#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

struct timeval startwtime, endwtime;
double seq_time;

__global__ void Ising(int* G, int* L,int n, int threads,int bSize){
  int index = threadIdx.x + blockIdx.x * threads;
  int s = ceil(n/(float) bSize);
  int k = index/s;
  int f = index%s;
      
  for(int i = (k * bSize) ; i < (k+1) * bSize && i < n; i++){
    for(int j = (f * bSize) ; j < (f+1) * bSize && j < n; j++ ){
      int x = G[(i-1+n)%n*n+j] + G[i*n+(j-1+n)%n] + G[i*n+j] + G[(i+1)%n*n+j] + G[i*n+(j+1)%n];
      L[i*n+j] = (x>0) - (x<0);
    }
  }
    
      
}

int main(int argc, char* argv[]){

    int n ,k;
    FILE *fptr;
    srand((unsigned int)time(NULL));

  
    if(argc < 5){
      printf("We need 4 arguments, number of iterations, size, block size and threads per Gpu block");
      return 0;
	  }

    k = (int) strtol(argv[1],NULL,10);
    n = (int) strtol(argv[2],NULL,10);

    int* F = (int*)malloc(n * n * sizeof(int));
    int* L = (int*)malloc(n * n * sizeof(int));

    int *d_F, *d_L;
    cudaMalloc(&d_F, n * n * sizeof(int));
    cudaMalloc(&d_L, n * n * sizeof(int));

    // reads file
    fptr = fopen("input.bin","rb");
    fread(F, sizeof(int), n * n, fptr);
    fclose(fptr);

    cudaMemcpy(d_F, F, n * n * sizeof(int), cudaMemcpyHostToDevice);

    

    int bSize = (int) strtol(argv[3],NULL,10);
    int threadsPerBlock = (int) strtol(argv[4],NULL,10);
    int s = ceil(n/(float) bSize);
    int blocks = ceil((s * s)/(float)threadsPerBlock);
    printf("blocks %d\n", blocks);
    int threads =  ceil((s * s)/(float)blocks);
    printf("threads %d\n", threads);
    
   gettimeofday (&startwtime, NULL);
    
    for(int i = 0; i < k ; i++ ){
        Ising<<<blocks,threads>>>(d_F,d_L,n,threads,bSize);
        int* temp = d_F;
        d_F = d_L;
        d_L = temp;
        cudaDeviceSynchronize();
    }

    cudaDeviceSynchronize();
    gettimeofday (&endwtime, NULL);
		seq_time = (double)((endwtime.tv_usec - startwtime.tv_usec)/1.0e6 + endwtime.tv_sec - startwtime.tv_sec);
    printf("\n\n-=-=-=-=-=-=-=-+++total time %f+++-=-=-=-=-=-=-=-=-=-\n\n",seq_time);

    cudaMemcpy(F, d_F, n * n * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(L, d_L, n * n * sizeof(int), cudaMemcpyDeviceToHost);


    int* checker = (int*)malloc(n * n * sizeof(int));
    fptr = fopen("output.bin","rb");
    fread(checker, sizeof(int), n * n, fptr);
    fclose(fptr);

    int allOk = 0;

    for(int i = 0 ; i < n ; i++){
      for(int k = 0 ; k < n ; k++){
        if(checker[i*n + k] != F[i*n + k]){
          allOk++;
        }
      }
    }

    if(allOk){
      printf("Something went wrong %d times\n",allOk);
    }
    else{
      printf("Everything is correct\n");
    }


    // Free everything
    free(L);
    free(F);
    cudaFree(d_F);
    cudaFree(d_L);

}
