#include <iostream>
#include <string>

class Sales_data {
    friend Sales_data add(const Sales_data&, const Sales_data&);
    friend std::istream &read(std::istream&, Sales_data&);
    friend std::ostream &print(std::ostream&, const Sales_data&);
    friend std::ostream& operator<<(std::ostream&,const Sales_data&);
    friend std::istream& operator>>(std::istream&,Sales_data&);
    friend Sales_data operator+(const Sales_data&,const Sales_data&);
    public:
        Sales_data() = default;
        Sales_data(const std::string &s):bookNo(s){}
        Sales_data(const std::string &s,unsigned n,double p):
            bookNo(s),units_sold(n),revenue(p*n){}
        Sales_data(std::istream &);
        Sales_data& operator+=(cosnt Sales_data&);

    // new members: operations on Sales_data objects
        std::string isbn() const { return bookNo; }
        Sales_data& combine(const Sales_data&);
        inline double Sales_data::avg_price() const
        {
            if (units_sold)
                return revenue/units_sold;
            else
                return 0;
        }
    private:
    // data members are unchanged from § 2.6.1 (p. 72)
        std::string bookNo;
        unsigned units_sold = 0;
        double revenue = 0.0;
};


/*
* nonmember Sales_data interface functions
*/
Sales_data add(const Sales_data&, const Sales_data&);
std::istream &read(std::istream&, Sales_data&);
std::ostream &print(std::ostream&, const Sales_data&);

 
