/*
    C socket server example, handles multiple clients using threads
*/
 
#include <stdio.h>
#include <string.h>    //strlen
#include <stdlib.h>    //strlen
#include <sys/socket.h>
#include <arpa/inet.h> //inet_addr
#include <unistd.h>    //write
#include <pthread.h> //for threading , link with lpthread

int client_socks[1024];
int client_cnt = 0; 

//the thread function
void *task_handler(void *);


int main(int argc , char *argv[])
{
    pthread_t thread;
    int socket_desc , client_sock , c , *new_sock;
    struct sockaddr_in server , client;
     
    //Create socket
    socket_desc = socket(AF_INET , SOCK_STREAM , 0);
    if (socket_desc == -1)
    {
        printf("Could not create socket");
    }
    puts("Socket created");
     
    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( 8888 );
     
    //Bind
    if( bind(socket_desc,(struct sockaddr *)&server , sizeof(server)) < 0)
    {
        //print the error message
        perror("bind failed. Error");
        return 1;
    }
    puts("bind done");
     
    //Listen
    listen(socket_desc , 3);
     
    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);
     
     
    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);

    pthread_create( &thread , NULL ,  task_handler , NULL );


    while( (client_sock = accept(socket_desc, (struct sockaddr *)&client, (socklen_t*)&c)) )
    {
        printf("Connection %d accepted\n", client_cnt);
         
        client_socks[client_cnt] = client_sock;
        client_cnt++;

    }

    return 0;
}
 


void *task_handler(void * v)
{
    char message[1024] = "123";
    char recv_message[1024];

    int i  = 0;
    int count = 0;
    while(1)
    {
        for(i = 0; i < client_cnt; i++)
        {
            write(client_socks[i] , message , strlen(message));
            count++;
            printf("sending message %d to client %d\n", count, i);
            while(recv(client_socks[i] , recv_message , 1024 , 0) <= 0);
            printf("reply from %d receiced", i);
            
            fflush(stdout);
            usleep(1000);

        }
    }
    
} 


/*
void *connection_handler(void *socket_desc)
{
    static id = client_cnt;

    //Get the socket descriptor
    int sock = *(int*)socket_desc;
    int read_size;
    char *message , client_message[2000];
     
    //Send some messages to the client
    ///message = "Greetings! I am your connection handler\n";
    //write(sock , message , strlen(message));
     
    //message = "Now type something and i shall repeat what you type \n";
    //write(sock , message , strlen(message));
     

    if(read_size == 0)
    {
        puts("Client disconnected");
        fflush(stdout);
    }
    else if(read_size == -1)
    {
        perror("recv failed");
    }
         
    //Free the socket pointer
    free(socket_desc);
     
    return 0;
}
*/