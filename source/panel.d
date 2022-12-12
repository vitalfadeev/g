module panel;

import std.conv;
import std.stdio;
import bindbc.sdl;
import tree;
import gobject;
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
        // State, Childs
        super.mouse_button( e );

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

        return 0;
    }
}


