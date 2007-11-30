NB. media/wav - Windows WAV file creation and play
NB.
NB. 12/03/2006 Oleg Kobchenko

require 'dll files'

coclass 'pwav'

NB. =========================================================
NB. playing wave files
PlaySound=: 'winmm PlaySoundA > i *c i i'&cd

'SND_SYNC SND_ASYNC SND_MEMORY SND_LOOP SND_PURGE SND_ALIAS'=: 0 1 4 8 64 65536

NB.*wavplay v plays wav from file or memory
NB.   y:  wav file or char vector of wav format
NB.   x:  SND_* flags, SND_SYNC default, see wav.ijs for details
wavplay=: SND_SYNC&$: : (4 : 0)
  PlaySound y;0;x
)

NB. =========================================================
NB. making wave files
BIGEND=. ({.a.)={.1(3!:4)1
'`i2 i4'=: (0 1+2*BIGEND){ (1&ic)`(2&ic)`([: , _2 |.\ 1&ic)`([: , _4 |.\ 2&ic)
RATE=: 11000

NB.*wavmake v wav format from samples
NB.   y:  samples vector or (2,N)=$y matrix for stereo
NB.       range is 0..255 or _32768..32767
NB.   x:  sample rate in Hz, RATE default of 11000
wavmake=: 3 : 0
  RATE wavmake y               NB. x: sample rate, eg 11 kHz
:
  bs=. 8 16{~255<>./,y         NB. bits per sample
  ba=. (bs*#$y) <.@% 8         NB. block align
  br=. x * ba                  NB. byte rate (bytes/sec)
  d=. 'data',(,~ i4@#) i2`({&a.)@.(bs=8) ,|:y
  f=. 'fmt ',(i4 16),(i2 1),(i2 #$y),(i4 x),(i4 br),(i2 ba),i2 bs
  'RIFF',(,~ i4@#) 'WAVE',f,d
)

NB. =========================================================
NB. making notes
freq=: 440*2^12%~-&9
note=: 0.25&$: :(4 : '<.255*(%>./)(-<./) 1 o.y*x*2p1*(i.%<:)1+RATE*x')"0

NB.*wavmakenote v make wav format from musical notes
wavmakenote=: [: wavmake ;@(<@note freq)

NB.*wavnote v plays musical notes
NB.   y:  tones 0=C, 1=C#, 2=D of main octave
NB.   x:  durations in sec, 0.25 default of 1/4 sec
wavnote=: 4 wavplay wavmakenote


NB. =========================================================
NB. reading PCM wave files

ic=: 3!:4             NB. integer conversion
int=: _2&ic
sht=: _1&ic
byt=: a.&i.
ss=: ,:@[ ];.0 ]      NB. sub-string

oibeg=: 3 : 'OFFS=: 0'  NB. offset iterator
oimov=: 3 : 'y,~y-~OFFS=: OFFS+y'

wavhead=: 3 : 0
  oibeg''
         chunk         =:        y ss~ oimov 4
  assert chunk         -: 'RIFF'
         chunkSize     =: {. int y ss~ oimov 4
         format        =:        y ss~ oimov 4
  assert format        -: 'WAVE'

         subChunk1     =:        y ss~ oimov 4
         chunkSize1    =: {. int y ss~ oimov 4
         format1       =: {. sht y ss~ oimov 2
  assert format1       -: 1

         chanels       =: {. sht y ss~ oimov 2
         sampleRate    =: {. int y ss~ oimov 4
         byteRate      =: {. int y ss~ oimov 4
         blockAlign    =: {. sht y ss~ oimov 2
         bitsPerSample =: {. sht y ss~ oimov 2

         subChunk2     =:        y ss~ oimov 4
         chunkSize2    =: {. int y ss~ oimov 4
)

wavdata=: 3 : 0
  wavhead y
  f=. ]`byt`sht`int@.(bitsPerSample <.@% 8)
         data          =:    f   y ss~ oimov chunkSize2
)

wavinfo=: 3 : 0
  wavhead y
  r=.      'File Type       ',chunk
  r=. r,LF,'Total Size      ',":8+chunkSize
  r=. r,LF,'File Format     ',format
  r=. r,LF,'Channels        ',":chanels
  r=. r,LF,'Sample Rate     ',":sampleRate
  r=. r,LF,'Bits per Sample ',":bitsPerSample
)


NB. =========================================================
wavplay_z_=: wavplay_pwav_
wavmake_z_=: wavmake_pwav_
wavmakenote_z_=: wavmakenote_pwav_
wavnote_z_=: wavnote_pwav_
wavhead_z_=: wavhead_pwav_
wavdata_z_=: wavdata_pwav_
wavinfo_z_=: wavinfo_pwav_


NB. =========================================================
Note 'Test playing and making waves'
scriptdoc 'media/wav'

wavplay jpath'~addons/media/wav/test1.wav'
1 wavplay jpath'~addons/media/wav/test1.wav'      NB. async
(1+8) wavplay jpath'~addons/media/wav/test1.wav'  NB. async loop
64 wavplay <0                                     NB. stop

load 'files'
(wavmake i.100) fwrite jpath'~addons/media/wav/test2.wav'
(wavmake 1000?@$200) fwrite jpath'~addons/media/wav/test3.wav'
(wavmake ,~^:6 i.200) fwrite jpath'~addons/media/wav/test4.wav'

4 wavplay 2000 wavmake 1000?@$200              NB. memory
4 wavplay wavmake <.255*(%>./)(-<./) 1 o.440*    2p1*(i.%<:) RATE_pwav_
4 wavplay wavmake <.255*(%>./)(-<./) 1 o.440*1 o.2p1*(i.%<:) RATE_pwav_

65536 wavplay&>({.,&.>}.);:'System Asterisk Exclamation Exit Hand Question'

0.25 0.25 0.5 1 wavnote 0 2 4 5
0.25 wavnote 0 2 4 5
joy=.     11 11 12 14  14 12 11 9  7 7 9 11  11 9 9 9
joy=. joy,11 11 12 14  14 12 11 9  7 7 9 11  9  7 7 7
0.35 wavnote joy
(0.35 wavmakenote joy) fwrite jpath'~addons/media/wav/joy.wav'

<.0.5+freq_pwav_+i.12  NB. main octave
load 'plot'
plot 1 o.1 2 4*/2p1*(i.%<:)101
)

Note 'Test reading waves'
  load 'plot'
  W=. fread jpath '~addons/media/wav/test1.wav'
  wavinfo W
  plot wavdata W

  W=. fread jpath '~addons/media/wav/test2.wav'
  wavinfo W
  plot wavdata W
)
