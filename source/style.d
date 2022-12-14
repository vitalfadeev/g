module style;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import defs;
import states;
import gobject;


static 
Style[] styles;


// 
class Style
{
    string class_name;
    BitFlags!States state;

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


class Style4 : Style
{
    this()
    {
        class_name = "panel.Clock";
        state = STATE_NORMAL;
    }

    override
    void apply( GObject o )
    {
        import panel;
        ( cast( Clock )o ).font_file = "InputSansCondensed-Regular.ttf";
        ( cast( Clock )o ).font_size = 32;
    }
}


//
void apply_styles( GObject o )
{
    foreach ( style; styles )
        apply_style( o, style );
}


//
void apply_style( GObject o, Style style )
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
void create_style()
{
    styles ~= new Style1();
    styles ~= new Style2();
    styles ~= new Style3();
    styles ~= new Style4();    
}

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


