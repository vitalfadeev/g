module tools;


auto beetween( TA, TB, TC )( TA a, TB b, TC c )
{
    return ( a >= b ) && ( a <=c );
}
