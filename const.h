#ifndef __CONST_IDT
#define __CONST_IDT

/* betzw: must be a multiple of 2 because of stereo PCM audio data */
#define BUFLENWORD (BUFFER_SIZE*1024)
#define BUFLENBYTE (2*BUFLENWORD)

#endif // __CONST_IDT
