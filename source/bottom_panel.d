module bottom_panel;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import treeobject;
import gobject;
import op;
import defs;
import button;
import text;
import tools;
import style;
import sdlexception;


class BottomPanel : GObject
{
    override
    size_t main( SDL_Event* e )
    {
        //if ( e.type == OP.RENDER   ) return this.render( e );
        //if ( e.type == op.rendered ) return this.rendered( e );
        return super.main( e );
    }
}

class AppButton : GObject
{
    override
    void render( SDL_Renderer* renderer )
    {
        bg = SDL_Color(   64,   64,  64, SDL_ALPHA_OPAQUE );
        fg = SDL_Color(  200,  200, 200, SDL_ALPHA_OPAQUE );
        rect.x = 300;
        rect.y = 0;
        rect.w = 96;
        rect.h = 96;

        super.render( renderer );
    }
}

