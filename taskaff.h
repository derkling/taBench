#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif
#include <unistd.h>
#include <sys/syscall.h>

#define gettid() syscall(SYS_gettid)

#ifdef __x86_64__
# define __NR_sched_add_taskaffinity 300
# define sched_add_taskaffinity(tsk) \
       syscall(__NR_sched_add_taskaffinity, tsk)

# define __NR_sched_del_taskaffinity 301
# define sched_del_taskaffinity(tsk) \
       syscall(__NR_sched_del_taskaffinity, tsk)
#elif __i386__
# define __NR_sched_add_taskaffinity 338
# define sched_add_taskaffinity(tsk) \
	syscall(__NR_sched_add_taskaffinity, tsk)

# define __NR_sched_del_taskaffinity 339
# define sched_del_taskaffinity(tsk) \
	syscall(__NR_sched_del_taskaffinity, tsk)
#endif
