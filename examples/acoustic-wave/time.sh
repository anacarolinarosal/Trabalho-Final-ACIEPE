#!/bin/bash

echo "Execucao das aplicacoes para analise de desempenho"
echo "Sera executado 5 vezes cada aplicacao para ser analizado a media"
echo "  "
echo "  "
echo "----------------------------------------------------------"
echo "*** SEQUENCIAL ***"
echo "Ex1: "
./wave_seq 2000 2000 5000
echo "  "
echo "Ex2: "
./wave_seq 2000 2000 5000
echo "  "
echo "Ex3: "
./wave_seq 2000 2000 5000
echo "  "
echo "Ex4: "
./wave_seq 2000 2000 5000
echo "  "
echo "Ex5: "
./wave_seq 2000 2000 5000
echo "  "
echo "----------------------------------------------------------"
echo "*** PARALELO OPENMP***"
echo "*** 2 THREADS ***"
export OMP_NUM_THREADS=2
echo "Ex1: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex2: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex3: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex4: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex5: "
./wave_parallel 2000 2000 5000
echo "  "
echo "----------------------------------------------------------"
echo "*** PARALELO OPENMP***"
echo "*** 4 THREADS ***"
export OMP_NUM_THREADS=4
echo "Ex1: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex2: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex3: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex4: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex5: "
./wave_parallel 2000 2000 5000
echo "  "
echo "----------------------------------------------------------"
echo "*** PARALELO OPENMP***"
echo "*** 8 THREADS ***"
export OMP_NUM_THREADS=8
echo "Ex1: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex2: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex3: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex4: "
./wave_parallel 2000 2000 5000
echo "  "
echo "Ex5: "
./wave_parallel 2000 2000 5000
echo "  "
