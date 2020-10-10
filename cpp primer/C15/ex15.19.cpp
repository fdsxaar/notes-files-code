
class Base {
public:
    void pub_mem(); // public member
protected:
    int prot_mem; // protected member
private:
    char priv_mem; // private member
};

struct Pub_Derv : public Base {
// ok: derived classes can access protected members
    int f() { return prot_mem; }
// error: private members are inaccessible to derived classes
   // char g() { return priv_mem; }
};

struct Derived_from_Public : public Pub_Derv {
// ok: Base::prot_mem remains protected in Pub_Derv
    int use_base() { return prot_mem; }
    void memfcn(Base &b) { b = *this; }
};

int main(){
    return 0;
}