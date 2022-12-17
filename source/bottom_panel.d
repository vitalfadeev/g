module bottom_panel;

import core.sys.windows.windows;
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
import tools;
import style;
import sys_task;
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
    //override
    //size_t main( SDL_Event* e )
    //{
    //    return super.main( e );
    //}

    //override
    //size_t mouse_button( SDL_Event* e )
    //{
    //    // State
    //    change_state( e );

    //    // Styles
    //    apply_styles_recursive( this );

    //    // Remder
    //    push_render();

    //    // Childs
    //    return this.each_child_main( e );
    //}

    //override
    //size_t mouse_button( SDL_Event* e )
    //{
    //    return super.mouse_button( e );
    //}

    override
    size_t click( SDL_Event* e )
    {
        writeln( text );
        (cast(WinList)parent).update();
        return super.click( e );
    }
}


class WinList : GObject
{
    //
    void update()
    {
        clear_childs();
        SysTask.each_task( &_sys_task_each_callback );
    }

    void _sys_task_each_callback( HWND hwnd, string s )
    {
        //writeln( s );

        auto ab = new AppButton();
        add_child( ab );
        ab.text           = (s.length > 8) ? (s[0..8] ~ "...") : s;
        ab.rect.x         = 635;
        ab.rect.y         = 0;
        ab.w_mode         = WMODE.FIXED;
        ab.rect.w         = 96;
        ab.h_mode         = HMODE.FIXED;
        ab.rect.h         = 96;
        ab.layout_mode    = LAYOUT_MODE.FIXED;
        ab.borders_enable = true;
        ab.fg             = SDL_Color( 220, 220, 220, SDL_ALPHA_OPAQUE );
        ab.bg             = SDL_Color( 120, 120, 120, SDL_ALPHA_OPAQUE );
    }

    void clear_childs()
    {
        foreach ( ref c; childs )
            c.parent = null;
            // FIXME c.destroy 

        l_child = null;
        r_child = null;
    }
}
