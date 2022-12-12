module popupmenu;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import gobject;
import window;
import windows;
import button;
import defs;
import vboxlayout;
import sdlexception;


//
void create_popup_menu( SDL_Point* at_point )
{
    // create tree
    Menu menu;
    create_menu( menu );

    // create window
    SDL_Window* window;
    create_window( window, at_point );

    // Save window for manage
    manage_window( new Window( window, null, null ) );

    //
    window_size_fromn_gobject( window, menu );
}


//
class PopupMenu : GObject
{
    //
}


//
class Menu : GObject
{
    //
}


//
void create_menu( ref Menu menu )
{
    menu = new Menu();
    menu.size_mode = SizeMode.BY_CHILD;

    auto vbox = new VBoxLayout();
    menu.add( vbox );

    auto b1 = new Button();
    auto b2 = new Button();
    auto b3 = new Button();
    vbox.add( b1 );
    vbox.add( b2 );
    vbox.add( b3 );
}


//
void create_window( ref SDL_Window* window, SDL_Point* at_point )
{
    // Window
    window = 
        SDL_CreateWindow(
            "SDL2 Window",
            at_point.x,
            at_point.y,
            200, 400,
            SDL_WINDOW_POPUP_MENU | SDL_WINDOW_SKIP_TASKBAR
        );

    // SDL_CreateWindowFrom(), SDL_SetWindowInputFocus() | SDL_RaiseWindow()

    if ( !window )
        throw new SDLException( "Failed to create window" );

    // Update
    SDL_UpdateWindowSurface( window );    
}


//
void window_size_fromn_gobject( SDL_Window* window, GObject o )
{
    SDL_SetWindowSize( window, o.rect.w, o.rect.h );
}

