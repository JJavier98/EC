//-----------------------------------------------------------------------------
// suma64s-h.cc
//-----------------------------------------------------------------------------

#include <iostream>  // std::cout std::endl
#include <limits>    // std::numeric_limits
#include <numeric>   // std::accumulate

//-----------------------------------------------------------------------------

long long int suma64s1(int v[], int n)
{
	long long int t = 0;

	while (n--)
		t += *v++;

	return t;
}

//-----------------------------------------------------------------------------

long long int suma64s2(int v[], int n)
{
	long long int t = 0;

	for (int i = 0; i < n; ++i)
		t += v[i];

	return t;
}

//-----------------------------------------------------------------------------

long long int suma64s3(int* primero, int* ultimo)
{
	long long int t = 0;

	while (primero != ultimo)
		t += *primero++;

	return t;
}

//-----------------------------------------------------------------------------

int main(int argc, char* argv[])
{
	const int N = 9;
	int v[N] = {0x1, 0x10, 0x100, 0x1000, 0x10000, 0x100000, 0x1000000, 0x10000000, std::numeric_limits<int>::max()};
	
	std::cout << "suma64u1   = " << suma64s1(v, N) << std::endl;
	std::cout << "suma64u2   = " << suma64s2(v, N) << std::endl;
	std::cout << "suma64u3   = " << suma64s3(v, v + N) << std::endl;
	std::cout << "accumulate = " << std::accumulate(v, v + N, 0ll) << std::endl;
}

//-----------------------------------------------------------------------------


