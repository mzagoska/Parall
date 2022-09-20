
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdlib.h>

//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU//GPU

#include <stdio.h>
#include <time.h>

#define SIZE	16

__global__ void Square(int* a, int* c, int n) //Добавляем __global__ чтобы функция выполнялась на GPU(многопоточно)
{
	int i = threadIdx.x; //Задаем как поточную переменную
	if (i < n) //Проверка наличия памяти для записи переменной
		c[i] = a[i] * a[i];
}

void SquareCPU(int* a, int* c, int n)
{
	int i;

	for (i = 0; i < n; ++i)
		c[i] = a[i] * a[i];
}

int main()
{
	float elapsedTime;
	clock_t start = clock();

	int* a, * c;	//Инициализация переменных
	int* d_a, * d_c;

	a = (int*)malloc(SIZE * sizeof(int));
	c = (int*)malloc(SIZE * sizeof(int));

	cudaMalloc(&d_a, SIZE * sizeof(int)); //Выделение памяти на переменную
	cudaMalloc(&d_c, SIZE * sizeof(int));

	for (int i = 0; i < SIZE; ++i)
	{
		a[i] = i;
		c[i] = 0;
	}

	cudaMemcpy(d_a, a, SIZE * sizeof(int), cudaMemcpyHostToDevice); //Копируем данные в GPU из CPU
	cudaMemcpy(d_c, c, SIZE * sizeof(int), cudaMemcpyHostToDevice);

	Square <<< 1, SIZE >> > (d_a, d_c, SIZE); //Вызов функции со специальной конфигурацией( <<< *кол-во блоков*, *величина блока*>>>...)

	cudaMemcpy(c, d_c, SIZE * sizeof(int), cudaMemcpyDeviceToHost); //Копируем данные обратно из GPU в CPU для вывода


	for (int i = 0; i < SIZE; ++i)
		printf("c[%d] = %d\n", i, c[i]);

	free(a);
	free(c);

	cudaFree(d_a);
	cudaFree(d_c); //Освобождаем память

	elapsedTime = ((double)clock() - start) / CLOCKS_PER_SEC; // Подсчет времени
	printf("GPU time elapsed: %f seconds \n", elapsedTime);

	//---------------------------------------------------------------------------------------------------------------------
	float elapsedTimeCPU;
	clock_t startCPU = clock();

	int* a1, * c1;
	a1 = (int*)malloc(SIZE * sizeof(int));
	c1 = (int*)malloc(SIZE * sizeof(int));

	for (int i = 0; i < SIZE; ++i)
	{
		a1[i] = i;
		c1[i] = 0;
	}

	SquareCPU(a1, c1, SIZE);

	for (int i = 0; i < SIZE; ++i)
		printf("c[%d] = %d\n", i, c1[i]);

	free(a1);
	free(c1);

	elapsedTimeCPU = ((double)clock() - startCPU) / CLOCKS_PER_SEC;
	printf("CPU time elapsed: %f seconds \n", elapsedTimeCPU);

	return 0;
}