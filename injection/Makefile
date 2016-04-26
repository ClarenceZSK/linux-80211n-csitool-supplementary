CFLAGS = -O3 -Wall -static -Wno-unknown-pragmas
LDLIBS = -lorcon -lm -lrt
CC = gcc

all: random_packets send_packets server_multi

random_packets : random_packets.c util.c
	gcc -o random_packets random_packets.c util.c -O3 -Wall -static -Wno-unknown-pragmas  -lorcon -lm -lrt
send_packets : send_packets.c util.c
	gcc -o send_packets send_packets.c util.c -O3 -Wall -static -Wno-unknown-pragmas  -lorcon -lm -lrt
server_multi : server_multi.c 
	gcc -o server_multi server_multi.c -lpthread
clean:
	rm -f *.o random_packets send_packets server_multi
