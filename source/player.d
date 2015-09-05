module player;

import std.conv;
import std.typecons;

import board;
import window;

/***********************************
* The type, that is used to store information about a turn.
*/

alias TurnInfo = Tuple!(uint, "stackNumber", uint, "numberOfMatches");

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

    TurnInfo doTurn();
}

/***********************************
* An implementation of the Player interface, which defines a local human
* controlled player.
*/

class LocalPlayer : Player
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
    * Examples:
    * --------------------
    * auto player = new LocalPlayer();
    * auto turnInfo = player.doTurn(); // We assume, that the user enters 1 and 1.
    * assert(turnInfo.stackNumber == 1);
    * assert(turnInfo.numberOfMatches == 1);
    * --------------------
    */

    TurnInfo doTurn()
    {
        TurnInfo turnInfo;
        turnInfo.stackNumber = inputWindow.getInt().to!uint - 1;
        turnInfo.numberOfMatches = inputWindow.getInt().to!uint;
        return turnInfo;
    }
}
