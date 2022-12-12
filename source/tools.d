module tools;


auto beetween( TA, TB, TC )( TA a, TB b, TC c )
{
    return ( a >= b ) && ( a <=c );
}


auto remove_element( R, N )( R haystack, N needle )
{
    import std.algorithm : countUntil, remove;
    auto index = haystack.countUntil( needle );
    return ( index != -1 ) ? haystack.remove( index ) : haystack;
}