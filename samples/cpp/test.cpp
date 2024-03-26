#include <iostream>

__attribute__((constructor))
void __constructor__(){
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
}

int main() {
    int a, b;
    std::cerr << "Something to test stderr against too." << std::endl;
    std::cout << "Enter two numbers: ";
    std::cin >> a >> b;
    std::cout << "a=" << a << " b=" << b << " sum=" << a+b << std::endl;
    
    system("cat flag.txt");
    exit(0);
}
