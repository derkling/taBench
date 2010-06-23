/*
 * wave.cpp
 *
 *  Created on: Mar 10, 2009
 *      Author: betzwlin
 */

#include <stdio.h>
#include <errno.h>
#include <strings.h>
#include <sys/prctl.h>

#include "wave.h"
#include "taskaff.h"

void wave::kickoff()
{
    int err;

    err = sem_init(&sem_tid, 0, 0);
    if (err != 0) {
        perror("wave::sem_tid");
    }

    pthread_t thr;
    err = pthread_create(&thr, NULL, start_routine, (void *)this);
    if (err != 0) {
        perror("wave::kickoff");
    }
}

pid_t wave::get_tid()
{
    /* can be called only once, otherwise it will block forever */
    int err = sem_wait(&sem_tid);
    if (err != 0 )
        perror("wave::sem_wait = sem_tid");
    if (!tid)
        fprintf(stderr, "error synchronizing to get tid.\n");

    return tid;
}

void *wave::start_routine(void *_this)
{
    char name[10];
    wave *obj = (wave *)_this;

    obj->tid = gettid();

    int err = sem_post(&obj->sem_tid);
    if (err != 0)
        perror("wave::sem_post - sem_tid");

    sprintf (name, "wave%d", obj->index);
    prctl(PR_SET_NAME, name, 0,0,0);

    obj->loop();
    return NULL;
}

void wave::loop()
{
    t_sint16 sample = 0;

    bzero(buffer, BUFLENBYTE);

    while (1) {
        for (int i = 0; i < (BUFLENWORD-1); i += 2) {
            buffer[i] = sample;
            buffer[i+1] = sample;

            // fprintf(stderr, "+");

            if ((i % width) == 0)
                sample += height;
        }

        // write(1, buffer, BUFLENBYTE);

        my_mixer.emptyBuffer(buffer, pos);
    }
}
