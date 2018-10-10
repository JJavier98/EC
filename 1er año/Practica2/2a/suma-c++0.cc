#include <iostream>

int main()
{
	int N = 9;
	int lista[N] = {1, 2, 10, 1, 2, 0b10, 1, 2, 0x10};
	int resultado = 0;
	
	for (int i = 0; i < N; ++i)
		resultado += lista[i];
	
	std::cout << "suma = " << resultado
	          << " / 0x" << std::hex << resultado 
	          << std::endl;
}
