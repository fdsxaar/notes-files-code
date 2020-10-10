#include <string>
#include <iostream>
#include <memory>

// abstract class acts as a base class for concrete query types; all members are private
class Query_base {
    friend class Query;
    protected:
        using line_no = TextQuery::line_no; // used in the eval functions
    virtual ~Query_base() = default;
    
    private:
        // eval returns the QueryResult that matches this Query
        virtual QueryResult eval(const TextQuery&) const = 0;
        // rep is a string representation of the query
        virtual std::string rep() const = 0;
};

// interface class to manage the Query_base inheritance hierarchy
class Query {
    // these operators need access to the shared_ptr constructor
    friend Query operator~(const Query &);
    friend Query operator|(const Query&, const Query&);
    friend Query operator&(const Query&, const Query&);
    public:
        Query(const std::string&); // builds a new WordQuery
        // interface functions: call the corresponding Query_base operations
        QueryResult eval(const TextQuery &t) const
                    { return q->eval(t); }
        std::string rep() const { return q->rep(); }
    private:
        Query(std::shared_ptr<Query_base> query): q(query) { }
        std::shared_ptr<Query_base> q;
};

std::ostream &
operator<<(std::ostream &os, const Query &query)
{
    // Query::rep makes a virtual call through its Query_base pointer to rep()  
    return os << query.rep();
}

class WordQuery: public Query_base {
    friend class Query; // Query uses the WordQuery constructor
    WordQuery(const std::string &s): query_word(s) { }
    // concrete class: WordQuery defines all inherited pure virtual functions
    QueryResult eval(const TextQuery &t) const
        { return t.query(query_word); }
    std::string rep() const { return query_word; }
    std::string query_word; // word for which to search
};

inline
Query::Query(const std::string &s): q(new WordQuery(s)) { }

class NotQuery: public Query_base {
    friend Query operator~(const Query &);
    NotQuery(const Query &q): query(q) { }
    // concrete class: NotQuery defines all inherited pure virtual functions
    std::string rep() const {return "~(" + query.rep() +")";}
    QueryResult eval(const TextQuery&) const;
    Query query;
};

inline Query operator~(const Query &operand)
{
    return std::shared_ptr<Query_base>(new NotQuery(operand));
}

class BinaryQuery: public Query_base {
    protected:
        BinaryQuery(const Query &l, const Query &r, std::string s):
            lhs(l), rhs(r), opSym(s) { }
        // abstract class: BinaryQuery doesn't define eval
        std::string rep() const { return "(" + lhs.rep() + " " + opSym + " " + rhs.rep() + ")";}
        Query lhs, rhs; // right- and left-hand operands
        std::string opSym; // name of the operator
};

class AndQuery: public BinaryQuery {
    friend Query operator& (const Query&, const Query&);
    AndQuery(const Query &left, const Query &right):
        BinaryQuery(left, right, "&") { }
    // concrete class: AndQuery inherits rep and defines the remaining pure virtual
    QueryResult eval(const TextQuery&) const;
};

inline Query operator&(const Query &lhs, const Query &rhs)
{
    return std::shared_ptr<Query_base>(new AndQuery(lhs,rhs));
}

class OrQuery: public BinaryQuery {
    friend Query operator|(const Query&, const Query&);
    OrQuery(const Query &left, const Query &right):
        BinaryQuery(left, right, "|") { }
    QueryResult eval(const TextQuery&) const;
};

inline Query operator|(const Query &lhs, const Query &rhs)
{
    return std::shared_ptr<Query_base>(new OrQuery(lhs,rhs));
}

// returns the union of its operands' result sets
QueryResult
OrQuery::eval(const TextQuery& text) const
{
    // virtual calls through the Query members, lhs and rhs
    // the calls to eval return the QueryResult for each operand
    auto right = rhs.eval(text), left = lhs.eval(text);
    // copy the line numbers from the left-hand operand into the result set
    auto ret_lines = make_shared<set<line_no>>(left.begin(), left.end());
    // insert lines from the right-hand operand
    ret_lines->insert(right.begin(), right.end());
    // return the new QueryResult representing the union of lhs and rhs
    return QueryResult(rep(), ret_lines, left.get_file());
}

// returns the intersection of its operands' result sets
QueryResult
AndQuery::eval(const TextQuery& text) const
{
    // virtual calls through the Query operands to get result sets for the operands
    auto left = lhs.eval(text), right = rhs.eval(text);
    // set to hold the intersection of left and right
    auto ret_lines = make_shared<set<line_no>>();
    // writes the intersection of two ranges to a destination iterator
    // destination iterator in this call adds elements to ret
    set_intersection(left.begin(), left.end(),right.begin(), right.end(),
    inserter(*ret_lines, ret_lines->begin()));
    return QueryResult(rep(), ret_lines, left.get_file());
}

// returns the lines not in its operand's result set
QueryResult
NotQuery::eval(const TextQuery& text) const
{
    // virtual call to eval through the Query operand
    auto result = query.eval(text);
    // start out with an empty result set
    auto ret_lines = make_shared<set<line_no>>();
    // we have to iterate through the lines on which our operand appears
    auto beg = result.begin(), end = result.end();
    // for each line in the input file, if that line is not in result,
    // add that line number to ret_lines
    auto sz = result.get_file()->size();
    for (size_t n = 0; n != sz; ++n) {
    // if we haven't processed all the lines in result
    // check whether this line is present
    if (beg == end || *beg != n)
        ret_lines->insert(n); // if not in result, add this line
    else if (beg != end)
        ++beg; // otherwise get the next line number in result if there is one
}
    return QueryResult(rep(), ret_lines, result.get_file());
}




