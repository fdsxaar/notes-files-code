#include <string>
#include <cstddef>

class HasPtr {
    friend void swap(HasPtr&, HasPtr&);
    public:
        HasPtr()=default;
        HasPtr(const std::string &s = std::string()):
            ps(new std::string(s)), i(0)
            { }
        HasPtr(const HasPtr&);
        HasPtr& operator=(const HasPtr&);
        HasPtr& operator=(HasPtr);
        HasPtr(HasPtr&& rhp)noexcept:ps(rhp.ps),i(rhp.i){rhp.ps = nullptr;}
        HasPtr& operator=(HasPtr &&rhp)noexcept{
            ps = rhp.ps;
            i = rhp.i;
            rhp.ps = nullptr;
        }
        ~HasPtr(){delete ps;}
        
    private:
        std::string *ps;
        int i;
};


HasPtr::HasPtr(const HasPtr &rhp) :
    ps(new std::string(*hp.ps)),
    i(hp.i),
    {
    }

HasPtr& HasPtr::operator=(HasPtr &rhp){
    ps = new std::string(*hp.ps);
    i = rhp.i;
    return *this;
}

HasPtr& HasPtr::operator=( HasPtr rhp){
        swap(*this, rhp);
        return *this;
        }

void swap(HasPtr &lhp, HasPtr rhp){
    using std::swap;
    swap(lhp.ps, rhp.ps);
    swap(lhp.i,rhp.i);
}