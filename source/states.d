module states;

import std.typecons;


//
enum States
{
    NORMAL   = 1 << 0,
    PRESSED  = 1 << 1,
    DISABLED = 1 << 2,
    HOVER    = 1 << 3
}

BitFlags!States STATE_NORMAL   = States.NORMAL;
BitFlags!States STATE_PRESSED  = States.PRESSED;
BitFlags!States STATE_DISABLED = States.DISABLED;
BitFlags!States STATE_HOVER    = States.HOVER;