#include <string.h>
#include <stdio.h>

char chnew[1003];

int checkl(char x)
{
    int p = 0;
    switch(x)
    {
        case '*':
        case '/':
            p = 3;
            break;
        case '+':
        case '-':
            p = 2;
            break;
        case ')':
            p = 1;
            break;
        case '(':
            p = 4;
            break;
        default:
            break;
    }
    return p;
}
int checkr(char x)
{
    int p = 0;
    switch(x)
    {
        case '*':
        case '/':
            p = 3;
            break;
        case '+':
        case '-':
            p = 2;
            break;
        case ')':
            p = 4;
            break;
        case '(':
            p = 1;
            break;
        default:
            break;
    }
    return p;
}
void ChangeToBehind(char* ch)
{
    int len = strlen(ch);
    int num = 0;
    int l = 0;
    int i;
    int j;
    int heaptop = 0;
    char heap[2000];
    chnew[0] = 0;
    heap[0] = '#';
    for (i = 0; i <= len; i++)
    {
        if (ch[i] >= '0' && ch[i] <= '9')
        {
            num++;
        }
        else
        {
            for (j = 0; j < num; j++)
            {
                chnew[l + j] = ch[i - num + j];
            }
            chnew[l + num] = ' ';
            l = l + num + 1;
            num = 0;
            while (checkl(ch[i]) <= checkr(heap[heaptop]))
            {
                if (heaptop == 0)
                {
                    break;
                }
                if (heap[heaptop] != '('){
                    chnew[l] = heap[heaptop];
                    l = l + 1;
                }
                else
                {
                    if (ch[i] == ')')
                    {
                    heaptop--;
                    break;
                    }
                }
                heaptop--;
            }
            heap[++heaptop] = ch[i];
        }
    }
}

float getResult(char* ch)
{
    int len = strlen(ch);
    int heaptop = 0;
    int num = 0;
    int i;
    int flag = 0;
    float sta[1003];
    for (i = 0; i < len; i++)
    {
        if (ch[i] >= '0' && ch[i] <= '9')
        {
            flag = 1;
            num = num * 10 + ch[i] - '0';
        }
        else
        {
            if (flag == 1){
                sta[heaptop] = num;
                heaptop = heaptop + 1;
            }
            num = 0;
            flag = 0;
            switch(ch[i]){
                case '+':
                    heaptop = heaptop - 1;
                    sta[heaptop - 1] = sta[heaptop - 1] + sta[heaptop];
                    break;
                case '-':
                    heaptop = heaptop - 1;
                    sta[heaptop - 1] = sta[heaptop - 1] - sta[heaptop];
                    break;
                case '*':
                    heaptop = heaptop - 1;
                    sta[heaptop - 1] = sta[heaptop - 1] * sta[heaptop];
                    break;
                case '/':
                    heaptop = heaptop - 1;
                    sta[heaptop - 1] = sta[heaptop - 1] / sta[heaptop];
                    break;
                default:
                    break;
            }
        }
    }
    return sta[0];
}
void test(char* ch)
{
    ChangeToBehind(ch);
    printf("%f", getResult(chnew));
}
int main()
{
    test("1+(5-2)*4/(2+1)");
    return 0;
}

