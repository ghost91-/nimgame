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
        menu.addMenuEntry(new MenuEntryMethodParameter!GameType("Human vs Human", &startGame, GameType.humanVsHuman));
        menu.addMenuEntry(new MenuEntryMethodParameter!GameType("Human vs AI", &startGame, GameType.humanVsAI));
        menu.addMenuEntry(new MenuEntryMethodParameter!GameType("AI vs AI", &startGame, GameType.AIVsAI));
        while(running)
        {
            menu.run();
        }
    }

    /***********************************
    * Creates and starts a new game
    */

    void startGame(GameType gameType)
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
        auto board = Board(numberOfStacks);
        auto game = new Game(gameType, board);
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
