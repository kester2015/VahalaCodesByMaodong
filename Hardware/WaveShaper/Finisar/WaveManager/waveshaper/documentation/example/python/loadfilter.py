#import WaveShaper Python API
from wsapi import *

#Create WaveShaper instance SN007090 and name it "ws1"
rc = ws_create_waveshaper("ws1", "../testdata/SN011313.wsconfig")
print "ws_create_waveshaper rc="+str(rc) 

#read WSP from file
wspfile = open('../testdata/test 100GHz 4ports alternating.wsp', 'r')
wsptext = wspfile.read()

#Compute and load the filter to device
rc = ws_load_profile("ws1", wsptext)
print "ws_load_profile rc="+str(rc)
