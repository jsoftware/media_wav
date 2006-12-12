NB. media/wav - Windows WAV file creation and play
NB.
NB. 12/03/2006 Oleg Kobchenko

require 'dll'

coclass 'pwav'

NB. =========================================================
PlaySound=: 'winmm PlaySoundA > i *c i i'&cd

'SND_SYNC SND_ASYNC SND_MEMORY SND_LOOP SND_PURGE SND_ALIAS'=: 0 1 4 8 64 65536

NB.*wavplay v plays wav from file or memory
NB.   y:  wav file or char vector of wav format
NB.   x:  SND_* flags, SND_SYNC default, see wav.ijs for details
wavplay=: SND_SYNC&$: : (4 : 0)
  PlaySound y;0;x
)

NB. =========================================================
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
freq=: 440*2^12%~-&9
note=: 0.25&$: :(4 : '<.255*(%>./)(-<./) 1 o.y*x*2p1*(i.%<:)1+RATE*x')"0

NB.*wavmakenote v make wav format from musical notes
wavmakenote=: [: wavmake ;@(<@note freq)

NB.*wavnote v plays musical notes
NB.   y:  tones 0=C, 1=C#, 2=D of main octave
NB.   x:  durations in sec, 0.25 default of 1/4 sec
wavnote=: 4 wavplay wavmakenote

NB. =========================================================
wavplay_z_=: wavplay_pwav_
wavmake_z_=: wavmake_pwav_
wavmakenote_z_=: wavmakenote_pwav_
wavnote_z_=: wavnote_pwav_


NB. =========================================================
0 : 0
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
