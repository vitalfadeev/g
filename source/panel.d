module panel;

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
import sysmixer;
import sdlexception;


class Panel : GObject
{
    //
}


class Clock : GObject
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


class LBox : GObject
{
    // childs align left
}

class CBox : GObject
{
    // childs align center
}

class RBox : GObject
{
    // childs align right
}

class LMenuButton : Button
{
    //
}


class RMenuButton : Button
{
    override
    size_t click( SDL_Event* e )
    {
        //msgbox( "RMenuButton.click()");
        return 0;
    }


    override
    size_t show_context_menu( SDL_Event* e, SDL_Window* cur_window, SDL_Point* at_point )
    {
        super.show_context_menu( e, cur_window, at_point );

        import popupmenu;
        create_popup_menu( at_point );

        return 0;
    }
}


class SoundIndicator : RMenuButton
{
    float level;

    // icon
    // mouse scroll up   - volume up
    // mouse scroll down - volume down
    override
    size_t mouse_wheel( SDL_Event* e )
    {
        //
        if ( e.wheel.y > 0 ) // scroll up
        {
             // Put code for handling "scroll up" here!
             text = "up";
             try_volume_up();
        }

        else 
        if ( e.wheel.y < 0 ) // scroll down
        {
             // Put code for handling "scroll down" here!
             text = "down";
             try_volume_down();
        }

        if ( e.wheel.x > 0 ) // scroll right
        {
             // ...
        }

        else 
        if ( e.wheel.x < 0 ) // scroll left
        {
             // ...
        }

        return super.mouse_wheel( e );
    }


    void try_volume_up()
    {
        sys_mixer.try_volume_up();

        update_level();
        update_text();
        //update_image();
    }


    void try_volume_down()
    {
        sys_mixer.try_volume_down();

        update_level();
        update_text();
        //update_image();
    }


    void update_level()
    {
        level = _get_current_volume();
    }


    void update_text()
    {
        text = ( level * 100 ).to!string;
    }


    void update_image()
    {
        if ( level == 0 )
            image = "audio-status\\disabled.png";
        else if ( level == 0 )
            image = "audio-status\\mute.png";
        else if ( level < .25 )
            image = "audio-status\\audio-25.png";
        else if ( level < .50 )
            image = "audio-status\\audio-50.png";
        else if ( level < .75 )
            image = "audio-status\\audio-75.png";
        else if ( level == 1.0 )
            image = "audio-status\\audio-100.png";        
    }


    float _get_current_volume()
    {
        return sys_mixer.get_current_volume();
    }
}
