//------------------------------------------------------------------------------
// suma_09_v2.cc
//------------------------------------------------------------------------------

#include <algorithm> // max_element min_element
#include <chrono>    // duration_cast high_resolution_clock microseconds
#include <iomanip>   // setw
#include <iostream>  // cout endl
#include <numeric>   // accumulate iota

//------------------------------------------------------------------------------

const int N = 1 << 16, REP = 9999;

int lista[N];

//------------------------------------------------------------------------------

int suma1(int* array, int len)
{
	int res = 0;
	for (int i = 0; i < len; i++)
		res += array[i];
	return res;
}

//------------------------------------------------------------------------------

int suma2(int* array, int len)
{
	int i, res = 0;
	for (i = 0; i < len; i++)
	asm("add (%[a],%[i],4),%[r]	\n" // code
	     : [r] "+r" (res)           // output-input
	     : [i] "r"  (i),            // input
	       [a] "r"  (array)         // clobber
	   );
	return res;
}

//------------------------------------------------------------------------------

int suma3(int* array, int len)
{
	asm("    mov 8(%%ebp), %%ebx        \n"  // array
	    "    mov 12(%%ebp), %%ecx       \n"  // len
	    "                               \n"
	    "    mov $0, %%eax              \n"  // retval
	    "    mov $0, %%edx              \n"  // index
	    ".bucle:                        \n"
	    "    add (%%ebx,%%edx,4), %%eax \n"
	    "    inc %%edx                  \n"
	    "    cmp %%edx,%%ecx            \n"
	    "    jne .bucle                 \n"
	    :                                // output
	    :                                // input
	    : "ebx"                          // clobber
	);
}

//------------------------------------------------------------------------------

int suma4(int* array, int len)
{
	return std::accumulate(array, array + len, 0);
}

//------------------------------------------------------------------------------

int suma5(int* array, int len)
{
	int res = 0;
	int *end = array + len;
	while(array != end)
		res += *array++;
	return res;
}

//------------------------------------------------------------------------------

template <class F> void test(F& f, const char* msg)
{
	using namespace std::chrono;

	double t[REP];
	int resultado;

	for (auto& i: t)
	{
		resultado = 0;
		auto start = high_resolution_clock::now();
		resultado += f(lista, N);
		auto stop  = high_resolution_clock::now();
		i = duration_cast<nanoseconds>(stop - start).count() / 1000.0;
	}

	std::nth_element(t, t + REP / 2, t + REP); // for median

	std::cout << std::setw(28) << msg
	          << std::setw(15) << resultado
	          << std::setw(8) << std::fixed << std::setprecision(2)
	          << *std::min_element(t, t + REP) << "us"
	          << std::setw(10) << std::fixed << std::setprecision(2)
	          << t[REP / 2] << "us"
	          << std::setw(8) << std::fixed << std::setprecision(2)
	          << *std::max_element(t, t + REP) << "us"
	          << std::endl;
}

//------------------------------------------------------------------------------

int main()
{
	std::iota(lista, lista + N, 0);

	std::cout << std::setw(28) << "version"
	          << std::setw(15) << "resultado"
	          << std::setw(10) << "min"
	          << std::setw(12) << "median"
	          << std::setw(10) << "max" << std::endl
	          << std::string(75, '-') << std::endl;

	test(suma1, "suma1 (C for         )");
	test(suma2, "suma2 (asm corto     )");
	test(suma3, "suma3 (asm todo      )");
	test(suma4, "suma4 (C++ accumulate)");
	test(suma5, "suma5 (C while       )");
}

//------------------------------------------------------------------------------
