NB. media/wav/view - zoom wave form viewer

require 'media/wav plot'
coclass 'pwavview'
coinsert 'jgl2'

TITLE=: 'Wave Form Viewer'
LENSFACT=: 8
substr=: ,."1@[ ];.0 ]

F=: 0 : 0
pc f;
xywh 4 4 360 60;cc lens isigraph rightmove;
xywh 4 68 360 128;cc part isigraph rightmove bottommove;
xywh 4 198 213 10;cc info static topmove rightmove bottommove;cn "Info";
xywh 294 197 70 12;cc zoom trackbar tbs_both leftmove topmove rightmove bottommove;
xywh 270 197 25 11;cc fix checkbox leftmove topmove rightmove bottommove;cn "Fix";
xywh 230 198 37 10;cc status static leftmove topmove rightmove bottommove;cn "Status";
pas 4 2;pcenter;
rem form end;
)

create=: 3 : 0
  wd F
  DATA=: FILE=: ''
  POS=: 0
  LW=: 720
  fix=: '1'
  zoom=: '50'

  wd 'pn *',y,' - ',TITLE
  wd 'set zoom 1 ',zoom,' 100 10 1'
  wd 'set fix ',fix
  wd 'pshow;'
  
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
  if. LW~:{.glqwh '' do. update'' else. pd__lens 'show' end.
)

getsysdata=: 3 : ' ''mx my mw mh ml mr mc ms''=: 8{.0".sysdata'

f_lens_mmove=: (3 : 0)@getsysdata
  if. -.ml do. return. end.
  POS=: <.((0".zoom)-~COUNT)*mx%mw
  update''
)

f_part_paint=: 3 : 0
  pd__part 'show'
)

f_zoom_button=: update

f_fix_button=: update

init=: 3 : 0
  FILE=: y
  1 wavfile FILE
  RATE=: sampleRate_pwav_
  COUNT=: sampleCount_pwav_
  set_info''
)

update=: 3 : 0
  sel=. POS,<.10*2^0.1*0".zoom
  glsel 'lens'
  'LW LH'=: glqwh ''
  lndex=. <.COUNT*(i.%]) LW * LENSFACT
  ltime=. lndex % RATE
  ldata=. (2;lndex,.1) wavfile FILE
  drng=. (<./ , >./) ldata
  stime=. (({.+i.@{:) sel) % RATE
  sdata=. (2;sel) wavfile FILE

  pd__lens 'reset;frame 1;grids 0 1;tics 1 0;labels 1 0;color lightgreen;'
  pd__lens 'yrange ',(":drng)
  pd__lens ltime;ldata
  pd__lens 'color navy'
  pd__lens stime;sdata
  tt=. 6!:2 'pd__lens ''show'' '

  pd__part 'reset;'
  if. 0".fix do. pd__part 'yrange ',(":drng) end.
  pd__part stime;sdata
  pd__part 'show'

  wd 'set status *',(0j3":tt),'s'
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
