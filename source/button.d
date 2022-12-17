module button;

import std.stdio;
import std.string;
import std.typecons;
import bindbc.sdl;
import op;
import defs;
import gobject;
import sdlexception;


class Button : GObject
{
    override
    size_t main( SDL_Event* e )
    {
        //if ( e.type == SDL_MOUSEBUTTONDOWN ) return this.mouse_button( e );
        //if ( e.type == SDL_MOUSEBUTTONUP   ) return this.mouse_button( e );
        //if ( e.type == SDL_KEYDOWN         ) return this.key( e );
        //if ( e.type == SDL_KEYUP           ) return this.key( e );
        //if ( e.type == OP.CLICK            ) return this.click( e );
        //if ( e.type == OP.CLICKED          ) return this.clicked( e );
        return super.main( e );
    }

    size_t key( SDL_Event* e )
    {
        return 0;
    }


    override
    size_t mouse_button( SDL_Event* e )
    {
        super.mouse_button( e );

        if ( e.type == SDL_MOUSEBUTTONDOWN )
        if ( e.button.button == SDL_BUTTON_LEFT )
            return click( e );

        return 0;
    }


    size_t click( SDL_Event* e )
    {
        return 0;
    }


    //override
    //void render( SDL_Renderer* renderer )
    //{
    //    // bg, borders
    //    render_bg( renderer );
    //    render_borders( renderer );
    //    render_text( renderer );

    //    // Render childs
    //    render_childs( renderer );
    //}
}
