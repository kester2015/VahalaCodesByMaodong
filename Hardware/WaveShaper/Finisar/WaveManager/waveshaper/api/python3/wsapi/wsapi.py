from ctypes import *

wsapi = None


dllnames = ["wstestapi.dll", "wsapi.dll", "libwstestapi.so", "libwsapi.so"]
 
if (wsapi == None):
	for dllname in dllnames:
		try:
			wsapi = cdll.LoadLibrary(dllname)
		except:
			continue
		break

	if(wsapi == None):
		print ("Failed to load WaveShaper api library.  Please check library path")


def ws_init(param=""):
	if(wsapi==None):
		return -1
	return wsapi.ws_init(param);

def ws_deinit():
	if(wsapi==None):
		return -1
	return wsapi.ws_deinit();

def ws_create_waveshaper(name, wsconfig):
	if(wsapi==None):
		return -1
	p=create_string_buffer(name.encode('utf-8'))
	if(name == ""):
		p = create_string_buffer(32)
	return (wsapi.ws_create_waveshaper(p, wsconfig.encode('utf-8')), p.raw.decode('utf-8').strip("\x00"))		

LOADFLAG_DEFAULT    = 0
LOADFLAG_WAVESHAPER = 1
LOADFLAG_FLEXGRID   = 2

def ws_create_waveshaper4(name, wsconfig, cfg):
	if(wsapi==None):
		return -1
	p=create_string_buffer(name.encode('utf-8'))
	if(name == ""):
		p = create_string_buffer(32)
	return (wsapi.ws_create_waveshaper4(p, wsconfig, cfg), p.raw.decode('utf-8').strip("\x00"))	
	
def ws_load_config(name, wsconfig):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_config(name.encode('utf-8'), wsconfig.encode('utf-8'))
	
def ws_load_firmware(name, firmware):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_firmware(name.encode('utf-8'), firmware.encode('utf-8'))
	
