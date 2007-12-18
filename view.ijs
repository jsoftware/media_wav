NB. media/wav/view - zoom wave form viewer

require 'media/wav plot'
coclass 'pwavview'

TITLE=: 'Wave Form Viewer'
ss=: ,.@[ ];.0 ]   NB. subset

F=: 0 : 0
pc f;
menupop "File";
menu new "&New" "" "" "";
menu open "&Open" "" "" "";
menusep;
menu exit "&Exit" "" "" "";
menupopz;
xywh 4 4 300 60;cc lens isigraph rightmove;
xywh 4 75 300 100;cc part isigraph rightmove bottommove;
xywh 4 178 228 10;cc info static topmove rightmove bottommove;cn "Info";
xywh 234 176 70 12;cc zoom trackbar tbs_both tbs_noticks leftmove topmove rightmove bottommove;
pas 4 2;pcenter;
rem form end;
)

create=: 3 : 0
  wd F
  wd 'pn *',y,' - ',TITLE
  wd 'set zoom 1 50 100 10 1'
  wd 'pshow;'
  DATA=: FILE=: ''
  ZOOM=: 50
  POS=: 0
  
  lens=: conew 'jzplot'
  PForm__lens=: 'myplot'
  PFormhwnd__lens=: wd 'qhwndp'
  PId__lens=: 'lens'
  
  part=: conew 'jzplot'
  PForm__part=: 'myplot'
  PFormhwnd__part=: wd 'qhwndp'
  PId__part=: 'part'
  
  init y
  update''
)

destroy=: 3 : 0
  wd 'pclose'
  destroy__lens''
  destroy__part''
  codestroy ''
)

f_close=: destroy

f_lens_paint=: 3 : 0
  pd__lens 'show'
)

getsysdata=: 3 : ' ''mx my mw mh ml mr mc ms''=: 8{.0".sysdata'

f_lens_mmove=: (3 : 0)@getsysdata
  if. -.ml do. return. end.
  POS=: <.(ZOOM-~#DATA)*mx%mw
  update''
)

f_part_paint=: 3 : 0
  pd__part 'show'
)

f_zoom_button=: 3 : 0
  ZOOM=: 0".zoom
  update''
)

init=: 3 : 0
  FILE=: y
  wavfile FILE
  RATE=: sampleRate_pwav_
  DATA=: 2 wavfile FILE
  TIME=: RATE %~ i.#DATA
  set_info''
)

update=: 3 : 0
  sel=. POS,<.10*2^0.1*ZOOM
  pd__lens 'reset;color gray'
  pd__lens TIME;DATA
  pd__lens 'color navy'
  pd__lens (sel ss TIME);sel ss DATA
  pd__lens 'show'
  plot__part (sel ss TIME);sel ss DATA
)

set_info=: 3 : 0
  s=.   'Rate ',(":sampleRate_pwav_%1000),' kHz, '
  s=. s,'',(":bitsPerSample_pwav_),' Bit/sample, '
  s=. s,'',(":chanels_pwav_),' Channel(s) '
  wd 'set info *',s
)

wavview=: 'pwavview' conew~ jpath

wavview_z_=: wavview_pwavview_

Note 'Test'
wavview '~addons/media/wav/test1.wav'
)
