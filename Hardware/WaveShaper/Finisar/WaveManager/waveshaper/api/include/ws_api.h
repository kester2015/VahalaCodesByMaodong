/** @file ws_api.h
 *  @author Finisar Australia - Copyright (c) 2005-2011
 *  @author Qing Li
 *
 * This header defines WaveShaper API functions
 *
 */
 
#ifndef _WS__API__H_
#define _WS__API__H_

#ifdef __cplusplus
extern "C" {
#endif

//////////////////////////////////////////////
//  WaveShaper functions
//////////////////////////////////////////////
/** Create WaveShaper object
 *@param name     [in|out] <1> User define WaveShaper name.
 *@n                   Valid name contains one or more letters or digits or underscore.
 *@n                   Distinct name must be used when creating new WaveShaper objects.
 *@n                   <2> Instead user define the name, a distinct name will be generated for WaveShaper created. 
 *@n                   User pass in a buffer with empty string (NOT NULL Pointer).
 *@n                   The buffer should be at least 32 bytes long to hold the name generated.
 *@param wsconfig [in] Path string to Configuration file
 *@return result code, WS_SUCCESS if success.
 */
int ws_create_waveshaper(char* name, const char* wsconfig);


/** Create waveshaper object from multi-config format
 *@param name     [in|out] <1> User define WaveShaper name.
 *@n                   Valid name contains one or more letters or digits or underscore.
 *@n                   Distinct name must be used when creating new WaveShaper objects.
 *@n                   <2> Instead user define the name, a distinct name will be generated for WaveShaper created. 
 *@n                   User pass in a buffer with empty string (NOT NULL Pointer).
 *@n                   The buffer should be at least 32 bytes long to hold the name generated.
 *@param wsconfig [in] Path string to Configuration file
 *@param cfg      [in] sub configuration part
 *@return result code, WS_SUCCESS if success.
 */
int ws_create_waveshaper4(char* name, const char* wsconfig, const char* cfg);

/** Create waveshaper object from multi-config format
 */
int ws_create_waveshaper5(char* name, const char* wsconfig, const char* serial, const char* spi, const char* cfg);

/** Create WaveShaper object for simulation without real device
 *@param name     [in|out] <1> User define WaveShaper name.
 *@n                   Valid name contains one or more letters or digits or underscore.
 *@n                   Distinct name must be used when creating new WaveShaper objects.
 *@n                   <2> Instead user define the name, a distinct name will be generated for WaveShaper created. 
 *@n                   User pass in a buffer with empty string (NOT NULL Pointer).
 *@n                   The buffer should be at least 32 bytes long to hold the name generated.
 *@param wsconfig [in] Path string to Configuration file
 *@return result code, WS_SUCCESS if success.
 */
int ws_create_waveshaper_forsimulation(char* name, const char* wsconfig);


/** Load configuration file
 *@n Correct configuration file (*.wsconfig) must be loaded, in order to generate filter profile
 *@param name     [in] Previously created WaveShaper name
 *@param wsconfig [in] Path string to Configuration file
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_config(const char* name, const char* wsconfig);

/** Delete WaveShaper object.
 *@n The Waveshaper object will be automatically closed, if it is in open state.
 *@param name     [in] Previously created WaveShaper name
 *@return result code, WS_SUCCESS if success.
 */
int ws_delete_waveshaper(const char* name);

/** Open WaveShaper.
 *@n Establish connection to Waveshaper device. 
 *@param name     [in] Previously created WaveShaper name
 *@return result code, WS_SUCCESS if success.
 */
int ws_open_waveshaper(const char* name);

/** Close WaveShaper.
 *@n Disconnect to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@return result code, WS_SUCCESS if success.
 */
int ws_close_waveshaper(const char* name);

/** Apply UCFX filter and wait for completion.
 *@deprecated use ws_load_profile instead
 *@n Calculate filter profile based on ucfxtext, then load filter to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@param ucfxtext [in] UCFX text string
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_ucfx(const char* name, const char* ucfxtext);

/** Apply UCFX filter with temperature compensation and wait for completion.
 *@deprecated use ws_load_profile instead
 *@n Calculate filter profile based on ucfxtext, then load filter to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@param ucfxtext [in] UCFX text string
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_profile_tempcompensation(const char* name, const char* ucfxtext);

/** Load profile and wait for completion.
 *@n Calculate filter profile based on profile (wsp format), then load filter to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@param wsptext  [in] wsp text string
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_profile(const char* name, const char* wsptext);

/** Load profile and wait for completion (with mode parameter)
 *@n Calculate filter profile based on profile (wsp format), then load filter to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@param wsptext  [in] wsp text string
 *@param mode     [in] load mode 
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_profile2(const char* name, const char* wsptext, int mode);

#define  LOAD_PROFILE_DEFAULT     (0x00000000)
#define  LOAD_PROFILE_HITLESS     (0x00000001)
#define  LOAD_PROFILE_FULLUPDATE  (0x00000002)
#define  LOAD_PROFILE_TEMPCOMPENSATION  (0x00000004)

/** Load predefined filter and wait for completion.
 *@n Calculate filter profile based on profile type and parameters, then load filter to Waveshaper device.
 *@param name     [in] Previously created WaveShaper name
 *@param filtertype [in] filter type
 *@param center   [in] center frequency (THz)
 *@param bandwidth[in] bandwidth (GHz)
 *@param attn     [in] attenuation (dB)
 *@param port     [in] port number 
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_predefinedprofile(const char* name, int filtertype, float center, float bandwidth, float attn, int port);

#define PROFILE_TYPE_BLOCKALL  1
#define PROFILE_TYPE_TRANSMIT  2
#define PROFILE_TYPE_BANDPASS  3 
#define PROFILE_TYPE_BANDSTOP  4
#define PROFILE_TYPE_GAUSSIAN  5

/** Recover WaveShaper from soft error and wait for completion
 *@param name     [in] Previously created WaveShaper name
 *@param timeout  [in] Timeout in seconds, 0 for defualt timeout
 *@return result code, WS_SUCCESS if success.
 */
int ws_recover(const char* name, int arg);

/** Read WaveShaper Serial Number from WaveShaper device
 *@param name     [in] Previously created WaveShaper name
 *@param sno      [out] NULL terminated serial number string
 *@param size     [in] buffer size of sno
 *@return status code
 */
int ws_read_sno(const char* name, char* sno, int size);


/** Get WaveShaper Serial Number from configuration
 *@param name     [in] Previously created WaveShaper name
 *@param sno      [out] NULL terminated serial number string
 *@param size     [in] buffer size of sno
 *@return status code
 */
int ws_get_sno(const char* name, char* sno, int size);

/** Get WaveShaper Frequency Range
 *@param name     [in] Previously created WaveShaper name
 *@param start    [out] start frequency (Can not be NULL)
 *@param stop     [out] stop frequency (Can not be NULL)
 *@return status code
 */
int ws_get_frequencyrange(const char* name, float* start, float* stop);

/** Get WaveShaper Port Count
 *@param name     [in] Previously created WaveShaper name
 *@param nport    [out] number of ports (Can not be NULL)
 *@return status code
 */
int ws_get_portcount(const char* name, int* nport);

/** Get WaveShaper Part Number
 *@param name     [in] Previously created WaveShaper name
 *@param pno      [out] NULL terminated part number string
 *@param size     [in] buffer size of pno
 *@return status code
 */
int ws_get_partno(const char* name, char* pno, int size);
	
/** Get status of waveshaper
 *@param name     [in] Previously created WaveShaper name
 *@return status code, see WSAPI_STATUS_... definitions
 */
#define WSAPI_STATUS_OPEN    2
#define WSAPI_STATUS_CLOSE   3
#define WSAPI_STATUS_ERROR   4
int ws_get_status(const char* name);

/** Retrieve current loaded profile as ucfx
 *@deprecated use ws_get_profile instead
 *@param name     [in] Previously created WaveShaper name
 *@param ucfxbuffer  [out] NULL terminated ucfx output
 *@param psize    [in/out] buffer size and uxfx output size
 *@return status code
 */
int ws_get_ucfxtext(const char* name, char* ucfxbuffer, int* psize);

/** Retrieve current loaded profile as wsp formated string
 *@param name       [in] Previously created WaveShaper name
 *@param wspbuffer  [out] NULL terminated wsp output
 *@param psize      [in/out] buffer size and wsp output size
 *@return status code
 */
int ws_get_profile(const char* name, char* wspbuffer, int* psize);

/** Load new version of firmware to waveshaper
 *@param name     [in] Previously created WaveShaper name
 *@param filename [in] Path to firmware file
 *@param oldver   [out] pointer to old firmware version buffer, must be larger than 64bytes
 *@param newver   [out] pointer to new firmware version buffer, must be larger than 64bytes
 *@return status code
 */
int ws_load_firmware(const char* name, const char* filename, char* oldver, char* newver);

/** Get WaveShaper Configuration version
 *@param name       [in] Previously created WaveShaper name
 *@param version    [out] buffer to hold version string, it must be at least 32 bytes long
 *@return result code, WS_SUCCESS if success.
 */
int ws_get_configversion(const char* name, char* version);

/** Get text description from result code
 *@param rc     [in] Result code
 *@return text description of the result code
 */
const char* ws_get_result_description(int rc);

/** Get WaveShaper version
 *@return WaveShaper version string as MAJOR.MINOR.BUILD
 */
const char* ws_get_version();

/** List all WaveShaper devices
 *@param buffer     [out] buffer to hold device ids
 *@param buffersize [in]  buffer size
 */
int ws_list_devices(char* buffer, int buffersize);

/** Create WaveShaper object from serial number
 *@param name     [in] User define WaveShaper name.
 *@n                   Valid name contains one or more letters or digits or underscore.
 *@n                   Distinct name must be used when creating new WaveShaper objects.
 *@param sno      [in] Serial number of the WaveShaper
 *@return result code, WS_SUCCESS if success.
 */
int ws_create_waveshaper_fromsno(char* name, const char* sno);


/** Load profile and initialize modeling data structures
 *@param name     [in] Previously created WaveShaper name
 *@param wsptext  [in] wsp text string
 *@param port     [in] port number to be modeled
 *@return result code, WS_SUCCESS if success.
 */
int ws_load_profile_for_modeling(const char* name, const char* wsptext, int port, void* resv);
 
 /** Retrieve modeled profile
 *@param name       [in] Previously created WaveShaper name
 *@param wspbuffer  [out] NULL terminated wsp output
 *@param psize      [in/out] buffer size and wsp output size
 *@return status code
 */
int ws_get_model_profile(const char* name, char* wspbuffer, int* psize);

/** Read Configuration from WaveShaper Device
 *@param name       [in] Previously created WaveShaper name
 *@param buffer     [out] buffer to hold configuration data
 *@param buffersize [in] buffer size
 *@param nread      [out] configuration data read in bytes
 *@return status code
 */
int ws_read_configdata(const char* name, char* buffer, int buffersize, int* nread);

/** Write Configuration to WaveShaper Device
 *@param name       [in] Previously created WaveShaper name
 *@param buffer     [out] buffer to hold configuration data
 *@param buffersize [in] buffer size
 *@param nwrite     [out] configuration data written in bytes
 */
int ws_write_configdata(const char* name, char* buffer, int size, int* nwrite);

/** Send raw serial command to waveshaper
 *@param name          [in] Previously created WaveShaper name
 *@param cmd           [in] NULL terminated command string 
 *@param response      [out] Response buffer
 *@param responsesize  [in|out] pointer to the limit of the response buffer size as input,
 *@n                            hold the response data length as output 
 *@return result code, WS_SUCCESS if success.
 */
int ws_send_command(const char* name, const char* cmd, char* response, int* responsesize);

#ifdef __cplusplus
}
#endif

