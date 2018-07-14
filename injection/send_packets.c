/*
 * (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
 */
#include <linux/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#include <tx80211.h>
#include <tx80211_packet.h>

#include <stdio.h>  
#include <string.h>    
#include <sys/socket.h>     
#include <arpa/inet.h> 
#include <signal.h>

#include "util.h"

static void init_lorcon();
void caught_signal(int sig);
void exit_program(int code);

struct lorcon_packet
{
	__le16	fc;
	__le16	dur;
	u_char	addr1[6];
	u_char	addr2[6];
	u_char	addr3[6];
	u_char device_id;//> add by myself 
	__le16	seq;
	u_char	payload[0];
} __attribute__ ((packed));

struct tx80211	tx;
struct tx80211_packet	tx_packet;
uint8_t *payload_buffer;
#define PAYLOAD_SIZE	2000000
#define DEVICE_ID 0x01

int sock;

static inline void payload_memcpy(uint8_t *dest, uint32_t length,
		uint32_t offset)
{
	uint32_t i;
	for (i = 0; i < length; ++i) {
		dest[i] = payload_buffer[(offset + i) % PAYLOAD_SIZE];
	}
}




int main(int argc, char** argv)
{
	uint32_t num_packets = 10000;
	uint32_t packet_size = 5;
	struct lorcon_packet *packet;
	uint32_t i;
	int32_t ret, inject_ret;
	uint32_t mode = 1;


	
    struct sockaddr_in server;
    char message[1024];
     
    //Create socket
    sock = socket(AF_INET , SOCK_STREAM , 0);
    if (sock == -1)
    {
        printf("Could not create socket");
    }
    printf("Socket created\n");

    server.sin_addr.s_addr = inet_addr("192.168.0.1");
    server.sin_family = AF_INET;
    server.sin_port = htons( 8888 );
 
    //Connect to remote server
    if (connect(sock , (struct sockaddr *)&server , sizeof(server)) < 0)
    {
        perror("connect failed. Error");
        return 1;
    }
     
    printf("Connected\n");

	/* Generate packet payloads */
	printf("Generating packet payloads \n");
	payload_buffer = (uint8_t*)malloc(PAYLOAD_SIZE);
	if (payload_buffer == NULL) {
		perror("malloc payload buffer");
		exit(1);
	}
	generate_payloads(payload_buffer, PAYLOAD_SIZE);

	/* Setup the interface for lorcon */
	printf("Initializing LORCON\n");
	init_lorcon();

	/* Allocate packet */
	packet = (struct lorcon_packet*)malloc(sizeof(*packet) + packet_size);
	if (!packet) {
		perror("malloc packet");
		exit(1);
	}
	packet->fc = (0x08 /* Data frame */
				| (0x0 << 8) /* Not To-DS */);
	packet->dur = 0xffff;
	if (mode == 0) {
		memcpy(packet->addr1, "\x00\x16\xea\x12\x34\x56", 6);
		get_mac_address(packet->addr2, "mon0");
		memcpy(packet->addr3, "\x00\x16\xea\x12\x34\x56", 6);
	} else if (mode == 1) {
		memcpy(packet->addr1, "\x00\x16\xea\x12\x34\x56", 6);
		memcpy(packet->addr2, "\x00\x16\xea\x12\x34\x56", 6);
		//memcpy(packet->addr2, "\x00\x01\x02\x03\x04\x05", 6);
		memcpy(packet->addr3, "\xff\xff\xff\xff\xff\xff", 6);
	}
	
	packet->device_id = DEVICE_ID;
	packet->seq = 0;
	tx_packet.packet = (uint8_t *)packet;
	tx_packet.plen = sizeof(*packet) + packet_size;
	payload_memcpy(packet->payload, packet_size, 0);

	/* Send packets */
	int count = 0;
	printf("Sending %u packets of size %u (. every thousand)\n", num_packets, packet_size);

	signal(SIGINT, caught_signal);

	while(1)
	{
		
		ret = recv(sock, message , 1024 , 0);
        if( ret > 0)
        {
            printf("recv: %s", message);
            fflush(stdout);

            packet->seq = count & 0xffff;	

			inject_ret = tx80211_txpacket(&tx, &tx_packet);

			if (inject_ret < 0) {
			 	fprintf(stderr, "Unable to transmit packet: %s\n",
			 			tx.errstr);
			 	exit(1);
			}

            write(sock , message , strlen(message));
            usleep(1000);
            write(sock , message , strlen(message));

            if (count % 100 == 0) 
			{
				printf("%d \n", count);
				fflush(stdout);
			}
          	count++;

        }else if(ret < 0)
        {
            printf("failed\n");
            fflush(stdout);
            break;
        }

	}

	return 0;
}

static void init_lorcon()
{
	/* Parameters for LORCON */
	int drivertype = tx80211_resolvecard("iwlwifi");

	/* Initialize LORCON tx struct */
	if (tx80211_init(&tx, "mon0", drivertype) < 0) {
		fprintf(stderr, "Error initializing LORCON: %s\n",
				tx80211_geterrstr(&tx));
		exit(1);
	}
	if (tx80211_open(&tx) < 0 ) {
		fprintf(stderr, "Error opening LORCON interface\n");
		exit(1);
	}

	/* Set up rate selection packet */
	tx80211_initpacket(&tx_packet);
}

void caught_signal(int sig)
{
	fprintf(stderr, "Caught signal %d\n", sig);
	exit_program(0);
}

void exit_program(int code)
{
	if (sock != -1)
	{
		close(sock);
		sock = -1;
	}
	exit(code);
}