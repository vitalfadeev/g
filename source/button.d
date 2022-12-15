module button;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import defs;
import gobject;


class Button : GObject
{
    string text;


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


    override
    void render( SDL_Renderer* renderer )
    {
        // bg, borders
        render_bg( renderer );
        render_borders( renderer );

        // Text
        SDL_SetRenderDrawColor( renderer, 198, 198, 198, 255  );
        int text_w =  2;
        int text_h = 16;
        SDL_Rect r = 
            SDL_Rect( 
                rect.x + rect.w / 2 - text_w / 2, 
                rect.y + rect.h / 2 - text_h / 2, 
                text_w, 
                text_h 
            );
        SDL_RenderFillRect( renderer, &r );

        // Render childs
        render_childs( renderer );
    }
}
