OBJS	= haqnative-linux.o
CC      = gcc
CFLAGS	= -fPIC -I/usr/lib/neko/include
LDFLAGS = -shared -lneko

all: $(OBJS)
	$(CC) $(LDFLAGS) -o ../../../../../library/haqnative-linux.ndll haqnative-linux.o

clean:
	rm -f $(OBJS)
	rm -rf ../../../../../library/haqnative-linux.ndll
