module panel;

import std.conv;
import std.format;
import std.stdio;
import bindbc.sdl;
import tree;
import treeobject;
import gobject;
import op;
import defs;
import button;
import text;
import style;


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


class Clock : Text
{
    override
    size_t mouse_button( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN )
        {
            // Update
            update_clock();

            // Render
            push_render();

            // Childs
            this.each_child_main( e );
        }

        return 0;
    }


    void update_clock()
    {
        import std.datetime.systime : Clock, SysTime;
        import std.datetime.timezone : LocalTime;

        SysTime today = Clock.currTime();
        assert( today.timezone is LocalTime() );

        text = 
            format!
                " %0.2d:%0.2d:%0.2d"
                ( today.hour, today.minute, today.second );
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
        // State
        change_state( e );

        // Styles
        apply_styles( this );

        // Remder
        push_render();

        // Popup
        if ( e.button.type == SDL_MOUSEBUTTONDOWN )
        if ( e.button.button == SDL_BUTTON_RIGHT )
        {
            import popupmenu;

            SDL_Window* window;
            window = SDL_GetWindowFromID( e.button.windowID );

            int wx;
            int wy;
            SDL_GetWindowPosition( window, &wx, &wy );

            SDL_Point at_point;
            at_point.x = e.button.x + wx;
            at_point.y = e.button.y + wy;

            create_popup_menu( &at_point );
        }

        // Childs
        this.each_child_main( e );

        return 0;
    }
}


