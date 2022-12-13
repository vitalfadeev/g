module window;

import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import tree;
import op;
import defs;
import panel;
import windows;
import bindbc.sdl;
import sdlexception;


//
class Window
{
    SDL_Window*   window;
    Tree          tree;
    SDL_Renderer* renderer;

    this( SDL_Window* window, Tree tree, SDL_Renderer* renderer )
    {
        this.window   = window;
        this.tree     = tree;
        this.renderer = renderer;
    }

    ~this()
    {
        SDL_DestroyRenderer( renderer );
        SDL_DestroyWindow( window );
    }

    size_t main( SDL_Event* e )
    {
        // SDL_WINDOWEVENT
        if ( e.type == SDL_WINDOWEVENT )
        {
            if ( SDL_GetWindowID( window ) == e.window.windowID )
            {
                // SDL_WINDOWEVENT_CLOSE
                if ( e.window.event == SDL_WINDOWEVENT_CLOSE )
                {
                    // Unmanage window
                    unmanage_window( this );

                    // Close
                    SDL_DestroyWindow( window );
                }
                else

                // ANY WINDOW EVENT
                {
                    //
                }
            }
        }
        else

        // SDL_MOUSEBUTTONDOWN
        // SDL_MOUSEBUTTONUP
        if (( e.type == SDL_MOUSEBUTTONDOWN ) ||
            ( e.type == SDL_MOUSEBUTTONUP ))
        {
            if ( SDL_GetWindowID( window ) == e.button.windowID )
            {
                if ( tree !is null )
                    return tree.main( e );
            }
        }
        else

        // ANY
        {
            //
        }
        
        return 0;
    }
}