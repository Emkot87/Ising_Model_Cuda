#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

struct timeval startwtime, endwtime;
double seq_time;


int Sign(float x){
    int s = 0;
    s = (x>0) - (x<0);
    return s;
}


void Ising(int* G, int* L,int n){
    for(int i = 0 ; i < n ; i++){
        for(int j = 0 ; j < n ; j++){
            L[i*n+j] = Sign(G[((i-1+n)%n)*n + j] + G[i*n + (j-1+n)%n] + G[i*n + j] + G[((i+1)%n)*n + j] + G[i*n + (j+1)%n]);
        }
    }
}


void init ( int* F, int L) {
  int i,j;
  for (i=0;i<L;i++) {
    for (j=0;j<L;j++) {
      F[i*L+j]=2*(rand()%2) - 1;
    }
  }
}


int main(int argc, char* argv[]){

    int n ,k;
    FILE *fptr;
    srand((unsigned int)time(NULL));

    // read num of iterations and size
    if(argc < 3){
		printf("We need 2 arguments, number of iterations and size");
		return 0;
	}

    k = (int) strtol(argv[1],NULL,10);
    n = (int) strtol(argv[2],NULL,10);

    int* F = (int*)malloc(n * n * sizeof(int));
    int* L = (int*)malloc(n * n * sizeof(int));

    // random 1 and -1
    init(F,n);

    fptr = fopen("input.bin","wb+");
    fwrite(F, n*n,sizeof(int),fptr);
    fclose(fptr);

    gettimeofday (&startwtime, NULL);

    for(int i = 0; i < k ; i++ ){
        Ising(F,L,n);
        int* temp = F;
        F = L;
        L = temp;
    }

    gettimeofday (&endwtime, NULL);
	seq_time = (double)((endwtime.tv_usec - startwtime.tv_usec)/1.0e6 + endwtime.tv_sec - startwtime.tv_sec);
    printf("\n\n-=-=-=-=-=-=-=-+++total time %f+++-=-=-=-=-=-=-=-=-=-\n\n",seq_time);


    fptr = fopen("output.bin","wb+");
    fwrite(F,n*n,sizeof(int),fptr);
    fclose(fptr);


    // Free everything
    free(L);
    free(F);

}
