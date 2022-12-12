module gobject;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import style;
import states;
import treeobject;


class GObject : TreeObject
{
    SDL_Rect  rect;
    ubyte     flags;
    SDL_Color fg;
    SDL_Color bg;

    SizeMode  size_mode;

    BitFlags!States state;


    override
    size_t main( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEBUTTONUP   ) return _mouse_button( e );
        if ( e.type == OP.RENDER           ) return render( e );
        //if ( e.type == OP.DRAWED ) return this.drawed( e );
        return super.main( e );
    }


    bool hit_test( Sint32 x, Sint32 y )
    {
        SDL_Point point = SDL_Point( x, y );
        return SDL_PointInRect( &point, &rect );
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
        if ( e.type == SDL_MOUSEBUTTONDOWN )
            state |= STATE_PRESSED;
        else
        if ( e.type == SDL_MOUSEBUTTONUP )
            state &= ~STATE_PRESSED;

        // Styles
        apply_styles( this );

        // Remder
        push_render();

        // Childs
        this.each_child_main( e );

        return 0;
    }


    void layout()
    {
        // Self layout
        // ...

        // Childs layout
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
        SDL_SetRenderDrawColor( renderer, fg.r, fg.g, fg.b, fg.a  );
        SDL_RenderDrawRect( renderer, &rect );
    }


    void render_childs( SDL_Renderer* renderer )
    {
        this.each_child_render( renderer );        
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
        SDL_PushEvent( &e );
    }
}


//
enum SizeMode
{
    FIXED,
    BY_CHILD,
}


//
void each_child_render( GObject root, SDL_Renderer* renderer )
{
    foreach ( c; root.childs )
        (cast( GObject )c).render( renderer );
}