#ifndef WS_SUCCESS
/* return code list */
#define WS_SUCCESS                    (0)
#define WS_ERROR                      (-1)
#define WS_INTERFACE_NOTSUPPORTED     (-2)
#define WS_NULL_PARAM                 (-3)
#define WS_UNKNOWN_NAME               (-4)
#define WS_NO_ITEM                    (-5)
#define WS_INVALID_CID                (-6)
#define WS_INVALID_IID                (-7)
#define WS_NULL_POINTER               (-8)
#define WS_BUFFEROVERFLOW             (-9)
#define WS_WRONGSTATE                 (-10)
#define WS_NO_THREADPOOL              (-11)
#define WS_NO_DIRECTORY               (-12)
#define WS_BUSY                       (-16)
#define WS_NULL_BUFFER                (-17)
#define WS_NO_SUCH_FIELD              (-18)
#define WS_NO_SUCH_PROPERTY           (-19)
#define WS_IO_ERROR                   (-20)
#define WS_TIMEOUT                    (-21)
#define WS_ABORTED                    (-22)
#define WS_LOADMODULE_ERROR           (-23)
#define WS_GETPROCESS_ERROR           (-24)
#define WS_OPEN_PORT_FAILED           (-25)
#define WS_NOT_FOUND                  (-26)
#define WS_OPEN_FILE_FAILED           (-27)
#define WS_FILE_TOOLARGE              (-28)
#define WS_INVALIDPORT                (-29)
#define WS_INVALIDFREQ                (-30)
#define WS_INVALIDATTN                (-31)
#define WS_INVALIDUCFX                (-32)
#define WS_INVALIDSPACING             (-33)
#define WS_NARROWBANDWIDTH            (-34)
#define WS_OPENFAILED                 (-35)
#define WS_OPTION_ERROR               (-36)
#define WS_COMPRESS_ERROR             (-37)
#define WS_WAVESHAPER_NOT_FOUND       (-38)
#define WS_WAVESHAPER_CMD_ERROR       (-39)
#define WS_NOT_SUPPORTED              (-40)
#define WS_DUPLICATE_NAME             (-41)
#define WS_INVALIDFIRMWARE            (-42)
#define WS_INCOMPATIBLEFIRMWARE       (-43)
#define WS_OLDERFIRMWARE              (-44)
#define WS_INVALIDIMGSIZE             (-45)
#define WS_OUTOFRANGE                 (-46)
#define WS_NO_TEMPERATURE             (-47)
#endif

#endif
