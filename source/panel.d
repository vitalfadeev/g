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
import tools;
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
    SDL_TimerID timer;
    Uint32      timer_interval = 1000; // ms
    

    ~this()
    {
        if ( timer )
            SDL_RemoveTimer( timer );
    }


    override
    size_t main( SDL_Event* e )
    {
        if ( e.type == OP.TIMER ) return timer_callback( e );
        return super.main( e );
    }


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


    override
    void render( SDL_Renderer* renderer )
    {
        super.render( renderer );

        // Add Timer
        add_timer();
    }


    //
    void add_timer()
    {
        if ( !timer )
            timer = 
                SDL_AddTimer( 
                    timer_interval, 
                    &_timer_callback, 
                    cast( void* )this  // FIXME
                );        
    }


    //
    size_t timer_callback( SDL_Event* e )
    {
        // Update
        update_clock();

        // Render
        push_render();

        return 0;
    }


    //
    void push_timer()
    {
        // Create new SDL event
        // Push in SDL Event Loop
        SDL_Event e;
        e.type          = cast( SDL_EventType )OP.TIMER;
        e.user.code     = OP.TIMER;
        e.user.data1    = cast( void* )this; // FIXME
        e.user.data2    = null;
        auto res = SDL_PushEvent( &e );

        //  1 - success
        //  0 - filtered
        // <0 - error
        if ( res == 0 )
            throw new Exception( "SDL_PushEvent(): filtered" );
        else if ( res < 0 )
            throw new Exception( "SDL_PushEvent(): error" );
    }
}

extern(C) nothrow 
uint _timer_callback( uint interval, void* param )
{
    uint next_run_interval = 0; // ms

    alias This = param;
    try {
        // Push timer event
        ( cast( panel.Clock )This ).push_timer();

        // Return interval
        next_run_interval = ( cast( panel.Clock )This ).timer_interval;
    } 
    catch ( Throwable e )
        msgbox( e );

    return next_run_interval;
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


