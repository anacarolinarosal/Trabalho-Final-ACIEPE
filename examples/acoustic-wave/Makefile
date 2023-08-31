CC=gcc

all: clean wave_parallel wave_seq

wave_parallel:
	$(CC) wave_parallel.c -o wave_parallel -fopenmp

wave_seq:
	$(CC) wave_seq.c -o wave_seq
clean:
	rm -f wave_seq wave_omp wave_mpi wave_pth wave_cuda wave_parallel
