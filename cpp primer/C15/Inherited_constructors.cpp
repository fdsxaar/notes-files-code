#include <iostream>

class B{
    public:
        B()=default;
        B(int arg):i(arg){
         std::cout << " initialization done!" << std::endl;
}
      // B(const B &b):i(b.i){std::cout<< "B obj copy done!" << std::endl;}

    private:
        int i = 0;
};

class D:public B{
    public:
        D()=default;
        D(int arg):B(arg){}
       // D(const D &d):B(d){std::cout<< "D obj copy done!" << std::endl;}
};

int main(){
    B b_obj(10);
    D d_obj(10);
    D d2_obj = d_obj;
    return 0;
}

