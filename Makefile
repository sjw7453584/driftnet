#
# Makefile:
# Makefile for driftnet.
#
# Copyright (c) 2001 Chris Lightfoot. All rights reserved.
# Email: chris@ex-parrot.com; WWW: http://www.ex-parrot.com/~chris/
#
# $Id: Makefile,v 1.38 2003/10/16 11:56:47 chris Exp $
#

#
# User-serviceable parts:
#

# Compiler to use.
#CC = gcc

# Basic compiler, linker flags; should not need any changes.
CFLAGS += -g -Wall
LDFLAGS += -g

# You might need these if libpcap is installed somewhere random.
CFLAGS += -I/usr/include/pcap
#LDFLAGS += -L/path/to/libpcap.so

# Required on Linux to get BSDish definitions of the TCP/IP structs.
CFLAGS += -D_BSD_SOURCE

# We always need the pcap and pthread libraries.
LDLIBS += -lpcap -lpthread #-lefence

# Optional C compiler and linker flags. Typical driftnet builds have support
# for displaying captured images in an X window, and need the following flags:
CFLAGS  += `gtk-config --cflags`
LDLIBS  += -ljpeg -lungif -lpng `gtk-config --libs`

# Alternatively, you can build a version of driftnet which can only be used
# in `adjunct' mode as the back end for some other image-processing program. To
# use this, comment out the two preceding CFLAGS and LDLIBS lines and uncomment
# the following line:
#CFLAGS += -DNO_DISPLAY_WINDOW

# On systems with a C99 compiler, driftnet will use <stdint.h> for the
# definitions of types such as uint8_t. On other systems like Solaris, these
# are in <sys/types.h>, and you should uncomment this line.
#CFLAGS += -DUSE_SYS_TYPES_H

# On Solaris, it is necessary to link against -lposix4 for the definition of
# nanosleep; uncomment the below.
#LDLIBS  += -lposix4

# On BSD systems, may need to use /usr/local/include
#CFLAGS += -I/usr/local/include


#
# No user-serviceable parts below this point.
#

# Driftnet version.
VERSION = 0.1.6
CFLAGS += -DDRIFTNET_VERSION='"$(VERSION)"'

SUBDIRS = 

TXTS = README TODO COPYING CHANGES CREDITS driftnet.1 driftnet.1.in endian.c
SRCS = audio.c mpeghdr.c gif.c img.c jpeg.c png.c driftnet.c image.c \
       display.c playaudio.c connection.c media.c util.c http.c
HDRS = img.h driftnet.h mpeghdr.h
BINS = driftnet

OBJS = $(SRCS:.c=.o)

default: driftnet driftnet.1

driftnet:   depend $(OBJS)
	$(CC) -o driftnet $(OBJS) $(LDFLAGS) $(LDLIBS)

driftnet.1: driftnet.1.in Makefile
	( echo '.\" DO NOT EDIT THIS FILE-- edit driftnet.1.in instead' ; sed s/@@@VERSION@@@/$(VERSION)/ ) < driftnet.1.in > driftnet.1

endianness: endian
	./endian > endianness

endian: endian.c
	$(CC) $(CFLAGS) -o endian endian.c

%.o:    %.c Makefile endianness
	$(CC) $(CFLAGS) `cat endianness` -c -o $@ $<

clean:  nodepend
	rm -f *~ *.bak *.o core $(BINS) TAGS driftnet.1 endian endianness

tags:
	etags *.c *.h

tarball: nodepend $(SRCS) $(HDRS) $(TXTS)
	mkdir driftnet-$(VERSION)
	set -e ; for i in Makefile $(SRCS) $(HDRS) $(TXTS) ; do cp $$i driftnet-$(VERSION)/$$i ; done
	tar cvzf driftnet-$(VERSION).tar.gz driftnet-$(VERSION)
	rm -rf driftnet-$(VERSION)
	mv driftnet-$(VERSION).tar.gz ..
	
depend: endianness
	makedepend -- $(CFLAGS) `cat endianness` -- $(SRCS)
	touch depend
	rm -f Makefile.bak

nodepend:
	makedepend -- --
	rm -f depend Makefile.bak

# DO NOT DELETE
