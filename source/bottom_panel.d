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
        //writeln( this, ": ", e.type );
        //if ( e.type == OP.RENDER   ) return this.render( e );
        //if ( e.type == op.rendered ) return this.rendered( e );
        return super.main( e );
    }
}

class AppButton : Button
{
    override
    size_t main( SDL_Event* e )
    {
        return super.main( e );
    }

    override
    size_t mouse_button( SDL_Event* e )
    {
        writeln( this, ": ", e.type );

        // State
        change_state( e );

        // Styles
        apply_styles_recursive( this );

        // Remder
        push_render();

        // Childs
        return this.each_child_main( e );
    }


    override
    void render( SDL_Renderer* renderer )
    {
        writeln( this, ": ", renderer );

        super.render( renderer );
    }
}

