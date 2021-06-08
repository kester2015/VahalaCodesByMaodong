/** @file ws_psapi.h
 *  @author Finisar Australia - Copyright (c) 2005-2011
 *  @author Patrick Blown
 *
 * This header defines PowerSplitting API functions
 *
 */
 
#ifndef _WS__PSAPI__H_
#define _WS__PSAPI__H_

extern "C" {
	int ps_create_psobject(const char* name, const char* wsconfig);
	int ps_create_psobject2(const char* name, const char* wsconfig, const char* serial, const char* spi, void* reserved);
	int ps_delete_psobject(const char* name);
	int ps_open_waveshaper(const char* name);
	int ps_close_waveshaper(const char* name);
	int ps_load_psp(const char* name, const char* buffer);
	int ps_set_threshold(const char* name,double threshdB);
	int ps_set_debug_mode(const char* name,int debugmode);
	int ps_get_frequencyrange(const char* name, float* start, float* stop);
	int ps_load_predefinedprofile(const char* name, int filtertype, float center, float bandwidth, float attn, int port);
	int ps_create_image(const char* name, const char* PSPFilename, const char* BMPFilename);
}

#endif