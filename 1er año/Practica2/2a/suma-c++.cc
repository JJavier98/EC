#include <numeric>
#include <iostream>

int main()
{
	int N = 9;
	int lista[N] = {1, 2, 10, 1, 2, 0b10, 1, 2, 0x10};
	int resultado = std::accumulate(lista, lista + N, 0);
	
	std::cout << "suma = " << resultado
	          << " / 0x" << std::hex << resultado 
	          << std::endl;
}
