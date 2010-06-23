
# Check for all warnings and make them become an error
CFLAGS += -Wall -O3
CPPFLAGS = $(CFLASG) -pthread
ifdef TASKAFFINITY
	CPPFLAGS += -DTASKAFFINITY
endif
ifdef FTRACE
	CFLAGS += -DCONFIG_USE_FTRACE
endif

B_LDFLAGS += -lrt
B_OBJS += mixer.o wave.o nwBench.o

M_LDFLAGS += -lm -lrt
M_OBJS += monitor.o

VERSION = \"$(shell tools/setlocalversion)\"
CFLAGS += -DCONFIG_CODE_VERSION=$(VERSION)
CPPFLAGS += -DCONFIG_CODE_VERSION=$(VERSION)

all:
	@make nwBench
	@make soft-clean
	@make TASKAFFINITY=1 nwBench-taskaff
	@make monitor
	@make soft-clean
	@make FTRACE=1 monitor-ftrace

nwBench: $(B_OBJS)
	g++ $(B_LDFLAGS) $(B_OBJS) -o $@

nwBench-taskaff: $(B_OBJS)
	g++ $(B_LDFLAGS) $(B_OBJS) -o $@

monitor: $(M_OBJS)
	gcc $(M_LDFLAGS) $(M_OBJS) -o $@

monitor-ftrace: $(M_OBJS)
	gcc $(M_LDFLAGS) $(M_OBJS) -o $@

soft-clean:
	rm -rf *.o *~ cscope.*

clean: soft-clean
	rm -rf nwBench{,-taskaff} monitor{,-ftrace}

index:
	find `pwd` -regex ".*\.[ch]\(pp\)?" -print > cscope.files
	cscope -b -q -k

%.o : %.c
	gcc $(CFLAGS) -c -o $@ $<

%.o : %.cpp
	g++ $(CPPFLAGS) -c -o $@ $<

