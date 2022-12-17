module gobject;

import std.stdio;
import std.string;
import std.typecons;
import bindbc.sdl;
import op;
import style;
import states;
import treeobject;
import sdlexception;
import layout_mode_hbox;


class GObject
{
    mixin TreeObject!GObject;
    mixin StateObject!GObject;
    mixin LayoutObject!GObject;
    mixin EventObject!GObject;
    mixin RenderObject!GObject;
    mixin TextObject!GObject;
    mixin ImageObject!GObject;

    ubyte flags;

    string duit_class;


    bool hit_test( Sint32 x, Sint32 y )
    {
        SDL_Point point = SDL_Point( x, y );
        return SDL_PointInRect( &point, &rect );
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
void each_child( FUNC )( GObject root, FUNC callback )
{
    foreach ( c; root.childs )
        callback( c );
}


//
size_t each_child_main( GObject root, SDL_Event* e )
{
    size_t res;

    foreach ( c; root.childs )
        res = c.main( e );

    return res;
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


enum CHILDS_ALIGN
{
    LEFT,
    CENTER,
    RIGHT,
}


void layout_LEFT( GObject o )
{
    //
}


mixin template LayoutObject( T )
{
    WMODE w_mode;
    HMODE h_mode;

    LAYOUT_MODE layout_mode;
    bool  layout_mode_hbox_same_width = true;
    bool  layout_mode_hbox_fixed_width = false;
    int   layout_mode_hbox_child_width = 0; // px
    //WMODE layout_mode_hbox_child_w_mode = WMODE.FIXED;

    CHILDS_ALIGN childs_align;


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
            c.layout();
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
}


mixin template StateObject( T )
{
    BitFlags!STATES state;


    void change_state( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN )
            state |= STATE_PRESSED;
        else
        if ( e.type == SDL_MOUSEBUTTONUP )
            state &= ~STATE_PRESSED;        
    }
}


mixin template EventObject( T )
{
    GObject bindo;


    size_t main( SDL_Event* e )
    {
        if ( bindo !is null ) bindo.main( e );

        if ( e.type == SDL_MOUSEBUTTONDOWN ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEBUTTONUP   ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEWHEEL      ) return _mouse_wheel( e );
        if ( e.type == OP.RENDER           ) return render( e );
        //if ( e.type == OP.DRAWED ) return this.drawed( e );
        return this.each_child_main( e );
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
        //writeln( this, ": ", e.type );
        //writeln( this, ":   ", e.button.x, ", ", e.button.y );
        //writeln( this, ":   ", rect.x, ", ", rect.y, " ", rect.w, "x", rect.h );
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


    size_t render( SDL_Event* e )
    {
        SDL_Renderer* renderer = cast( SDL_Renderer* )e.user.data2;

        // Layout
        layout();

        // Render
        this.render( renderer );

        // Raxterize
        SDL_RenderPresent( renderer );

        return 0;
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
}


mixin template RenderObject( T )
{
    SDL_Rect  rect;
    SDL_Color fg;
    SDL_Color bg;

    int padding_l; // left
    int padding_t; // top
    int padding_r; // right
    int padding_b; // bottom

    bool borders_enable = false;


    void render( SDL_Renderer* renderer )
    {
        // bg, borders
        render_bg( renderer );
        render_borders( renderer );
        render_text( renderer );
        render_image( renderer );

        // Render childs
        render_childs( renderer );
    }


    void render_bg( SDL_Renderer* renderer )
    {
        if ( bg.a != 0 )
        {        
            // fill rect x, y, w, h
            SDL_SetRenderDrawColor( renderer, bg.r, bg.g, bg.b, bg.a );
            SDL_RenderFillRect( renderer, &rect );
        }
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
            c.render( renderer );
    }


    //
    void content_rect( SDL_Rect* crect )
    {
        crect.x = rect.x + padding_l;
        crect.y = rect.y + padding_t;
        crect.w = rect.w - padding_l - padding_r;
        crect.h = rect.h - padding_t - padding_b;
    }
}


mixin template TextObject( T )
{
    string text;
    string font_file = "InputSansCondensed-Regular.ttf";
    int    font_size = 17;


    void render_text( SDL_Renderer* renderer )
    {
        if ( text.length > 0 )
        {
            // Font
            TTF_Font* font = TTF_OpenFont( font_file.toStringz, font_size );
            if ( !font )
                throw new SDLException( "TTF_OpenFont()" );

            //TTF_SetFontStyle( font, TTF_STYLE_BOLD );

            // Color
            SDL_Color white = { 255, 255, 255 };
            SDL_Color bg_c  = { 0, 0, 0 };

            // Text Rect
            SDL_Rect trect;
            {
                // Content Rect
                SDL_Rect crect;
                content_rect( &crect );

                // Text Rect
                int w;
                int h;
                if ( TTF_SizeText( font, text.toStringz, &w, &h ) )
                    throw new SDLException( "TTF_SizeText()" );
                trect.x = crect.x;
                trect.y = crect.y;
                trect.w = w;
                trect.h = h;

                // Center Text inside Content Rect
                center_rect_in_rect( &trect, &crect );

                // Clip
                SDL_RenderSetClipRect( renderer, &crect );
            }

            // Render
            SDL_Surface* text_surface =
                TTF_RenderText_Solid( font, text.toStringz, white ); 
                //TTF_RenderText_Shaded( font, "Text", white, bg_c ); 

            SDL_Texture* text_texture = 
                SDL_CreateTextureFromSurface( renderer, text_surface );

            // Copy
            SDL_RenderCopy( renderer, text_texture, null, &trect );

            // Free
            SDL_RenderSetClipRect( renderer, null );
            TTF_CloseFont( font );
            SDL_FreeSurface( text_surface );
            SDL_DestroyTexture( text_texture );
        }
    }


    int text_width()
    {
        // Text
        TTF_Font* font = TTF_OpenFont( font_file.toStringz, font_size );
        if ( !font )
            throw new SDLException( "TTF_OpenFont()" );

        //TTF_SetFontStyle( font, TTF_STYLE_BOLD );

        int w;
        int h;
        if ( TTF_SizeText( font, text.toStringz, &w, &h ) )
            throw new SDLException( "TTF_SizeText()" );

        TTF_CloseFont( font );

        return w;
    }
}


mixin template ImageObject( T )
{
    string image;


    void render_image( SDL_Renderer* renderer )
    {
        if ( image.length > 0 )
        {
            string real_file = image;

            // SDL_IMG
            SDL_Surface* img_surface = IMG_Load( real_file.toStringz );

            if ( img_surface is null ) 
            {
                import std.format;
                throw new SDLException( 
                    format!
                        "could not load image: %s"
                        ( IMG_GetError() )
                );
            }

            // 
            SDL_Rect imgrect;
            imgrect.x = rect.x + 55;
            imgrect.y = rect.y;
            imgrect.w = 28;
            imgrect.h = 28;

            //
            SDL_Texture* img_texture = 
                SDL_CreateTextureFromSurface( renderer, img_surface );

            // Copy
            SDL_RenderCopy( renderer, img_texture, null, &imgrect );

            //
            SDL_FreeSurface( img_surface );
            SDL_DestroyTexture( img_texture );
        }
    }
}
