module player;

import std.algorithm;
import std.conv;
import std.random;
import std.range;
import std.string;
import std.typecons;

import board;
import window;

/***********************************
* The type, that is used to store information about a turn.
*/

alias TurnInfo = Tuple!(ulong, ulong);

/***********************************
* An interface for players.
*/

interface Player
{
public:
    /***********************************
    * Used to make a player do a turn based on the current board.
    * Returns: A tuple of two integers: The number of the stack from which the
    * player wants to remove matches and the number of matches he wants to
    * remove.
    */

    TurnInfo doTurn(Board board);
}

/***********************************
* An implementation of the Player interface, which defines a local human
* controlled player.
*/

class HumanPlayer : Player
{
private:
    Window inputWindow;
public:

    ///
    this()
    {
        inputWindow = new Window(1, mainWindow.maxX, mainWindow.maxY, 0);
    }

    /***********************************
    * Lets the user input two integers as the information for the turn.
    * Returns: A tuple of those two integers.
    */

    TurnInfo doTurn(Board board)
    {
        return tuple(inputWindow.getInt().to!ulong, inputWindow.getInt().to!ulong);
    }
}

/***********************************
* An implementation of the Player interface, which defines a local AI
* controlled player.
*/

class AIPlayer : Player
{
protected:

    /***********************************
    * Used to determin if a turn is a win-turn
    * Returns: true, if the turn is a win-turn and false otherwise.
    * Params:
    * board = is the state of the board which the turn is based on.
    * turnInfo = is the information about the turn.
    */

    bool isWinTurn(Board board, TurnInfo turnInfo)
    {
        board.removeMatches(turnInfo[0], turnInfo[1]);
        return board.reduce!((a, b) => a ^ b) == 0;
    }

    ///
    unittest
    {
        auto player = new AIPlayer();
        auto board = Board(1);
        auto anotherBoard = Board(2);
        auto turn = tuple(0uL, 1uL);
        assert(player.isWinTurn(board, turn));
        assert(!player.isWinTurn(anotherBoard, turn));
    }

public:

    ///
    this()
    {

    }

    /***********************************
    * Used to make the AI-player decide on a turn based on the current board.
    * The AI-player plays perfect, which means, if there is a win-turn, the
    * AI-player chooses a win-turn.
    * Returns: The turn info for the chosen turn.
    */

    TurnInfo doTurn(Board board)
    {
        TurnInfo[] turns;
        TurnInfo[] winTurns;
        import core.thread;

        Thread.sleep(dur!("msecs")(500));
        foreach (stackNumber, stack; board[].enumerate)
        {
            foreach (numberOfMatches; 1 .. stack + 1)
            {
                auto currentTurn = tuple(stackNumber, numberOfMatches);
                if (isWinTurn(board, currentTurn))
                {
                    winTurns ~= currentTurn;
                }
                turns ~= currentTurn;
            }
        }
        if (winTurns !is null)
            return winTurns[uniform(0, winTurns.length)];
        else
            return turns[uniform(0, turns.length)];
    }
}
