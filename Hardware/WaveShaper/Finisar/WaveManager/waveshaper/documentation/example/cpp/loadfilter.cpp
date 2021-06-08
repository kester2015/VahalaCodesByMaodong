#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ws_api.h>

//wsp text buffer
static char wsptext[1024 * 1024];

/** Example code demonstrates loading filter to WaveShaper
 */
int main(int argc, char** argv) {
	char*  configfile = NULL;
	char*  wspfile    = NULL;
	int    rc = 0;
	FILE*  fp = NULL;
	if(argc <3) {
		printf("usage: %s  <wsconfig>  <wspfile>\n", argv[0]);
		return -1;
	}

	//load parameters
	configfile = argv[1];
	wspfile    = argv[2];
	
	//create a WaveShaper instance and name it "ws1"
	rc = ws_create_waveshaper((char*)"ws1", configfile);
	printf("create waveshaper name=%s config=%s rc=%d\n", "ws1", configfile, rc);	
	if(rc != WS_SUCCESS) { 
		printf("Error: failed to create waveshaper\n");
		return -1; 
	}
	
	//open filter profile file and load wsptext
	fp = fopen( wspfile , "r");
	if(fp == NULL) {
		printf("Error: can not open file %s\n", wspfile);
		return -1;
	}	
	rc = fread(wsptext, 1, sizeof(wsptext)-1, fp);
	wsptext[rc] = '\0';
	fclose(fp);
	
	//load filter profile from wsptext
	rc = ws_load_profile("ws1", wsptext);
	if(rc !=WS_SUCCESS ) {
		printf("Load Profile Error: %s\n", ws_get_result_description(rc));
		return rc;
	}
	printf("Load Profile OK\n");
	
	//delete waveshaper object 
	rc = ws_delete_waveshaper("ws1");	
	if(rc !=WS_SUCCESS ) {
		printf("Delete WaveShaper Error: %s\n", ws_get_result_description(rc));
		return rc;
	}	
	
	printf("Load Filter Done\n");	
	return 0;
}