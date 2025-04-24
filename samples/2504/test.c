#include <stdio.h>

__attribute__((constructor))
void __constructor__(){
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
}

int main() {
    int a, b;
    fprintf(stderr, "Something to test stderr against too.\n");
    printf("Enter two numbers: ");
    scanf("%d %d", &a, &b);
    printf("a=%d b=%d sum=%d\n", a, b, a+b);

    system("/bin/bash");
    exit(0);
}
