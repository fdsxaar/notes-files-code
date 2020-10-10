#include <cstddef>
#include <memory> 
#include <utility> //pair

// simplified implementation of the memory allocation strategy for a vector-like class
template <typename T> class Vec {
    public:
        Vec(): // the allocator member is default initialized
            elements(nullptr), first_free(nullptr), cap(nullptr) {}
        Vec(const Vec&); // copy constructor
        Vec &operator=(const Vec&); // copy assignment
        Vec(Vec &&) noexcept；
        Vec& operator = (Vec &&) noexcept;
        ~Vec(); // destructor
        void push_back(const T &); // copy the element
        void push_back(T &&);
        Vec& operator=(std::initializer_list<T>);
        T& operator[](std::size_t n) const 
            {return elements[n];}
        const T& operator[](std::size_t n){
            return elements[n];
        }
        size_t size() const { return first_free - elements; }
        size_t capacity() const { return cap - elements; }
        T *begin() const { return elements; }
        T *end() const { return first_free; }

    private:
        std::allocator<T> alloc; // allocates the elements
        // used by the functions that add elements to the StrVec
        void chk_n_alloc()
            { 
                if (size() == capacity()) 
                    reallocate();
            }
        // utilities used by the copy constructor, assignment operator, and destructor
        std::pair<T*, T*> alloc_n_copy
            (const T*, const T*);
        void free(); // destroy the elements and free the space
        void reallocate(); // get more space and copy the existing elements
        T *elements; // pointer to the first element in the array
        T *first_free; // pointer to the first free element in the array
        T *cap; // pointer to one past the end of the array
};

template <typename T>
void Vec<T>::push_back(const T& t)
{
    chk_n_alloc(); // ensure that there is room for another element
    // construct a copy of s in the element to which first_free points
    alloc.construct(first_free++, t);
}

template <typename T>
void Vec<T>::push_back(T &&t){
    chk_n_alloc();
    alloc.construct(first_free++, std::move(t));
}

template <typename T>
std::pair<T*, T*>
Vec<T>::alloc_n_copy(const T *b, const T *e)
{
    // allocate space to hold as many elements as are in the range
    auto data = alloc.allocate(e - b);
    // initialize and return a pair constructed from data and
    // the value returned by uninitialized_copy
    return {data, std::uninitialized_copy(b, e, data)};
}

tempalte <typename T>
void Vec<T>::free()
{
    // may not pass deallocate a 0 pointer; if elements is 0, there's no work to do
    if (elements) {
    // destroy the old elements in reverse order
        for (auto p = first_free; p != elements; /* empty */)
            alloc.destroy(--p);
            alloc.deallocate(elements, cap - elements);
    }
}

tempalte <typename T>
Vec<T>::Vec(const Vec &s)
{
    // call alloc_n_copy to allocate exactly as many elements as in s
    auto newdata = alloc_n_copy(s.begin(), s.end());
    elements = newdata.first;
    first_free = cap = newdata.second;
}

tempalte <typename T>
Vec<T>::~Vec() { free(); }

tempalte <typename T>
Vec<T> &Vec<T>::operator=(const Vec &rhs)
{
    // call alloc_n_copy to allocate exactly as many elements as in rhs
    auto data = alloc_n_copy(rhs.begin(), rhs.end());
    free();
    elements = data.first;
    first_free = cap = data.second;
    return *this;
}

tempalte <typename T>
void Vec<T>::reallocate()
{
    // we'll allocate space for twice as many elements as the current size
    auto newcapacity = size() ? 2 * size() : 1;
    // allocate new memory
    auto first = alloc.allocate(newcapacity);
    auto last = std::uninitialized_copy(std::make_move_iterator(begin(),
                std::make_move_iterator(end()),first);
    free(); // free the old space once we've moved the elements
    // update our data structure to point to the new elements
    elements = first;
    first_free = last;
    cap = elements + newcapacity;
}

tempalte <typename T>
Vec<T>::Vec(Vec&& sv) noexcept : 
    elements(sv.elements), first_free(sv.first_free), cap(sv.cap)
    {
        sv.elements = sv.first_free = sv.cap = nullptr;
    }

tempalte <typename T>
Vec& Vec::operator=(Vec&& sv) noexcept
{
    if(this != &sv){
        free();
        elements = sv.elements;
        first_free = sv.first_free;
        cap = sv.cap;
        sv.elements = sv.first_free = sv.cap = nullptr;
    }
    return *this;
}

tempalte <typename T>
Vec<T>& Vec<T>::operator=(std::initializer_list<T> lst){
    auto data = alloc_n_copy(lst.begin(),lst.end());
    free();
    elements = data.first;
    first_free = cap = data.second;
    return *this;
}
