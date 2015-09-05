module game;

import std.conv;
import std.string;

import board;
import player;
import window;

/***********************************
* A class which represents a game. It is used to manage the turns of the players
* and enforce the game rules. It also displays the board when needed.
*/

class Game
{
private:
    Player[2] players;
    Board board;
    Window infoWindow;
    Window inputWindow;
    Window displayWindow;

    void displayBoard()
    {
        displayWindow.clear();
        for(int j = 0; j < board.numberOfStacks; ++j)
        {
            displayWindow.move(j, 0);
            displayWindow.print(format("%d: ", j + 1));
            for(int k = 0; k < board.numberOfMatchesInStack(j); ++k)
            {
                displayWindow.print("|");
            }
        }
        displayWindow.update();
    }

public:

    ///
    this(Board board)
    {
        this.board = board;
        players[0] = new LocalPlayer();
        players[1] = new LocalPlayer();
        infoWindow = new Window(1, mainWindow.maxX, 0, 0);
        inputWindow = new Window(1, mainWindow.maxX, mainWindow.maxY, 0);
        displayWindow = new Window(mainWindow.maxY - 2,
                                   mainWindow.maxX,
                                   1,
                                   0);
    }

    /***********************************
    * Used to start a game.
    * Examples:
    * --------------------
    * auto board = new Board(3);
    * auto game = new Game(board);
    * game.play(); // The game is now running.
    * --------------------
    */

    void play()
    {
        mainWindow.clear();
        mainWindow.update();
        string msg;
        displayBoard();

        outerLoop:
        while(true)
        {
            foreach(i, player; players)
            {
                {
                    msg = format("It's player %s's Turn. Please enter from " ~
                                 "which stack to take how many matches.",
                                 i + 1);
                    infoWindow.setContent(msg);
                }
                while(true)
                {
                    try
                    {
                        auto turnInfo = player.doTurn();
                        board.removeMatches(turnInfo.stackNumber,
                                            turnInfo.numberOfMatches);
                        break;
                    }
                    catch(ConvException e)
                    {
                        msg = "Please enter two positive integers.";
                        infoWindow.setContent(msg);
                    }
                    catch(StackDoesNotExistException e)
                    {
                        infoWindow.setContent(e.msg);
                    }
                    catch(NotEnoughMatchesException e)
                    {
                        infoWindow.setContent(e.msg);
                    }
                }

                displayBoard();

                if(!board.existsMatch)
                {
                    msg = format("Player %s won the game. " ~
                                 "Press any key to return to the menu.",
                                 i + 1);
                    infoWindow.setContent(msg);
                    inputWindow.getKey();
                    break outerLoop;
                }
            }
        }  
    }
}
