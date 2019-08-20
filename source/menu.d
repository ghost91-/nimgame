module menu;

import std.algorithm;
import std.conv;
import std.exception;
import std.string;

import window;

/***********************************
* An interface for menu entries which can be used in the Menu class.
*/

interface MenuEntry
{
public:

    /***********************************
    * Used to activate the MenuEntry.
    */

    void select();

    /***********************************
    * Returns: Some text that is associated with the MenuEntry.
    */

    string text() const @property;
}

/***********************************
* A simple implementation of the MenuEntry interface,
* which only contains some text.
* 
* This is meant to be base class of which one can derive more specialized
* menu entry classes, that actually do something.
*/

class MenuEntryBasic : MenuEntry
{
protected:
    /***********************************
    * Representation of the text associated with the MenuEntry.
    */

    string name;

public:

    ///
    this(string text)
    {
        this.name = text;
    }

    /***********************************
    * Returns: The text that is associated with the MenuEntry.
    */

    string text() const @property
    {
        return name;
    }

    /***********************************
    * This implementaton actually does nothing.
    */

    override void select()
    {

    }
}

///
unittest
{
    auto entry = new MenuEntryBasic("test");
    assert(entry.text == "test");
}

/***********************************
* An implementation of the MenuEntry interface, which contains a delegate
* callback with arbitrary parameters.
*/

class MenuEntryMethod(Args...) : MenuEntryBasic
{
protected:

    /***********************************
    * Representation of the callback.
    */

    void delegate(Args) method;

    /***********************************
    * Representation of the parameters.
    */

    Args parameters;

public:

    ///
    this(string text, void delegate(Args) method, Args parameters)
    in
    {
        assert(method !is null);
    }
    body
    {
        super(text);
        this.method = method;
        this.parameters = parameters;
    }

    /***********************************
    * Calls the callback with the given parameters
    * Examples:
    * --------------------
    * auto entry = new MenuEntryMethod!int("Some text", aDelegate, 0);
    * entry.select(); // Calls aDelegate(0)
    * --------------------
    */

    override void select()
    {
        method(parameters);
    }
}

///
unittest
{
    int capturer;

    auto underTest = new MenuEntryMethod!()("Test text", { capturer = 42; });
    underTest.select();

    assert(underTest.text == "Test text");
    assert(capturer == 42);
}

///
unittest
{
    int capturerA;
    string capturerB;

    auto underTest = new MenuEntryMethod!(int, string)("Test text", (int a, string b) {
        capturerA = a;
        capturerB = b;
    }, 42, "is the answer");
    underTest.select();

    assert(underTest.text == "Test text");
    assert(capturerA == 42);
    assert(capturerB == "is the answer");
}

/***********************************
* Thrown when run() is called on an empty menu.
*/

class MenuEmptyException : Exception
{
    ///
    this(string msg)
    {
        super(msg);
    }
}

/***********************************
* An implementation of a menu. It depends on a window class for output.
*/

class Menu
{
protected:

    /***********************************
    * Representation of the menu entries.
    */

    MenuEntry[] menuEntries;

    /***********************************
    * Prints the menu to a given window and highlights entry number highlight.
    */

    void print(Window window, uint highlight)
    in
    {
        assert(highlight < menuEntries.length);
    }
    body
    {
        foreach (i, entry; menuEntries)
        {
            if (highlight == i)
            {
                window.setAttribute(Attribute.reverse);
                window.movePrint(i.to!uint, 0u, format("%s", entry.text));
                window.unsetAttribute(Attribute.reverse);
            }
            else
                window.movePrint(i.to!uint, 0, format("%s", entry.text));
        }
        window.update();
    }

public:

    ///
    this()
    {

    }

    /***********************************
    * Adds a MenuEntry to the menu
    * Examples:
    * --------------------
    * auto menu = new Menu();
    * menu.addMenuEntry(new MenuEntryBasic("Some text"));
    * --------------------
    */

    void addMenuEntry(MenuEntry menuEntry)
    {
        menuEntries ~= menuEntry;
    }

    /***********************************
    * Returns: The number of menu entries.
    */

    size_t length() const @property
    {
        return menuEntries.length;
    }

    ///
    unittest
    {
        auto menu = new Menu();
        assert(menu.length == 0);
        menu.addMenuEntry(new MenuEntryBasic("Some text"));
        assert(menu.length == 1);
        menu.addMenuEntry(new MenuEntryBasic("Some other text"));
        assert(menu.length == 2);
    }

    /***********************************
    * Returns: The maximum length of the texts of all menu entries.
    */

    size_t maximumTextLength() @property const
    {
        return menuEntries.map!(entry => entry.text.to!dstring.length).reduce!max;
    }

    ///
    unittest
    {
        auto menu = new Menu();
        string someText = "Some text";
        assert(someText.to!dstring.length == 9);
        string someOtherText = "Some text, which contains more complex characters: €, @, 𝔸";
        assert(someOtherText.to!dstring.length == 58);
        menu.addMenuEntry(new MenuEntryBasic(someText));
        menu.addMenuEntry(new MenuEntryBasic(someOtherText));
        assert(menu.maximumTextLength == 58);
    }

    /***********************************
    * Activates the menu
    *
    * Throws: MenuEmptyException if the menu does not contain an entries.
    */

    void run()
    {
        if (menuEntries is null)
        {
            immutable msg = "run() not callable on an empty menu.";
            throw new MenuEmptyException(msg);
        }
        uint highlight;
        int selection = -1;

        Key key;

        immutable uint x = (mainWindow.maxX - maximumTextLength.to!uint) / 2;
        immutable uint y = (mainWindow.maxY - length.to!uint) / 2;
        auto window = new Window(length.to!uint, maximumTextLength.to!uint, y, x);
        mainWindow.clear();
        mainWindow.movePrint(0, 0,
                "Use arrow keys to go up and down, press enter to select a menu entry");
        mainWindow.update();

        print(window, highlight);
        while (true)
        {
            key = window.getKey();
            switch (key)
            {
            case Key.up:
                if (highlight == 0)
                    highlight = (menuEntries.length.to!int - 1).to!uint;
                else
                    --highlight;
                break;
            case Key.down:
                if (highlight == menuEntries.length.to!int - 1)
                    highlight = 0;
                else
                    ++highlight;
                break;
            case Key.newline:
                selection = highlight;
                break;
            default:
                break;
            }

            if (selection >= 0)
            {
                window.clear();
                window.update();
                menuEntries[selection].select();
                break;
            }
            else
                print(window, highlight);
        }
        return;
    }
}
