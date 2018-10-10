template <class T> concept bool Addable = requires (T t) { t + t; };

template <Addable T> T add (T a, T b) { return a + b; }

int main()
{
	int x = 1, y = 2;
	Addable a = x + y;
	return a;
}
