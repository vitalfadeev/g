module window;

import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import root;
import op;
import defs;
import panel;
import windows;
import gobject;
import bindbc.sdl;
import sdlexception;


//
class Window
{
    SDL_Window*   window;
    GObject       root;
    SDL_Renderer* renderer;


    this( SDL_Window* window, GObject root, SDL_Renderer* renderer )
    {
        this.window   = window;
        this.root     = root;
        this.renderer = renderer;
    }


    ~this()
    {
        SDL_DestroyRenderer( renderer );
        SDL_DestroyWindow( window );
    }


    size_t main( SDL_Event* e )
    {
        if ( is_event_for_me( e ) )
        {
            // SDL_WINDOWEVENT
            if ( e.type == SDL_WINDOWEVENT )
            {
                // SDL_WINDOWEVENT_CLOSE
                if ( e.window.event == SDL_WINDOWEVENT_CLOSE )
                {
                    // Unmanage window
                    unmanage_window( this );

                    // Close
                    SDL_DestroyWindow( window );
                }

                // ANY WINDOW EVENT
                else
                {
                    //
                }
            }

            // ANY
            else
            {
                if ( root !is null )
                    return root.main( e );
            }
        }

        return 0;
    }


    bool is_event_for_me( SDL_Event* e )
    {
        // SDL_WINDOWEVENT
        if ( e.type == SDL_WINDOWEVENT )
        {
            if ( SDL_GetWindowID( window ) == e.window.windowID )
                return true;
        }

        // SDL_MOUSEBUTTONDOWN
        // SDL_MOUSEBUTTONUP
        else
        if (( e.type == SDL_MOUSEBUTTONDOWN ) ||
            ( e.type == SDL_MOUSEBUTTONUP ))
        {
            if ( SDL_GetWindowID( window ) == e.button.windowID )
                return true;
        }

        // SDL_MOUSEWHEEL
        else
        if ( e.type == SDL_MOUSEWHEEL )
        {
            if ( SDL_GetWindowID( window ) == e.wheel.windowID )
                return true;
        }

        return false;
    }
}
