#include <string>
#include <iostream>
#include <cstddef>

class Quote{
    public:
        Quote()=default;
        Quote(const std::string &book, double sales_price):
            bookNo(book), price(sales_price){}
        std::string isbn(){return bookNo;}
        virtual double net_price(std::size_t n) const
        {
            return n*price;
        }
        virtual ~Quote()=default;
        // virtual function to return a dynamically allocated copy of itself
        // these members use reference qualifiers; see §13.6.3 (p. 546)
        virtual Quote* clone() const & {return new Quote(*this);}
        virtual Quote* clone() && {return new Quote(std::move(*this));}
       // other members as before
        virtual void debug() const
        {
            std::cout << price << " " << bookNo <<std::endl;
        }
    protected:
        double price;
    private:
        std::string bookNo;
        
};


class Disc_quote:public Quote{
    public:
        Disc_quote()=default;
        Disc_quote(std::string &book, double price, std::size_t qty, double disc ):
            Quote(book, price), quantity(qty), discount(disc) {}
        double net_price(std::size_t) const =0;
    Bulk_quote* clone() const & {return new Bulk_quote(*this);}
    Bulk_quote* clone() && {return new Bulk_quote(std::move(*this));}
    
    protected:
        std::size_t quantity = 0;
        double discount = 0.0;
};
/******start Bulk_quote def******/

class Bulk_quote:public Disc_quote{
    public:
        Bulk_quote()=default;
        Bulk_quote(const std::string &book, double sales_price, std::size_t qty, double disc):
            Quote(book, sales_price, qty, disc){}
        virtual double net_price(std::size_t) const override;
    
};

double Bulk_quote::net_price(std::size_t cnt) const 
{
    if (cnt >= min_qty)
        return cnt*(1-discount);
    else
        return cnt*price;
}
/*****end Bulk_quote def ******/


// calculate and print the price for the given number of copies, applying any discounts
double print_total(std::ostream &os,const Quote &item, size_t n)
{
// depending on the type of the object bound to the item parameter
// calls either Quote::net_price or Bulk_quote::net_price
    double ret = item.net_price(n);
    std::os << "ISBN: " << item.isbn() // calls Quote::isbn
    << " # sold: " << n << " total due: " << ret << std::endl;
    return ret;
}

