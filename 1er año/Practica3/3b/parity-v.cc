//------------------------------------------------------------------------------
// parity-v.cc
//------------------------------------------------------------------------------

#include <x86intrin.h> // __rdtscp

#include <algorithm>   // generate
#include <array>       // array
#include <bitset>      // bitset
#include <chrono>      // now
#include <functional>  // bind
#include <iomanip>     // setw
#include <iostream>    // cout endl
#include <random>      // uniform_int_distribution

//------------------------------------------------------------------------------

const unsigned GAP = 12;            // gap between columns
const unsigned REP = 100;           // how many times we repeat the experiment

//------------------------------------------------------------------------------

std::array<unsigned, 1 << 16> list; // 64K x 4B = 256KB

//------------------------------------------------------------------------------

unsigned parity00(unsigned *begin, unsigned *end) // true on even parity
{
	unsigned count = 0;
	while (begin != end)
		count += *begin++ & 0x1;
	return count;
}

//------------------------------------------------------------------------------

unsigned parity01(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned even = 1;
		unsigned elem = *begin++;
		for (unsigned i = 0; i < 8 * sizeof(decltype(elem)); ++i)
		{
			unsigned mask = 0x1 << i;
			even ^= (elem & mask) != 0;
		}
		count += even;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity02(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned even = 1;
		unsigned elem = *begin++;
		while (elem)
		{
			even ^= elem & 0x1;
			elem >>= 1;
		}
		count += even;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity03(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned even = 1;
		unsigned elem = *begin++;
		do {
			even ^= elem;
		} while (elem >>= 1);
		count += even & 0x1;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity04(unsigned *begin, unsigned *end) // like 3 with an extra "test"
{
	unsigned count = 0;
	return count;
}

//------------------------------------------------------------------------------

unsigned parity05(unsigned *begin, unsigned *end) // like 3 without the extra "test"
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity06(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity07(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned even, elem = *begin++;
		count += even;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity08(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned char lt8[256];

unsigned parity09(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned char lt16[65536];

unsigned parity10(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity11(unsigned *begin, unsigned *end) // Hacker's Delight
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity12(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

unsigned parity13(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

//unsigned parity14(unsigned *begin, unsigned *end)
//{
//	if (elem == 0)
//		return 1;
//	else
//		return (elem & 1) ^ parity14(elem >> 1);
//}

//------------------------------------------------------------------------------

std::bitset<1<<16> lt16v2;

unsigned parity15(unsigned *begin, unsigned *end)
{
	unsigned count = 0;
	while (begin != end)
	{
		unsigned elem = *begin++;
	}
	return count;
}

//------------------------------------------------------------------------------

template <class _F> void test (_F& __f, const char* msg)
{
	using namespace std::chrono;

	unsigned id; // needed by __rdtscp()

	unsigned long long cycle_overhead = std::numeric_limits<unsigned long long>::max();

	for (unsigned i = 0; i < REP; ++i)
	{
		unsigned long long t1 = __rdtscp(&id);
		unsigned long long t2 = __rdtscp(&id);
		cycle_overhead = std::min(cycle_overhead, t2 - t1);
	}

	unsigned long long cycles = std::numeric_limits<unsigned long long>::max();

	for (unsigned i = 0; i < REP; ++i)
	{
		unsigned long long t1 = __rdtscp(&id);
		__f(list.begin(), list.end());
		unsigned long long t2 = __rdtscp(&id);
		cycles = std::min(cycles, t2 - t1);
	}
	cycles -= cycle_overhead;

	auto time_overhead = duration<high_resolution_clock::rep, std::nano>::max();

	for (unsigned i = 0; i < REP; ++i)
	{
		auto t1 = high_resolution_clock::now();
		auto t2 = high_resolution_clock::now();
		time_overhead = std::min(time_overhead, t2 - t1);
	}

	unsigned result;
	auto time = duration<high_resolution_clock::rep, std::nano>::max();

	for (unsigned i = 0; i < REP; ++i)
	{
		result = 0;
		auto t1 = high_resolution_clock::now();
		result = __f(list.begin(), list.end());
		auto t2 = high_resolution_clock::now();
		time = std::min(time, t2 - t1);
	}
	time -= time_overhead;

	std::cout << '"' << std::setw(GAP * 2 - 2) << msg << '"'
	          << std::setw(GAP) << result
	          << std::setw(GAP) << std::fixed << std::setprecision(2)
	          << cycles / static_cast<double>(list.size())
	          << std::setw(GAP) << std::fixed << std::setprecision(2)
	          << time.count() / static_cast<double>(list.size())
	          << std::setw(GAP) << std::fixed << std::setprecision(2)
	          << time.count() / 1000.0
	          << std::endl;
}

//------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
	std::default_random_engine engine;
	std::uniform_int_distribution<unsigned> distribution;
	auto generator = std::bind(distribution, engine);

	std::generate(list.begin(), list.end(), generator);

	for (unsigned i = 0; i < 256; ++i)
		lt8[i] = (__builtin_popcount(i) & 0x1) == 0;

	for (unsigned i = 0; i < 65536; ++i)
		lt16[i] = (__builtin_popcount(i) & 0x1) == 0;

	for (unsigned i = 0; i < 65536; ++i)
		lt16v2[i] = (__builtin_popcount(i) & 0x1) == 0;

	std::cout << "#" << std::setw(GAP * 2 - 1) << "parity"
	        << std::setw(GAP) << "value"
	        << std::setw(GAP) << "cycles"
	        << std::setw(GAP) << "time(ns)"
	        << std::setw(GAP) << "total(us)"
	        << std::endl;

	test(parity00, "parity00(empty)");
	test(parity01, "parity01(for)");
	test(parity02, "parity02(while)");
	test(parity03, "parity03(do while)");
	test(parity04, "parity04(asm)");
	test(parity05, "parity05(asm v2)");
	test(parity06, "parity06(tree)");
	test(parity07, "parity07(tree v2)");
	test(parity08, "parity08(asm v3)");
	test(parity09, "parity09(lt8)");
	test(parity10, "parity10(lt16)");
	test(parity11, "parity11(HD)");
	test(parity12, "parity12(builtin)");
	test(parity13, "parity13(bitset)");
//	test(parity14, "parity14(recursive)");
	test(parity15, "parity15(lt16 v2)");
}

//------------------------------------------------------------------------------
