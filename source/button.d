module button;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import defs;


class Button : GObject
{
    string text;

    BitFlags!ButtonStates state;


    override
    size_t main( SDL_Event* e )
    {
        //if ( e.type == SDL_MOUSEBUTTONDOWN ) return this.mouse_button( e );
        //if ( e.type == SDL_MOUSEBUTTONUP   ) return this.mouse_button( e );
        //if ( e.type == SDL_KEYDOWN         ) return this.key( e );
        //if ( e.type == SDL_KEYUP           ) return this.key( e );
        //if ( e.type == OP.CLICK            ) return this.click( e );
        //if ( e.type == OP.CLICKED          ) return this.clicked( e );
        return super.main( e );
    }

    size_t key( SDL_Event* e )
    {
        return 0;
    }


    override
    size_t mouse_button( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN )
            state = STATE_PRESSED;
            //bg = SDL_Color(  48,  48, 48, SDL_ALPHA_OPAQUE );
        else
        if ( e.type == SDL_MOUSEBUTTONUP )
            state = STATE_NORMAL;

        //
        apply_styles( this );

        //
        push_render();

        super.mouse_button( e );

        return 0;
    }


    size_t click( SDL_Event* e )
    {
        return 0;
    }

    override
    void render( SDL_Renderer* renderer )
    {
        // bg, border
        super.render( renderer );

        // Text
        SDL_SetRenderDrawColor( renderer, 198, 198, 198, 255  );
        int text_w =  2;
        int text_h = 16;
        SDL_Rect r = 
            SDL_Rect( 
                rect.x + rect.w / 2 - text_w / 2, 
                rect.y + rect.h / 2 - text_h / 2, 
                text_w, 
                text_h 
            );
        SDL_RenderFillRect( renderer, &r );
    }
}


//
enum ButtonStates
{
    NORMAL   = 1 << 0,
    PRESSED  = 1 << 1,
    DISABLED = 1 << 2,
    HOVER    = 1 << 3
}

BitFlags!ButtonStates STATE_PRESSED = ButtonStates.PRESSED;
BitFlags!ButtonStates STATE_NORMAL  = ButtonStates.NORMAL;


//
// CSS
//
// Button
// {
//   bg = rgb(SDL_Color(  48,  48, 0 );
// }
//
// Button:pressed
// {
//   bg = rgb(SDL_Color(  48,  48, 48 );
// }


static 
Style[] styles;


//
void apply_styles( Button o )
{
    foreach ( style; styles )
        apply_style( o, style );
}


//
void apply_style( Button o, Style style )
{
    bool test_style( Style style )
    {
        if ( is_class_base_of_classname( o.classinfo, style.class_name ) )
        {
            if ( style.state == STATE_NORMAL )
                return true;

            if ( o.state & style.state )
                return true;
        }

        return false;
    }

    if ( test_style( style ) )
    {
        style.apply( o );
    }
}


//
bool is_class_base_of_classname( TypeInfo_Class cls, string name )
{
    // object.Object
    // tree.TreeObject
    // tree.GObject
    // button.Button
    // panel.LMenuButton
    for ( auto cur = cls; cur !is null; cur = cur.base )
        if ( cur.name == name )
            return true;

    return false;
}


// 
class Style
{
    string class_name;
    BitFlags!ButtonStates state;

    void apply( GObject o ) {}
}


class Style1 : Style
{
    this()
    {
        class_name = "panel.RMenuButton";
        state = STATE_NORMAL;
    }

    override
    void apply( GObject o )
    {
        o.bg = SDL_Color(  48, 0,  48, SDL_ALPHA_OPAQUE );
        o.fg = SDL_Color( 255, 0, 255, SDL_ALPHA_OPAQUE );
    }
}


class Style2 : Style
{
    this()
    {
        class_name = "panel.LMenuButton";
        state = STATE_NORMAL;
    }

    override
    void apply( GObject o )
    {
        o.bg = SDL_Color( 0,  48,  48, SDL_ALPHA_OPAQUE );
        o.fg = SDL_Color( 0, 255, 255, SDL_ALPHA_OPAQUE );
    }
}


class Style3 : Style
{
    this()
    {
        class_name = "button.Button";
        state = STATE_PRESSED;
    }

    override
    void apply( GObject o )
    {
        o.bg = SDL_Color(  48,  48, 48, SDL_ALPHA_OPAQUE );
    }
}

