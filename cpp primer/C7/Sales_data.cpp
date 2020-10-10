#include "Sales_data.h"

/*
*member function
*/
/********start member functions def********/

Sales_data::Sales_data(std::istream &is){
    read(is,*this)
}


 Sales_data& Sales_data::combine(const Sales_data &rhs)
{
    units_sold += rhs.units_sold; // add the members of rhs into
    revenue += rhs.revenue; // the members of ''this'' object
    return *this; // return the object on which the function was called
}
/*********end member functions def *********/


/*
*non-member function
*/

/********start non-member functions def***********/
Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
    Sales_data sum = lhs; // copy data members from lhs into sum
    sum.combine(rhs); // add data members from rhs into sum
    return sum;
}

// input transactions contain ISBN, number of copies sold, and sales price
std::istream &read(istream &is, Sales_data &item)
{
    double price = 0;
    is >> item.bookNo >> item.units_sold >> price;
    item.revenue = price * item.units_sold;
    return is;
}

std::ostream &print(ostream &os, const Sales_data &item)
{
    os << item.isbn() << " " << item.units_sold << " "
    << item.revenue << " " << item.avg_price();
    return os;
}

std::ostream& operator<<(std::ostream &os,const Sales_data &item){
    os << item.bookNo << item.units_sold
       << item.revenue << std::endl;
}

std::istream& operator>>(std::istream &is,Sales_data &item){
    double price = 0.0;
    is >> item.bookNo >> item.units_sold >> price;
    if(is)
        item.revenue = item.units_sold*price;
    else
        item = Sales_data();
    return is;
}

Sales_data& Sales_data::operator+=(const Sales_data &r_item){
    units_sold += r_item.units_sold;
    revenue += r_item.revenue;
    return *this;
}

Sales_data operator+(const Sales_data &l_item, const Sales_data &r_item){
    Sales_data temp = l_item;
    temp += r_item;
    return temp;
}
/*******end non-member functions def *************/