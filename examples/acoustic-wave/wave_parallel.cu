#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <pthread.h>
#include <cuda_runtime.h>

#define DT 0.0070710676f // delta t
#define DX 15.0f // delta x
#define DY 15.0f // delta y
#define V 1500.0f // wave velocity v = 1500 m/s

int iterations;

int rows;
int cols;

float *swap;

float dxSquared;
float dySquared;
float dtSquared;

/*
 * save the matrix on a file.txt
 */
void save_grid(int rows, int cols, float *matrix){

    system("mkdir -p wavefield");

    char file_name[64];
    sprintf(file_name, "wavefield/wavefield_parallel15000.txt");

    // save the result
    FILE *file;
    file = fopen(file_name, "w");

    for(int i = 0; i < rows; i++) {

        int offset = i * cols;

        for(int j = 0; j < cols; j++) {
            fprintf(file, "%f ", matrix[offset + j]);
        }
        fprintf(file, "\n");
    }

    fclose(file);
    
    system("python3 plot_parallel.py");
}


__global__ void *compute_wave(float *prev_base, float *next_base, float *vel_base){

    //thread id
    int id = blockIdx.x;

    // calculate the chunk size
    int chunk = rows / num_threads;

    // calculate begin and end step of the thread
    int begin = id * chunk;
    int end = begin + chunk-1;

    // the last thread must have to end before the border
    if (id == num_threads-1)
        end = cols - 2;

    // the first thread must begin at after the beginning of the border
    if (id == 0)
        begin = begin + 1;

    // wavefield modeling
    for(int n = 0; n < iterations; n++) {
        for(int i = 1; i < rows-1; i++) {
            for(int j = begin ; j <= end; j++) {
                // index of the current point in the grid
                int current = i * cols + j;
                
                //neighbors in the horizontal direction
                float value = (prev_base[current + 1] - 2.0 * prev_base[current] + prev_base[current - 1]) / dxSquared;
                
                //neighbors in the vertical direction
                value += (prev_base[current + cols] - 2.0 * prev_base[current] + prev_base[current - cols]) / dySquared;
                
                value *= dtSquared * vel_base[current];
                
                next_base[current] = 2.0 * prev_base[current] - next_base[current] + value;
            }
        }
    }
}


int main(int argc, char* argv[]) {

    if(argc != 4){
        printf("Usage: ./stencil N1 N2 TIME\n");
        printf("N1 N2: grid sizes for the stencil\n");
        printf("TIME: propagation time in ms\n");
        exit(-1);
    }

    // number of rows of the grid
    rows = atoi(argv[1]);

    // number of columns of the grid
    cols = atoi(argv[2]);

    // number of timesteps
    int time = atoi(argv[3]);
    
    // calc the number of iterations (timesteps)
    iterations = (int)((time/1000.0) / DT);

    // Cuda error
    cudaError_t syncErr, asyncErr;

    // vetores
    float *dev_prev_base;
    float *dev_next_base;
    float *dev_vel_base;

    // alocação de memória na GPU
    cudaMalloc(&dev_prev_base, rows * cols * sizeof(float));
    cudaMalloc(&dev_next_base, rows * cols * sizeof(float));
    cudaMalloc(&dev_vel_base, rows * cols * sizeof(float));

    // alocação de memória na CPU
    float *prev_base = malloc(rows * cols * sizeof(float));
    float *next_base = malloc(rows * cols * sizeof(float));
    float *vel_base = malloc(rows * cols * sizeof(float));

    printf("Grid Sizes: %d x %d\n", rows, cols);
    printf("Iterations: %d\n", iterations);

    // ************* BEGIN INITIALIZATION *************

    printf("Initializing ... \n");

    // define source wavelet
    float wavelet[12] = {0.016387336, -0.041464937, -0.067372555, 0.386110067,
                         0.812723635, 0.416998396,  0.076488599,  -0.059434419,
                         0.023680172, 0.005611435,  0.001823209,  -0.000720549};

    // initialize matrix
    for(int i = 0; i < rows; i++){

        int offset = i * cols;

        for(int j = 0; j < cols; j++){
            prev_base[offset + j] = 0.0f;
            next_base[offset + j] = 0.0f;
            vel_base[offset + j] = V * V;
        }
    }

    // add a source to initial wavefield as an initial condition
    for(int s = 11; s >= 0; s--){
        for(int i = rows / 2 - s; i < rows / 2 + s; i++){

            int offset = i * cols;

            for(int j = cols / 2 - s; j < cols / 2 + s; j++)
                prev_base[offset + j] = wavelet[s];
        }
    }

    // ************** END INITIALIZATION **************

    printf("Computing wavefield ... \n");

    dxSquared = DX * DX;
    dySquared = DY * DY;
    dtSquared = DT * DT;

    // variable to measure execution time
    struct timeval time_start;
    struct timeval time_end;

    // get the start time
    gettimeofday(&time_start, NULL);

    // Copia os arrays prev_base, next_base e vel_base para a GPU
    cudaMemcpy(dev_prev_base, prev_base, rows * cols * sizeof(float), cudaMencpyHostToDevice);
    cudaMemcpy(dev_next_base, next_base, rows * cols * sizeof(float), cudaMencpyHostToDevice);
    cudaMemcpy(dev_vel_base, vel_base, rows * cols * sizeof(float), cudaMencpyHostToDevice);

    // Chamada para função na GPU
    compute_wave<<<rows,1>>>(dev_prev_base,dev_next_base,dev_vel_base);

    // Sincronização de threads
    cudaDeviceSynchronize();

    // Erro
    syncErr = cudaGetLastError();
    asyncErr = cudaDeviceSynchronize();
    if (syncErr != cudaSuccess) printf("Error: %s\n", cudaGetErrorString(syncErr));
    if (asyncErr != cudaSuccess) printf("Error: %s\n", cudaGetErrorString(asyncErr));

    // Copia os arrays da GPU para a CPU
    cudaMemcpy(prev_base, dev_prev_base, rows * cols * sizeof(float), cudaMencpyDeviceToHost);
    cudaMemcpy(next_base, dev_next_base, rows * cols * sizeof(float), cudaMencpyDeviceToHost);
    cudaMemcpy(vel_base, dev_vel_base, rows * cols * sizeof(float), cudaMencpyDeviceToHost);

    // get the end time
    gettimeofday(&time_end, NULL);

    double exec_time = (double) (time_end.tv_sec - time_start.tv_sec) + (double) (time_end.tv_usec - time_start.tv_usec) / 1000000.0;

    save_grid(rows, cols, next_base);

    printf("Iterations completed in %f seconds \n", exec_time);

    cudaFree(dev_prev_base);
    cudaFree(dev_next_base);
    cudaFree(dev_vel_base);

    return 0;
}