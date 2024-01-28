CC=nvcc

CFLAGS += -O3

default: all
all: V0 V1 V2 V3

V0: V0.c
	gcc -o $@ $^ 

V1: V1.cu
	 $(CC) -o $@ $^ 
	 
V2: V2.cu
	 $(CC) -o $@ $^ 
	 
V3: V3.cu
	 $(CC) -o $@ $^ 
