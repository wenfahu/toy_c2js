#include <stdio.h>
#include <string.h>

int pal(char* st)
{	
	int n;
	int i;
	int ret;
	n = strlen(st);
	ret = 1;

	for (i = 0; i < n; i ++)
	{
		if (st[i] != st[n-1-i])
		{
			ret = 0;
		}
		else {
		}
	}

	return ret;
}

int main()
{
	int Para;

	Para = pal("hi");
			
	if (Para == 1)
	{
		puts("True");
	}
	else
	{
		puts("False");
	}
	
	return 0;
}
