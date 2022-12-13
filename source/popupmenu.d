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

    // fix position for desktop
    fix_popup_position( at_point, menu.rect.w, menu.rect.h );

    // create window
    SDL_Window* window;
    create_window( window, at_point );

    // Save window for manage
    manage_window( new Window( window, null, null ) );

    //
    window_size_fromn_gobject( window, menu );
}


//
void fix_popup_position( SDL_Point* at_point, int w, int h )
{
    int display_index;
    SDL_DisplayMode mode;

    if ( SDL_GetDesktopDisplayMode( display_index, &mode ) )
        throw new SDLException( "ERR: Getting display mode" );

    // right 
    if ( at_point.x + w > mode.w )
        at_point.x = mode.w - w;

    // bottom
    if ( at_point.y + h > mode.h )
        at_point.y = mode.h - h;
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
    menu.rect.w = 200;
    menu.rect.h = 400;

    auto vbox = new VBoxLayout();
    menu.add( vbox );

    auto b1 = new Button();
    auto b2 = new Button();
    auto b3 = new Button();
    vbox.add( b1 );
    vbox.add( b2 );
    vbox.add( b3 );

    menu.layout();
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

