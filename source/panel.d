module panel;

import std.conv;
import std.stdio;
import bindbc.sdl;
import tree;
import op;
import defs;
import button;


class Panel : GObject
{
    override
    size_t main( SDL_Event* e )
    {
        //if ( e.type == OP.RENDER   ) return this.render( e );
        //if ( e.type == op.rendered ) return this.rendered( e );
        return super.main( e );
    }
}


class Clock : GObject
{
    override
    size_t mouse_button( SDL_Event* e )
    {
        // next childs
        super.mouse_button( e );

        return 0;
    }
}


class LMenuButton : Button
{
    //
}


class RMenuButton : Button
{
    override
    size_t mouse_button( SDL_Event* e )
    {
        // next childs
        super.mouse_button( e );

        return 0;
    }
}


