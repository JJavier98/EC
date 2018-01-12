#include <iostream>

int main()
{
	int lista[] = {1, 2, 10, 1, 2, 0b10, 1, 2, 0x10};
	int resultado = 0;
	
	for (int& i: lista)
		resultado += i;
	
	std::cout << "suma = " << resultado
	          << " / 0x" << std::hex << resultado 
	          << std::endl;
}
