#include <string>
#include <iostream>

class Base{
    // friend int main();
    public:
        int j = 53;
    protected:
        int i=42;
};

class Der:public Base{
   // friend int main();
    public:
       int mem(){return i+j;}
};

int main(){
    Der D;
    std::cout << "Der obj access: " << D.i << "\n" << std::endl;
    // std::cout << " Der obj mem access: " << D.mem()<< "\n" << std::endl;
    // std::cout << D.mem() <<std::endl;
   return 0;
}