module game;

import std.conv;
import std.string;
import std.range;
import std.algorithm;

import board;
import player;
import window;

/***********************************
* Different types of games
*/

enum GameType : int
{
    humanVsHuman,
    humanVsAI,
    AIVsAI
}

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
        displayWindow.move(0, 0);
        displayWindow.print(board[].enumerate.map!(a => a.index.to!string ~ ": " ~ replicate("|",
                a.value)).join("\n"));
        displayWindow.update();
    }

public:

    ///
    this(GameType gameType, const Board board)
    {
        this.board = board.dup;
        infoWindow = new Window(1, mainWindow.maxX, 0, 0);
        inputWindow = new Window(1, mainWindow.maxX, mainWindow.maxY, 0);
        displayWindow = new Window(mainWindow.maxY - 2, mainWindow.maxX, 1, 0);
        final switch (gameType) with (GameType)
        {
        case humanVsHuman:
            players[0] = new HumanPlayer();
            players[1] = new HumanPlayer();
            break;
        case humanVsAI:
            players[0] = new HumanPlayer();
            players[1] = new AIPlayer();
            break;
        case AIVsAI:
            players[0] = new AIPlayer();
            players[1] = new AIPlayer();
            break;
        }
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

        outerLoop: while (true)
        {
            foreach (i, player; players)
            {
                {
                    msg = format("It's player %s's Turn. Please enter from " ~ "which stack to take how many matches.",
                            i + 1);
                    infoWindow.setContent(msg);
                }
                while (true)
                {
                    try
                    {
                        auto turnInfo = player.doTurn(board);
                        board.removeMatches(turnInfo[0], turnInfo[1]);
                        break;
                    }
                    catch (ConvException e)
                    {
                        msg = "Please enter two positive integers.";
                        infoWindow.setContent(msg);
                    }
                    catch (StackDoesNotExistException e)
                    {
                        infoWindow.setContent(e.msg);
                    }
                    catch (NotEnoughMatchesException e)
                    {
                        infoWindow.setContent(e.msg);
                    }
                }

                displayBoard();

                if (!board.existsMatch)
                {
                    msg = format("Player %s won the game. " ~ "Press any key to return to the menu.",
                            i + 1);
                    infoWindow.setContent(msg);
                    inputWindow.getKey();
                    break outerLoop;
                }
            }
        }
    }
}
