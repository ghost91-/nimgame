module app;

import std.conv;

import board;
import game;
import menu;
import window;

/***********************************
* A simple application wrapper which contains the necessary functions to set up
* and run the application.
*/

class App
{
private:

    bool running = true;
public:
    ///
    this()
    {

    }

    /***********************************
    * Starts the application.
    */

    void run()
    {
        auto menu = new Menu();
        menu.addMenuEntry(new MenuEntryMethod("Quit", &quit));
        menu.addMenuEntry(new MenuEntryMethod("Start a new game", &startGame));
        while(running)
        {
            menu.run();
        }
    }

    /***********************************
    * Creates and starts a new game
    */

    void startGame()
    {
        auto inputWindow = new Window(1, mainWindow.maxX, mainWindow.maxY, 0);
        mainWindow.setContent("Please enter the number of stacks for " ~
                              "this game.");
        uint numberOfStacks;
        while(true)
        {
            try
            {
                numberOfStacks = inputWindow.getInt().to!uint;
                break;
            }
            catch(ConvException)
            {
                mainWindow.setContent("Please enter a positive integer.");
            }
        }
        auto board = new Board(numberOfStacks);
        auto game = new Game(board);
        game.play();
    }

    /***********************************
    * Clears the Display and quits the application
    */

    void quit()
    {
        running = false;
        mainWindow.clear();
        mainWindow.update();
    }
}
