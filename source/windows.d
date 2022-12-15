module windows;

import bindbc.sdl;
import window;
import tree;
import gobject;

//
Window[] managed_windows;


void manage_window( Window window )
{
    managed_windows ~= window;
}


void unmanage_window( Window window )
{
    import std.stdio;
    import tools;
    managed_windows = remove_element( managed_windows, window );
}


//
void find_windows_with_object( ref Window[] obj_windows, GObject obj )
{
    foreach ( window; managed_windows )
        if ( window.tree !is null )
            foreach ( ref o; window.tree.all_childs )
                if ( o is obj )
                    obj_windows ~= window; // tree found
}


void all_windows_main( SDL_Event* e )
{
    foreach ( w; managed_windows )
        w.main( e );
}