def ws_delete_waveshaper(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_delete_waveshaper(name.encode('utf-8'))

def ws_open_waveshaper(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_open_waveshaper(name.encode('utf-8'))

def ws_close_waveshaper(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_close_waveshaper(name.encode('utf-8'))

def ws_prepare_filter(name, ucfxtext):
	if(wsapi==None):
		return -1
	return wsapi.ws_prepare_filter(name.encode('utf-8'), ucfxtext.encode('utf-8'))

def ws_load_filter(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_filter(name.encode('utf-8'))	

def ws_load_ucfx(name, ucfxtext):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_ucfx(name.encode('utf-8'), ucfxtext.encode('utf-8'))	

def ws_load_profile(name, wsptext):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_profile(name.encode('utf-8'), wsptext.encode('utf-8'))

def ws_load_ucfx_hitless(name, ucfxtext):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_profile_hitless(name.encode('utf-8'), ucfxtext.encode('utf-8'))	

def ws_load_profile_hitless(name, wsptext):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_profile_hitless(name.encode('utf-8'), wsptext.encode('utf-8'))
		

PROFILE_TYPE_BLOCKALL = 1
PROFILE_TYPE_TRANSMIT = 2
PROFILE_TYPE_BANDPASS = 3 
PROFILE_TYPE_BANDSTOP = 4
PROFILE_TYPE_GAUSSIAN = 5
def ws_load_predefinedprofile(name, filtertype, center, bandwidth, attn, port):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_predefinedprofile(name.encode('utf-8'), filtertype, c_float.from_param(center), c_float.from_param(bandwidth), c_float.from_param(attn), port)	
	
	
def ws_load_image(name, buffer, width, height):
	if(wsapi==None):
		return -1
	if(buffer==None):
		return -1
	barray = c_byte * (width * height)
	ba = barray.from_buffer(buffer)
	return wsapi.ws_load_image(name.encode('utf-8'), ba, width, height)	
	
def ws_save_filter(name, filename):
	if(wsapi==None):
		return -1
	return wsapi.ws_save_filter(name.encode('utf-8'), filename.encode('utf-8'))

def ws_get_status(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_get_status(name.encode('utf-8'))

def ws_send_cmd(name, cmd):
	if(wsapi==None):
		return -1
	p = create_string_buffer(1024)	
	i = c_int(1024)
	rc = wsapi.ws_send_command(name.encode('utf-8'), cmd.encode('utf-8'), p, pointer(i))
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""	

def ws_read_sno(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(256)
	rc = wsapi.ws_read_sno(name.encode('utf-8'), p, 256)	
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""
		
def ws_get_sno(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(256)
	rc = wsapi.ws_get_sno(name.encode('utf-8'), p, 256)	
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""

def ws_get_partno(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(256)
	rc = wsapi.ws_get_partno(name.encode('utf-8'), p, 256)	
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""

def ws_get_portcount(name):
	if(wsapi==None):
		return -1
	i = c_int(0)
	rc = wsapi.ws_get_portcount(name.encode('utf-8'), pointer(i))	
	if(rc==0):
		return i.value
	else:
		return 0

def ws_get_startfreq(name):
	if(wsapi==None):
		return -1
	f1 = c_float(0.0)
	f2 = c_float(0.0)
	rc = wsapi.ws_get_frequencyrange(name.encode('utf-8'), pointer(f1), pointer(f2))
	if(rc==0):
		return f1.value
	else:
		return 0	
		
def ws_get_stopfreq(name):
	if(wsapi==None):
		return -1
	f1 = c_float(0.0)
	f2 = c_float(0.0)
	rc = wsapi.ws_get_frequencyrange(name.encode('utf-8'), pointer(f1), pointer(f2))
	if(rc==0):
		return f2.value
	else:
		return 0		

def ws_get_ucfxtext(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(512*1024)
	i = c_int(512*1024)
	rc = wsapi.ws_get_ucfxtext(name.encode('utf-8'), p, pointer(i))
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""

def ws_compute_nextstep(name):
	if(wsapi==None):
		return -1
	return wsapi.ws_compute_nextstep(name.encode('utf-8'))

def ws_update_currentspectrum(name, status):
	if(wsapi==None):
		return -1
	return wsapi.ws_update_currentspectrum(name.encode('utf-8'), status)
	
	
def ws_get_result_description(rc):
	if(wsapi==None):
		return -1
	wsapi.ws_get_result_description.restype = c_char_p
	if(type(rc) == type(())):
		return wsapi.ws_get_result_description(rc[0])
	else:
		return wsapi.ws_get_result_description(rc)

def ws_get_version():
	if(wsapi==None):
		return -1
	wsapi.ws_get_version.restype = c_char_p
	return wsapi.ws_get_version()

def ws_get_configversion(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(1024)	
	rc = wsapi.ws_get_configversion(name.encode('utf-8'), p)
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""	

def ws_load_profile_for_modeling(name, wsptext, port):
	if(wsapi==None):
		return -1
	return wsapi.ws_load_profile_for_modeling(name.encode('utf-8'), wsptext, port, 0)

def ws_get_model_profile(name):
	if(wsapi==None):
		return -1
	p = create_string_buffer(512*1024)
	i = c_int(512*1024)
	rc = wsapi.ws_get_model_profile(name.encode('utf-8'), p, pointer(i))
	if(rc==0):
		return p.raw.strip("\x00")
	else:
		return ""
	
def ps_create_psobject(name, wsconfig):
	if(wsapi==None):
		return -1
	p=create_string_buffer(name.encode('utf-8'))
	if(name == ""):
		p = create_string_buffer(32)
	return (wsapi.ps_create_psobject(p, wsconfig), p.raw.decode('utf-8').strip("\x00"))	
	
def ps_delete_psobject(name):
	if(wsapi==None):
		return -1
	return wsapi.ps_delete_psobject(name.encode('utf-8'))

def ps_open_waveshaper(name):
	if(wsapi==None):
		return -1
	return wsapi.ps_open_waveshaper(name.encode('utf-8'))

def ps_close_waveshaper(name):
	if(wsapi==None):
		return -1
	return wsapi.ps_close_waveshaper(name.encode('utf-8'))

def ps_load_psp(name, wsptext):
	if(wsapi==None):
		return -1
	return wsapi.ps_load_psp(name.encode('utf-8'), wsptext.encode('utf-8'))

def ps_load_predefinedprofile(name, filtertype, center, bandwidth, attn, port):
	if(wsapi==None):
		return -1
	return wsapi.ps_load_predefinedprofile(name.encode('utf-8'), filtertype, c_float.from_param(center), c_float.from_param(bandwidth), c_float.from_param(attn), port)	
	
def ps_get_startfreq(name):
	if(wsapi==None):
		return -1
	f1 = c_float(0.0)
	f2 = c_float(0.0)
	rc = wsapi.ps_get_frequencyrange(name.encode('utf-8'), pointer(f1), pointer(f2))
	if(rc==0):
		return f1.value
	else:
		return 0	
		
def ps_get_stopfreq(name):
	if(wsapi==None):
		return -1
	f1 = c_float(0.0)
	f2 = c_float(0.0)
	rc = wsapi.ps_get_frequencyrange(name.encode('utf-8'), pointer(f1), pointer(f2))
	if(rc==0):
		return f2.value
	else:
		return 0		
