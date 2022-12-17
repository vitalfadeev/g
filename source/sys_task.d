module sys_task;

import core.sys.windows.windows;
import std.conv;
import std.stdio;
import std.traits;


// WindowsDelegate!( EnumWindows, EnumWindowsProc )( callback )
// alias EnumWindowsProc = BOOL function( HWND, LPARAM )
//void WinDelegate( WIN_FUNC, WIN_CALLBACK, DG )( DG d_callback )
//{
//    WIN_CALLBACK win_callback;

//    extern( Windows ) nothrow 
//    WIN_CALLBACK
//    void win_callback( ARGS... )( ARGS args, LPARAM lParam )
//    {
//        DG callback = 
//            *( cast( DG* ) cast( void* ) lParam);

//        try {
//            callback( args );
//        } catch ( Throwable e ) {
//            // FIXME
//        }
//    }

//    WIN_FUNC( &win_callback, cast( LPARAM )cast( void* )&d_callback  );
//}


//void test_wd()
//{
//    void callback( HWND hwnd, LPARAM lParam )
//    {
//        writeln( "XXX" );
//    }

//    WinDelegate!( EnumWindows, EnumWindowsProc )( &callback );
//}


struct SysTask
{
    alias EACH_TASK_CALLBACK = void delegate( HWND, string );

    static
    void each_task( EACH_TASK_CALLBACK callback )
    {
        for ( HWND hwnd = GetTopWindow(NULL); hwnd != NULL; hwnd = GetNextWindow( hwnd, GW_HWNDNEXT ) )
        {
            if ( IsWindowVisible( hwnd ) )
            {
                int chars = GetWindowTextLength( hwnd );

                if ( chars )
                {
                    wchar[] buf = new wchar[ chars + 1 ];
                    chars = GetWindowText( hwnd, buf.ptr, chars + 1 );

                    string title = 
                        buf[ 0 .. chars ].to!string;

                    callback( hwnd, title );
                }
            }
        }
    }


    alias EACH_WINDOW_CALLBACK = void delegate( HWND, string );

    static
    void each_window( EACH_TASK_CALLBACK callback )
    {
        for ( HWND hwnd = GetTopWindow(NULL); hwnd != NULL; hwnd = GetNextWindow( hwnd, GW_HWNDNEXT ) )
        {
            {
                int chars = GetWindowTextLength( hwnd );

                if ( chars )
                {
                    wchar[] buf = new wchar[ chars + 1 ];
                    chars = GetWindowText( hwnd, buf.ptr, chars + 1 );

                    string title = 
                        buf[ 0 .. chars ].to!string;

                    callback( hwnd, title );
                }
            }
        }
    }

    // Enum versions
    static
    void each_task2( EACH_TASK_CALLBACK callback )
    {
        EnumWindows( 
            &(_enum_task_proc!EACH_TASK_CALLBACK), 
            cast( LPARAM )cast( void* )&callback 
        );
    }

    static
    void each_window2( EACH_WINDOW_CALLBACK callback )
    {
        EnumWindows( 
            &(_enum_windows_proc!EACH_WINDOW_CALLBACK), 
            cast( LPARAM )cast( void* )&callback 
        );
    }


    static extern( Windows ) nothrow
    BOOL _enum_windows_proc( CALLBACK )( HWND hwnd, LPARAM lParam )
        if ( isDelegate!CALLBACK )
    {
        {
            int chars = GetWindowTextLength( hwnd );

            if ( chars )
            {
                wchar[] buf = new wchar[ chars + 1 ];
                chars = GetWindowText( hwnd, buf.ptr, chars + 1 );

                try 
                {
                    string title = 
                        buf[ 0 .. chars ].to!string;

                    auto callback = 
                        *( cast( CALLBACK* ) cast( void* ) lParam);

                    callback( hwnd, title );
                }
                catch ( Exception e )
                {
                    // FIXME
                }
            }
        }

        return TRUE;
    }

    static extern( Windows ) nothrow
    BOOL _enum_task_proc( CALLBACK )( HWND hwnd, LPARAM lParam )
        if ( isDelegate!CALLBACK )
    {
        if ( IsWindowVisible( hwnd ) )
        {
            int chars = GetWindowTextLength( hwnd );

            if ( chars )
            {
                wchar[] buf = new wchar[ chars + 1 ];
                chars = GetWindowText( hwnd, buf.ptr, chars + 1 );

                try 
                {
                    string title = 
                        buf[ 0 .. chars ].to!string;

                    // struct delegate
                    //    .ptr
                    //    .funcptr
                    //
                    // delegate
                    // delegate*
                    // void*
                    //
                    // cast( void* )
                    // cast( delegate* )
                    // cast( delegate )

                    auto callback = 
                        *( cast( CALLBACK* ) cast( void* ) lParam);

                    callback( hwnd, title );
                }
                catch ( Exception e )
                {
                    // FIXME
                }
            }
        }

        return TRUE;
    }
}


void test_sys_window()
{
    void callback( HWND hwnd, string s )
    {
        writeln( "WIN: ", s );
    }

    SysTask.each_window( &callback );
}


void test_sys_task()
{
    void callback( HWND hwnd, string s )
    {
        writeln( "TASK: ", s );
    }

    SysTask.each_task( &callback );
}
