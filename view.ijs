NB. media/wav/view - zoom wave form viewer

require 'media/wav plot'
coclass 'pwavview'
coinsert 'jgl2'

TITLE=: 'Wave Form Viewer'
LENSFACT=: 8
substr=: ,."1@[ ];.0 ]
getsysdata=: 3 : ' ''mx my mw mh ml''=: 5{.0".sysdata'

FT=: 0 : 0
pc ft;
minwh 310 150;cc lens isigraph flush;
minwh 310 150;cc part isigraph flush;
bin h;
cc fix checkbox;cn "Fix";
cc zoom slider 0 0 1 10 100 50;
bin zh;
cc info static;cn "Info";
cc status static;cn "Status";
bin z;
)

create=: 3 : 0
  wd FT
  DATA=: FILE=: ''
  POS=: 0
  LW=: 720
  fix=: '1'
  zoom=: '50'
  SBEGIN=: ''

  wd 'pn ',y,' - ',TITLE
  wd 'set fix value ',fix
  wd 'pshow;'
  
  lens=: ('ft';'lens') conew 'jzplot'
  part=: ('ft';'part') conew 'jzplot'
  
  init y
  update''
)

destroy=: 3 : 0
  wd 'pclose'
  destroy__lens''
  destroy__part''
  codestroy ''
)

ft_close=: destroy
ft_cancel=: f_close

ft_lens_paint=: 3 : 0
  if. LW~:{.glqwh '' do.
    update''
  end.
)

ft_lens_mmove=: (3 : 0)@getsysdata
  if. -.ml do. return. end.
  POS=: 0>.1<.mx%mw
  update''
)

ft_part_mbldown=: (3 : 0)@getsysdata
  SBEGIN=: mx
  SPOS=: POS
)

ft_part_mblup=: (3 : 0)@getsysdata
  SBEGIN=: ''
)

ft_part_mmove=: (3 : 0)@getsysdata
  if. 0=#SBEGIN do. return. end.
  POS=: 0>.1<.SPOS+(SCNT%COUNT)*(SBEGIN-mx)%mw
  update''
)

ft_zoom_changed=: update

ft_fix_button=: update

init=: 3 : 0
  FILE=: y
  1 wavfile FILE
  RATE=: sampleRate_pwav_
  COUNT=: sampleCount_pwav_
  set_info''
)

update=: 3 : 0
  SCNT=: <.10*2^0.1*0".zoom
  sel=. (<.POS*COUNT-SCNT),SCNT
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

  wd 'set status text *',(0j3":tt),'s'
)

set_info=: 3 : 0
  s=.   'Rate ',(":sampleRate_pwav_%1000),' kHz, '
  s=. s,'',(":bitsPerSample_pwav_),' Bit/sample, '
  s=. s,'',(":chanels_pwav_),' Channel(s) '
  wd 'set info text *',s
)

wavview=: 'pwavview' conew~ jpath

wavview_z_=: wavview_pwavview_

Note 'Test'
  wavview '~addons/media/wav/test1.wav'
)
