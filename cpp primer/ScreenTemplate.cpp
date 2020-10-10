#include <string>

class Screen {
    friend class Window_mgr;    //friend void Window_mgr::clear(ScreenIndex);
    public:
        typedef std::string::size_type pos;  //using pos = std::string::size_type
        Screen() = default;
        Screen(pos ht, pos wd):
            height(ht), width(wd), contents(ht*wd,' '){}
        Screen(pos ht, pos wd, char c):
            height(ht), width(wd), contents(ht*wd,c){}
        char get()const
            {return contents[cursor];}
        char get(pos ht, pos wd)const;
        Screen &move(pos r, pos c);
        Screen &set(char);
        Screen &set(pos, pos, char);
        Screen &display(std::ostream &os)const
                {do_dispaly(os); return *this;}
        const Screen &display(std::ostream &os)
                {do_dispaly(os); return *this;}
    private:
        pos cursor = 0;
        pos height = 0, width = 0;
        std::string contents;
        void do_dispaly(std::ostream &os) const {os<<contents;}
};

inline
Screen &Screen::move(pos r, pos c)
{    
    pos row = r * width;
    pos cursor = row + c;
    return *this; 
}

inline 
char Screen::get(pos ht, pos wd)
{
    pos row = ht * width;
    return contents[row+c];
}

inline 
Screen &Screen::set(char c)
{
    contents[cursor] = c;
    return *this;
}

inline 
Screen &Screen set(pos r, pos col, char c)
{
    contents[r*width+col] = c;
    return *this;
}

