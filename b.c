#include <stdio.h>
#include <string.h>

#define N 100000

char text[N];
char pattern[N];
int next[N];

int main()
{
	gets(text);
	gets(pattern);
	
	int n = strlen(text);
	int m = strlen(pattern);
	
	int i, p = -1, ans = 0;
	
	next[0] = -1;
	for (i = 1; i < m; i ++)
	{
		while (p != -1 && pattern[i] != pattern[p+1])
			p = next[p];
		if (pattern[i] == pattern[p+1])
			p ++;
		next[i] = p;
	}

	p = -1;		
	for (i = 0; i < n; i ++)
	{
		while (p != -1 && text[i] != pattern[p+1])
			p = next[p];
		if (text[i] == pattern[p+1])
			p ++;
		if (p == m-1)	//match
		{
			ans ++;
			printf("%d ", i - p + 1);
			p = next[p];
		}
	}
	
	if (ans == 0)
		puts("False");
		
	scanf("%d", &i);
	
	return 0;
}
