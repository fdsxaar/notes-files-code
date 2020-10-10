#include <string>

class Screen;

class Window_mgr {
    public:
        using ScreenIndex = std::vector<Screen>::size_type;
        void clear(ScreenIndex);
    private:
    // Screens this Window_mgr is tracking
    // by default, a Window_mgr has one standard sized blank Screen
        std::vector<Screen> screens{Screen(24, 80, ' ') };
};

void Window_mgr::clear(ScreenIndex i)
{
    Screen &s = Screens[i];
    s.contents = string(s.height*s.width,' ');
}



