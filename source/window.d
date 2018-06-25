module window;

import std.algorithm;
import std.conv;
import std.traits;
import std.string;

import deimos.ncurses.ncurses;

/***********************************
* Attributes, which can be set for text that is displayed in a window
*/

enum Attribute : int
{
    standout = A_STANDOUT,
    underline = A_UNDERLINE,
    reverse = A_REVERSE,
    blink = A_BLINK,
    dim = A_DIM,
    bold = A_BOLD,
    invisible = A_INVIS
}

/***********************************
* Keys, which can be read as input
*/
enum Key : int
{
    down = KEY_DOWN,
    up = KEY_UP,
    left = KEY_LEFT,
    right = KEY_RIGHT,
    enter = KEY_ENTER,
    newline = '\n'
}

/***********************************
* Thrown when the cursor is moved past the boundaries of a window.
*/

class CursorOutOfWindowException : Exception
{
    ///
    this(string msg)
    {
        super(msg);
    }
}

/***********************************
* A class that allows control of the terminal. It uses ncurses as backend.
*/

class Window
{
public:

    static this() nothrow
    {
        initscr();
        deimos.ncurses.ncurses.clear();
        noecho();
        cbreak();
        mainWindow = new Window(stdscr);
    }

    static ~this() nothrow
    {
        endwin();
    }

    ///
    this(uint height, uint width, uint y, uint x) nothrow
    {
        window = newwin(height, width, y, x);
        keypad(window, true);
    }

    ///
    this(WINDOW* window) nothrow
    {
        this.window = window;
        keypad(window, true);
    }

    ///
    ~this() nothrow
    {
        delwin(window);
    }

    /***********************************
    * Prints a string to the window at the current cursor position.
    * Examples:
    * --------------------
    * mainWindow.print("Some text");
    * --------------------
    */

    void print(string text) nothrow
    {
        wprintw(window, toStringz(text));
    }

    /***********************************
    * Moves the cursor to a certain position and then prints a string at that
    * position.
    * Examples:
    * --------------------
    * mainWindow.movePrint(0, 0, "Some text"); // Prints "Some Text" at the upper left corner of the window.
    * --------------------
    */

    void movePrint(uint y, uint x, string text)
    {
        move(y, x);
        print(text);
    }

    /***********************************
    * Clears the window and prints text at the top left corner of the window.
    * In Contrast to the other print functions, this function does not require
    * a call to update() afterwards, because it calls update() itself. It is
    * meant to be a shortform for the frequent sequence of calls: clear();
    * movePrint(0, 0, "Some Text"); update();
    * Examples:
    * --------------------
    * mainWindow.setContent("Some text"); // Clears the window and prints "Some Text" at the upper left corner of the window.
    * --------------------
    */

    void setContent(string text)
    {
        clear();
        movePrint(0, 0, text);
        update();
    }

    /***********************************
    * Moves the cursor to a certain position.
    * Examples:
    * --------------------
    * mainWindow.move(0, 0); // The cursor is now at the upper left corner of
    * the window.
    * --------------------
    */

    void move(uint y, uint x)
    {
        if (y > maxY || x > maxX)
        {
            immutable msg = "Can't move the cursor past the windows boundaries.";
            throw new CursorOutOfWindowException(msg);
        }
        wmove(window, y, x);
    }

    ///
    unittest
    {
        import std.exception : assertThrown;

        assertThrown!CursorOutOfWindowException(mainWindow.move(mainWindow.maxY + 1,
                mainWindow.maxX));
        assertThrown!CursorOutOfWindowException(mainWindow.move(mainWindow.maxY,
                mainWindow.maxX + 1));
    }

    /***********************************
    * Reads a key input.
    * Returns: the read key.
    * Examples:
    * --------------------
    * auto key = mainWindow.getKey();
    * if(key == Key.up)
    *   doSomething();
    * --------------------
    */

    Key getKey() nothrow
    {
        return cast(Key) wgetch(window);
    }

    /***********************************
    * Reads an integer input.
    * Returns: The read int.
    * Examples:
    * --------------------
    * int i = mainWindow.getInt();
    * --------------------
    */

    int getInt()
    {
        static enum maximumIntLength = max(int.min.to!string.length, int.max.to!string.length);
        return getString(maximumIntLength).to!int;
    }

    /***********************************
    * Reads a string input.
    * Returns: The read string.
    * Params:
    * bufferLength = is an optional parameter which defines the buffer length
    *                to be used. The default value is 64.
    * Examples:
    * --------------------
    * string aString = mainWindow.getString();
    * string anotherString = mainWindow.getString(128); // Use a larger buffer.
    * --------------------
    */

    string getString(size_t bufferLength = 64)
    {
        char[] buffer;
        buffer.length = bufferLength;
        echo();
        wgetnstr(window, buffer.ptr, bufferLength.to!int);
        noecho();
        clear();
        update();
        return buffer.ptr.to!string;
    }

    /***********************************
    * Returns: The maximum y value of the window.
    */

    uint maxY() @property nothrow
    {
        return getmaxy(window);
    }

    /***********************************
    * Returns: The maximum x value of the window.
    */

    uint maxX() @property nothrow
    {
        return getmaxx(window);
    }

    /***********************************
    * Activates an attribute.
    * Examples:
    * --------------------
    * mainWindow.setAttribute(Attribute.underline);
    * mainWindow.print("Some Text"); // "Some Text" is printed underlined.
    * --------------------
    */

    void setAttribute(Attribute attribute) nothrow
    {
        wattron(window, attribute);
    }

    /***********************************
    * Deactivates an attribute.
    * Examples:
    * --------------------
    * mainWindow.unsetAttribute(Attribute.underline);
    * mainWindow.print("Some Text"); // "Some Text" is printed not underlined.
    * --------------------
    */

    void unsetAttribute(Attribute attribute) nothrow
    {
        wattroff(window, attribute);
    }

    /***********************************
    * Refreshes the window. This needs to be called to make any changes
    + to the window visible.
    * Examples:
    * --------------------
    * mainWindow.movePrint(0, 0, "Some Text");
    * mainWindow.update(); // "Some Text" is now actually written at the top left corner of the window.
    * --------------------
    */

    void update() nothrow
    {
        wrefresh(window);
    }

    /***********************************
    * Clears the window.
    * Examples:
    * --------------------
    * mainWindow.clear();
    * mainWindow.update(); // The window is now empty.
    * --------------------
    */

    void clear() nothrow
    {
        wclear(window);
    }

private:
    WINDOW* window;
}

/***********************************
* The main window, which is created when the module is loaded.
*/

Window mainWindow;
