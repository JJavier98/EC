#include <iostream>

int a = 7;

int main()
{
  float b = 2.5;
  
  std::cout << "hola" << std::endl;
  asm("cli");
  std::cout << "mundo" << std::endl;
}