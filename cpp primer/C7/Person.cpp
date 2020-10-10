#include <iostream>
#include <string>

class Person{
    friend int main;
    public:
        Person() = default;
        Person(cosnt std::string &n,const std::string &a):
            name(n),address(a){}
        std::string& ret_name()const {return name; }
        std::string& ret_addr()const {return address;}
    private:
        std::string name;
        std::string address;
}

int main(){
    return 0;
}