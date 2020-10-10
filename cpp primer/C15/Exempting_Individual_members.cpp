#include <cstddef>

class Base {
    public:
        std::size_t size() const { return n; }
    protected:
        std::size_t n;
};

class Derived : private Base { // note: private inheritance
    public:
        // maintain access levels for members related to the size of the object
        using Base::size;
    protected:
        using Base::n;
};