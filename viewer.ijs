NB. command-line WAVE form viewer

Note 'Example'
  j.exe -jijx media/wav/viewer "addons/media/wav/test1.wav"
)
Note 'Associate'
  To associate in Windows Explorer  with right-click "View" choice,
  edit the viewer.reg file for j.exe path and run it.
  Note: "SoundRec" is typical .wav file type, YMMV.
)

require 'media/wav/view'
wavview >{:ARGV
