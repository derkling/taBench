
# Check for all warnings and make them become an error
CFLAGS += -Wall -O3
CPPFLAGS = $(CFLASG) -pthread
ifdef TASKAFFINITY
	CPPFLAGS += -DTASKAFFINITY
endif
ifdef FTRACE
	CFLAGS += -DCONFIG_USE_FTRACE
endif
ifndef BSIZE
	BSIZE = 4
endif
CFLAGS += -DBUFFER_SIZE=$(BSIZE)
CPPFLAGS += -DBUFFER_SIZE=$(BSIZE)

B_LDFLAGS += -lrt
B_OBJS += mixer.o wave.o nwBench.o

M_LDFLAGS += -lm -lrt
M_OBJS += monitor.o

VERSION = \"$(shell tools/setlocalversion)\"
CFLAGS += -DCONFIG_CODE_VERSION=$(VERSION)
CPPFLAGS += -DCONFIG_CODE_VERSION=$(VERSION)

BUILD_ALL='\#!/bin/sh\n					\
for S in 2 4 8 16 32 64; do make BSIZE=$$S; done	\
'
all:
	@make soft-clean
	@make nwBench
	@make soft-clean
	@make TASKAFFINITY=1 nwBench-taskaff
	@make monitor
	@make soft-clean
	@make FTRACE=1 monitor-ftrace

all_version:
	echo -e ${BUILD_ALL} > build_all.sh
	chmod a+x build_all.sh
	./build_all.sh

nwBench: $(B_OBJS)
	g++ $(B_LDFLAGS) $(B_OBJS) -o $@_$(BSIZE)KB

nwBench-taskaff: $(B_OBJS)
	g++ $(B_LDFLAGS) $(B_OBJS) -o $@_$(BSIZE)KB

monitor: $(M_OBJS)
	gcc $(M_LDFLAGS) $(M_OBJS) -o $@_$(BSIZE)KB

monitor-ftrace: $(M_OBJS)
	gcc $(M_LDFLAGS) $(M_OBJS) -o $@_$(BSIZE)KB

soft-clean:
	rm -rf *.o *~ cscope.*

clean: soft-clean
	rm -rf nwBench{,-taskaff}_* monitor{,-ftrace}_* build_all.sh

index:
	find `pwd` -regex ".*\.[ch]\(pp\)?" -print > cscope.files
	cscope -b -q -k

%.o : %.c
	gcc $(CFLAGS) -c -o $@ $<

%.o : %.cpp
	g++ $(CPPFLAGS) -c -o $@ $<

