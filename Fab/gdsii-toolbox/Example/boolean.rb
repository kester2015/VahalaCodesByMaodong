cl = RBA::CellView::active.layout
cc = RBA::CellView::active.cell
sp = RBA::ShapeProcessor.new

la = cl.layer(1,0)
lb = cl.layer(2,0)
lc = cl.layer(1,0)
sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_anotb,true,true,true)

la = cl.layer(1,0)
lb = cl.layer(3,0)
lc = cl.layer(1,0)
sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_or,true,true,true)

la = cl.layer(1,0)
lb = cl.layer(4,0)
lc = cl.layer(1,0)
sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_anotb,true,true,true)

la = cl.layer(5,0)
lb = cl.layer(6,0)
lc = cl.layer(2,0)
sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_anotb,true,true,true)

(3..6).each do |i|
  ln=cl.layer(i,0)
  cl.delete_layer(ln)
end