#include "fandracApi.h"
#include <stdio.h> 
#include <string.h> 
#include <stdarg.h>
#include <stdlib.h> 
#include <errno.h> 
#include <unistd.h>
#include <arpa/inet.h>  
#include <sys/types.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 
#include <sys/time.h> 
#include<json-c/json.h>
#include <syslog.h>
     
#define TRUE   1 
#define FALSE  0 
#define PORT 8888 
#define MAX_CLIENTS 10
#define CONFIG_FILE "/root/fandracApi/config/ipmi_config.json"
#define  LOG_OUTPUT  "/root/fandracApi/log/fandracApi"

char        logTxt[]="test";

int main(int argc , char *argv[])  
{  
    
    // logOut("Starting fanDracAPI %d\n", 12);
    openlog(logTxt, LOG_CONS|LOG_PID, LOG_LOCAL7);
    syslog(LOG_DEBUG, "Ceci est un essai...");

    int opt = TRUE;  
    int master_socket , addrlen , new_socket , client_socket[MAX_CLIENTS] , 
          activity, client_id , valread , sd;  
    int max_sd;  
    struct sockaddr_in address;  
         
    char tcp_rx_buffer[1025];
         
    fd_set readfds;  
         
    char *message = "Welcome to the fandrac TCP API \r\n"; 

    read_json_idrac_configuration(CONFIG_FILE);
     
    for (client_id = 0; client_id < MAX_CLIENTS; client_id++)  
    {  
        client_socket[client_id] = 0;  
    }  

    /* Create server socket */ 
    if( (master_socket = socket(AF_INET , SOCK_STREAM , 0)) == 0)  
    {  
        perror("socket failed");  
        exit(EXIT_FAILURE);  
    }       
    if( setsockopt(master_socket, SOL_SOCKET, SO_REUSEADDR, (char *)&opt, 
          sizeof(opt)) < 0 )  
    {  
        perror("setsockopt");  
        exit(EXIT_FAILURE);  
    }  
     
    address.sin_family = AF_INET;  
    address.sin_addr.s_addr = INADDR_ANY;  
    address.sin_port = htons(PORT);  

    /* Bind the master socket */     
    if (bind(master_socket, (struct sockaddr *)&address, sizeof(address))<0)  
    {  
        perror("bind failed");  
        exit(EXIT_FAILURE);  
    }  
    printf("Listener on port %d \n", PORT);  
         
    if (listen(master_socket, 3) < 0)  
    {  
        perror("listen");  
        exit(EXIT_FAILURE);  
    }  
         
    addrlen = sizeof(address);  
    puts("Waiting for connections ...");  
         
    while(TRUE)  
    {  
        FD_ZERO(&readfds);  
     
        FD_SET(master_socket, &readfds);  
        max_sd = master_socket;  
             
        for ( client_id = 0 ; client_id < MAX_CLIENTS ; client_id++)  
        {  
            sd = client_socket[client_id];  
                 
            if(sd > 0)  
                FD_SET( sd , &readfds);  
                 
            if(sd > max_sd)  
                max_sd = sd;  
        }  
     
        activity = select( max_sd + 1 , &readfds , NULL , NULL , NULL);  
       
        if ((activity < 0) && (errno!=EINTR))  
        {  
            printf("select error");  
        }  
        if (FD_ISSET(master_socket, &readfds))  
        {  
            if ((new_socket = accept(master_socket, 
                    (struct sockaddr *)&address, (socklen_t*)&addrlen))<0)  
            {  
                perror("accept");  
                exit(EXIT_FAILURE);  
            }  
             
            printf("New connection , socket fd is %d , ip is : %s , port : %d\n" 
            , new_socket , inet_ntoa(address.sin_addr) , ntohs (address.sin_port));  
           
            if( send(new_socket, message, strlen(message), 0) != strlen(message) )  
            {  
                perror("send");  
            }  
                 
            puts("Welcome message sent successfully");  
            logOut("Welcome message sent successfully\n");
                 
            for (client_id = 0; client_id < MAX_CLIENTS; client_id++)  
            {  
                //if position is empty 
                printf("debug 1\n");
                if( client_socket[client_id] == 0 )  
                {  
                    printf("debug 1 %d\n", client_id);
                    client_socket[client_id] = new_socket;  
                    printf("Client added as ID: %d (MAX: %s)\n" , client_id, MAX_CLIENTS);  
                         
                    break;  
                }  
            }  
        }  
             
        for (client_id = 0; client_id < MAX_CLIENTS; client_id++)  
        {  
            sd = client_socket[client_id];  
                 
            if (FD_ISSET( sd , &readfds))  
            {  
                if ((valread = read( sd , tcp_rx_buffer, 1024)) == 0)  
                {  
                    getpeername(sd , (struct sockaddr*)&address , \
                        (socklen_t*)&addrlen);  
                    printf("Host disconnected , ip %s , port %d \n" , 
                          inet_ntoa(address.sin_addr) , ntohs(address.sin_port));  
                    close( sd );  
                    client_socket[client_id] = 0;  
                }  
                     
                else 
                {  
                    tcp_rx_buffer[valread] = '\0';  
                    send(sd , tcp_rx_buffer , strlen(tcp_rx_buffer) , 0 );
                    
                }  
            }  
        }  
    }  
         
    closelog();
    return 0;  
} 


void read_json_idrac_configuration(char * filepath)
{
    FILE *fp;
	char json_read_buffer[1024];
	struct json_object *parsed_json;
	struct json_object *user;
	struct json_object *password;
	struct json_object *host;

	size_t i;	

	fp = fopen(filepath,"r");
	fread(json_read_buffer, 1024, 1, fp);
	fclose(fp);

	parsed_json = json_tokener_parse(json_read_buffer);

	json_object_object_get_ex(parsed_json, "user", &user);
	json_object_object_get_ex(parsed_json, "password", &password);
	json_object_object_get_ex(parsed_json, "host", &host);

	printf("user: %s\n", json_object_get_string(user));
	printf("password: %s\n", json_object_get_string(password));
	printf("host: %s\n", json_object_get_string(host));	
}

void logOut(const char *control_string, ...)
{
   FILE *fp;
   fp = fopen(LOG_OUTPUT,"ab+");

   va_list argptr;
   va_start(argptr,control_string);
   fprintf(fp,control_string,argptr);
//    vfprintf(fp, control_string, argptr);
   va_end(argptr);
   fclose(fp);
}