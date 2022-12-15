module gobject;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import style;
import states;
import treeobject;
import sdlexception;
import layout_mode_hbox;


class GObject : TreeObject
{
    SDL_Rect  rect;
    ubyte     flags;
    SDL_Color fg;
    SDL_Color bg;

    WMODE w_mode;
    HMODE h_mode;

    int padding_l; // left
    int padding_t; // top
    int padding_r; // right
    int padding_b; // bottom

    BitFlags!States state;

    LAYOUT_MODE layout_mode;
    bool  layout_mode_hbox_same_width = true;
    bool  layout_mode_hbox_fixed_width = false;
    int   layout_mode_hbox_child_width = 0; // px
    //WMODE layout_mode_hbox_child_w_mode = WMODE.FIXED;

    bool borders_enable;


    override
    size_t main( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEBUTTONUP   ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEWHEEL      ) return _mouse_wheel( e );
        if ( e.type == OP.RENDER           ) return render( e );
        //if ( e.type == OP.DRAWED ) return this.drawed( e );
        return super.main( e );
    }


    bool hit_test( Sint32 x, Sint32 y )
    {
        SDL_Point point = SDL_Point( x, y );
        return SDL_PointInRect( &point, &rect );
    }


    size_t _mouse_wheel( SDL_Event* e )
    {
        int x;
        int y;
        SDL_GetMouseState( &x, &y );
        import tools;

        if ( hit_test( x, y ) ) 
            mouse_wheel( e );

        return 0;
    }


    size_t mouse_wheel( SDL_Event* e )
    {
        // State
        change_state( e );

        // Styles
        apply_styles_recursive( this );

        // Remder
        push_render();

        // Childs
        this.each_child_main( e );

        return 0;
    }


    size_t _mouse_button( SDL_Event* e )
    {
        if ( hit_test( e.button.x, e.button.y ) ) 
            mouse_button( e );

        return 0;
    }


    size_t mouse_button( SDL_Event* e )
    {
        // State
        change_state( e );

        // Styles
        apply_styles_recursive( this );

        // Remder
        push_render();

        // Childs
        this.each_child_main( e );

        // Context Menu
        if ( e.button.type == SDL_MOUSEBUTTONDOWN )
        if ( e.button.button == SDL_BUTTON_RIGHT )
        {
            SDL_Window* cur_window;
            cur_window = SDL_GetWindowFromID( e.button.windowID );

            int wx;
            int wy;
            SDL_GetWindowPosition( cur_window, &wx, &wy );

            SDL_Point at_point;
            at_point.x = e.button.x + wx;
            at_point.y = e.button.y + wy;

            return show_context_menu( e, cur_window, &at_point );
        }

        return 0;
    }


    void change_state( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN )
            state |= STATE_PRESSED;
        else
        if ( e.type == SDL_MOUSEBUTTONUP )
            state &= ~STATE_PRESSED;        
    }


    void layout()
    {
        // Layout This
        if ( w_mode == WMODE.DISPLAY )
        {        
            SDL_DisplayMode display_mode;
            SDL_GetCurrentDisplayMode( 0, &display_mode );
            rect.w = display_mode.w;
        }

        //
        else
        if ( w_mode == WMODE.FIXED )
        {
            //
        }


        if ( h_mode == HMODE.DISPLAY )
        {        
            SDL_DisplayMode display_mode;
            SDL_GetCurrentDisplayMode( 0, &display_mode );
            rect.h = display_mode.h;
        }

        //
        switch ( layout_mode )
        {
            case LAYOUT_MODE.HBOX: layout_mode_hbox.apply( this ); break;
            default:
        }

        // Layout Childs
        foreach( c; childs )
            ( cast( GObject )c ).layout();
    }


    size_t render( SDL_Event* e )
    {
        return 0;
    }


    void render( SDL_Renderer* renderer )
    {
        // bg, borders
        render_bg( renderer );
        render_borders( renderer );

        // Render childs
        render_childs( renderer );
    }


    void render_bg( SDL_Renderer* renderer )
    {
        // fill rect x, y, w, h
        SDL_SetRenderDrawColor( renderer, bg.r, bg.g, bg.b, bg.a  );
        SDL_RenderFillRect( renderer, &rect );
    }


    void render_borders( SDL_Renderer* renderer )
    {
        // borders rect x, y, w, h
        if ( borders_enable )
        {        
            SDL_SetRenderDrawColor( renderer, fg.r, fg.g, fg.b, fg.a  );
            SDL_RenderDrawRect( renderer, &rect );
        }
    }


    void render_childs( SDL_Renderer* renderer )
    {
        foreach ( c; childs )
            (cast( GObject )c).render( renderer );
    }


    void push_render()
    {
        // Create new SDL render event
        // Push in SDL Event Loop
        SDL_Event e;
        e.type          = cast( SDL_EventType )OP.RENDER;
        e.user.code     = OP.RENDER;
        e.user.data1    = cast( void* )this; // FIXME
        e.user.data2    = null;
        auto res = SDL_PushEvent( &e );
        //  1 - success
        //  0 - filtered
        // <0 - error
        if ( res == 0 )
            throw new SDLException( "SDL_PushEvent(): filtered" );
        else if ( res < 0 )
            throw new SDLException( "SDL_PushEvent(): error" );
    }


    //
    void content_rect( SDL_Rect* crect )
    {
        crect.x = rect.x + padding_l;
        crect.y = rect.y + padding_t;
        crect.w = rect.w - padding_l - padding_r;
        crect.h = rect.h - padding_t - padding_b;
    }


    //
    void center_1_child()
    {
        //
    }


    //
    void center_all_childs()
    {
        //
    }


    //
    size_t show_context_menu( SDL_Event* e, SDL_Window* cur_window, SDL_Point* at_point )
    {
        return 0;
    }
}


//
void center_rect_in_rect( SDL_Rect* inner_rect, SDL_Rect* outer_rect )
{
    void center_x( SDL_Rect* inner_rect, SDL_Rect* outer_rect )
    {
        // Center: Lon[g t]ext
        if ( inner_rect.w > outer_rect.w )
            inner_rect.x = outer_rect.x - ( inner_rect.w - outer_rect.w ) / 2;

        // Center: [ Short text ]
        else
            inner_rect.x = outer_rect.x + ( outer_rect.w - inner_rect.w ) / 2;
    }

    void center_y( SDL_Rect* inner_rect, SDL_Rect* outer_rect )
    {
        // Center: Lon[g t]ext
        if ( inner_rect.h > outer_rect.h )
            inner_rect.y = outer_rect.y - ( inner_rect.h - outer_rect.h ) / 2;

        // Center: [ Short text ]
        else
            inner_rect.y = outer_rect.y + ( outer_rect.h - inner_rect.h ) / 2;
    }

    center_x( inner_rect, outer_rect );
    center_y( inner_rect, outer_rect );
}


//
enum HMODE
{
    FIXED,
    BY_CHILD,
    DISPLAY,
    PARENT,
}

enum WMODE
{
    FIXED,
    BY_CHILD,
    DISPLAY,
    PARENT,
}


enum LAYOUT_MODE
{
    FIXED,
    LEFT,
    RIGHT,
    CENTER,
    HBOX,
    VBOX,
}


void layout_LEFT( GObject o )
{
    //
}
