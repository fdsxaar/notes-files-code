#include <string>
#include <cstddef>

class HasPtr {
    public:
        HasPtr()=default;
        HasPtr(const std::string &s = std::string()):
            ps(new std::string(s)), i(0), refcnt(new std::size_t(1))
            { }
        HasPtr(const HasPtr&);
        HasPtr& operator=(const HasPtr&);
        ~HasPtr(){
            if(--*refcnt==0){
                delete ps;
                delete refcnt;
            }
            }
        
    private:
        std::string *ps;
        int i;
        std::size_t *refcnt;
};


HasPtr::HasPtr(const HasPtr& rhp) :
    ps(new std::string(*hp.ps)),
    i(hp.i),
    refcnt(rhp.refcnt)
    {
        ++*refcnt;
    }

HasPtr& HasPtr::operator=(const HasPtr& rhp){
        ++*rhp.refcnt;
        if(--*refcnt == 0){
            delete ps;
            delete refcnt;
        }
        ps = rhp.ps;
        i = rhp.i;
        refcnt = rhp.refcnt;
        return *this;
        }

