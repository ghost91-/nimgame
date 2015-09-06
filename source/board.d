module board;

import std.algorithm;
import std.string;

/***********************************
* Thrown when trying to access a stack that does not exist.
*/

class StackDoesNotExistException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

/***********************************
* Thrown when trying to take more matches fro a stack than it contains.
*/

class NotEnoughMatchesException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

/***********************************
* A class that represents the board
*/

struct Board
{
private:
    ulong[] stacks;

public:

    ///
    this(uint numberOfStacks)
    {
        stacks.length = numberOfStacks;
        foreach(i, ref stack; stacks)
            stack = 2 * i + 1;
    }

    ///
    this(this)
    {
        stacks = stacks.dup;
    }

    ///
    auto opAssign(Board rhs)
    {
        this.stacks = rhs.stacks.dup;
        return this;
    }

    ///
    auto opApply(int delegate(ref ulong, ref ulong) dg)
    {
        int result = 0;
        foreach(i, stack; stacks)
        {
            result = dg(i, stack);
            if(result)
                break;
        }
        return result;
    }

    ///
    auto opApply(int delegate(ref ulong) dg)
    {
        int result = 0;
        foreach(stack; stacks)
        {
            result = dg(stack);
            if(result)
                break;
        }
        return result;
    }

    /***********************************
    * Removes amount matches from stack stackNumber.
    * Params:
    * stackNumber = is the number of the stack from which to remove matches.
    * amount = is the number of matches to remove.
    */

    void removeMatches(ulong stackNumber, ulong amount)
    {
        if(stackNumber >= stacks.length)
        {
            auto msg = format("There are only %s stacks, so it is not "~
                              "possible to remove matches from stack %s.",
                              stacks.length,
                              stackNumber + 1);
            throw(new StackDoesNotExistException(msg));
        }
        if(stacks[stackNumber] < amount)
        {
            auto msg = "You can't take more matches from a stack "~
                       "than it contains.";
            throw(new NotEnoughMatchesException(msg));
        }
        stacks[stackNumber] -= amount;
    }

    ///
    unittest
    {
        import std.exception : assertThrown; 
        auto board = new Board(1);
        assertThrown!StackDoesNotExistException(board.removeMatches(1, 2));
        assertThrown!NotEnoughMatchesException(board.removeMatches(0, 2));
    }

    /***********************************
    * Returns: true, if there is at least one stack containing at least one
    * match and false otherwise.
    */

    bool existsMatch() const @property
    {
        return stacks.sum > 0;
    }

    ///
    unittest
    {
        auto board = new Board(1);
        assert(board.existsMatch());
        board.removeMatches(0, 1);
        assert(!board.existsMatch());
    }

    /***********************************
    * Returns: The number of matches in stack stackNumber.
    */

    ulong numberOfMatchesInStack(size_t stackNumber) const
    {
        if(stackNumber >= stacks.length)
        {
            auto msg = format("There are only %s stacks, so it is not "~
                              "possible to remove matches from stack %s.",
                              stacks.length,
                              stackNumber);
            throw(new StackDoesNotExistException(msg));
        }
        return stacks[stackNumber];
    }

    /***********************************
    * Returns: The number of stacks.
    */

    size_t length() const @property
    {
        return stacks.length;
    }
}
