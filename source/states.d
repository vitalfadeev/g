module states;

import std.typecons;


//
enum STATES
{
    NORMAL   =      0,

    PRESSED  = 1 << 0,
    DISABLED = 1 << 1,
    HOVER    = 1 << 2,
    CHECKED  = 1 << 3,
    SELECTED = 1 << 4,
    FOCUSED  = 1 << 5,
    ACTIVE   = 1 << 6, 
    STUB     = 1 << 7, 
}

BitFlags!STATES STATE_NORMAL   = STATES.NORMAL;
BitFlags!STATES STATE_PRESSED  = STATES.PRESSED;
BitFlags!STATES STATE_DISABLED = STATES.DISABLED;
BitFlags!STATES STATE_HOVER    = STATES.HOVER;
