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


T instanceof( T )( Object o ) 
    if ( is( T == class ) )
{
    return cast( T ) o;
}


pragma( lib, "user32.lib" );
nothrow
void msgbox( string s )
{
    import core.sys.windows.windows; // FIXME
    import std.string;
    import std.conv;
    import std.utf;
    try { MessageBox( NULL, s.toUTF16z, "info", MB_OK | MB_ICONEXCLAMATION ); } 
    catch ( Throwable e ) { /* FIXME */ }
}

pragma( lib, "user32.lib" );
nothrow
void msgbox( Throwable e )
{
    import core.sys.windows.windows; // FIXME
    import std.string;
    import std.conv;
    import std.utf;
    try { MessageBox( NULL, e.toString.toUTF16z, "info", MB_OK | MB_ICONEXCLAMATION ); } 
    catch ( Throwable e ) { /* FIXME */ }
}
