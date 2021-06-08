#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ws_api.h>

//wsp text buffer
static char wsptext[1024 * 1024*2];

static int CREATE_LOOP = 300;
static int OPEN_LOOP = 6;
static int LOAD_LOOP = 5;
static int RETRY_COUNT = 8;

/** Example code demonstrates loading filter to WaveShaper
 */
int main(int argc, char** argv) {
	char*  configfile = NULL;
	char*  wspfile    = NULL;
	int    rc = 0;
	int i,j,k,r;

	int total_retry = 0, total_openfail = 0, max_retry = 0;

	FILE*  fp = NULL;
	if(argc <2) {
		printf("usage: %s  <wsconfig>  [wspfile]\n", argv[0]);
		return -1;
	}

	//load parameters
	configfile = argv[1];
	wspfile    = argc>=3?argv[2]:NULL;
	
	if(wspfile!=NULL) {
		//open filter profile file and load wsptext
		fp = fopen( wspfile , "r");
		if(fp == NULL) {
			printf("Error: can not open file %s\n", wspfile);
			return -1;
		}	
		rc = fread(wsptext, 1, sizeof(wsptext)-1, fp);
		wsptext[rc] = '\0';
		fclose(fp);
	}

	for(i=0; i<CREATE_LOOP; i++) {
		//create a WaveShaper instance and name it "ws1"
		rc = ws_create_waveshaper((char*)"ws1", configfile);
		printf("create waveshaper name=%s config=%s rc=%d\n", "ws1", configfile, rc);	
		if(rc != WS_SUCCESS) { 
			printf("Error: failed to create waveshaper\n");
			return -1; 
		}

		float startf=0, stopf=0;
		rc = ws_get_frequencyrange("ws1", &startf, &stopf);
		if(rc != WS_SUCCESS) { 
			printf("Error: failed to get frequency range\n");
			return -1; 
		} else {
			printf("frequency range: %f - %f\n", startf, stopf);
		}

		if(total_openfail>0) {
			printf("open fail:%d retry count:%d max retry:%d\n", total_openfail, total_retry, max_retry+1);
		}

		for(j=0; j<OPEN_LOOP; j++) {

			for(r=0; r<RETRY_COUNT; r++){
				rc = ws_open_waveshaper("ws1");
				if(rc==WS_SUCCESS) {
					break;
				} else {
					if(r==0) {
						total_openfail +=1; 
					} 
					total_retry +=1;
					if(max_retry < r) {
						max_retry = r;						
					}

					printf("Open WaveShaper Error: %s\n", ws_get_result_description(rc));
					printf("Retry open waveshaper %d\n", r+1);
				}
			}
			if(rc !=WS_SUCCESS ) {
				return rc;
			}

			for(k=0; k<LOAD_LOOP; k++) {

				rc = ws_load_predefinedprofile("ws1", PROFILE_TYPE_BLOCKALL, 0, 0,0, 0);
				if(rc !=WS_SUCCESS ) {
					printf("Load Predefined BLOCKALL Profile Error: %s\n", ws_get_result_description(rc));
					return rc;
				}

				//load filter profile from wsptext
				if(wspfile!=NULL) {
					rc = ws_load_profile("ws1", wsptext);
					if(rc !=WS_SUCCESS ) {
						printf("Load Profile Error: %s\n", ws_get_result_description(rc));
					} else {
						printf("%d %d %d Load Profile OK\n", i,j,k);
					}
				}else {
					rc = ws_load_predefinedprofile("ws1", PROFILE_TYPE_BANDPASS, (startf+stopf)/2, 0.1f, 0, 1);
					if(rc !=WS_SUCCESS ) {
						printf("Load Predefined Profile Error: %s\n", ws_get_result_description(rc));
					} else {
						printf("%d %d %d Load Predefined Profile OK\n", i,j,k);
					}
				}
				fflush(stdout);
			}


			rc = ws_close_waveshaper("ws1");
		}
		

		
		//delete waveshaper object 
		rc = ws_delete_waveshaper("ws1");	
		if(rc !=WS_SUCCESS ) {
			printf("Delete WaveShaper Error: %s\n", ws_get_result_description(rc));
			return rc;
		}	

		fflush(stdout);
	}
	
	//printf("Load Filter Done\n");	
	return 0;
}