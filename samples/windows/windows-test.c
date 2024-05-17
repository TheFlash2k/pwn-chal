#include <stdio.h>

__attribute__((constructor))
void __constructor__(){
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
}

void gadget() { __asm__("jmp %rsp"); }

void vuln() {
    char buf[0x100];
    printf("buffer @ %p\n", buf);
    gets(buf);
    printf(buf);
}

int main() {
    vuln();
}
