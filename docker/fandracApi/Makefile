CC=gcc
CFLAGS=-Wall
LDFLAGS=-ljson-c
EXEC=fandracApi

all: $(EXEC)

fandracApi: fandracApi.o
	$(CC) -o fandracApi fandracApi.o $(LDFLAGS)

fandracApi.o: fandracApi.c
	$(CC) -o fandracApi.o -c fandracApi.c $(CFLAGS)

clean:
	rm -rf *.o

mrproper: clean
	rm -rf $(EXEC)