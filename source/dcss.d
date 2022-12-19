module dcss;

import std.algorithm;
import std.typecons;
import std.uni;
import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.range;
import std.functional;
import std.traits;
import bindbc.sdl;
import root;
import gobject;
import states;
import button;
import duit : string_to_value;

// Load CSS
//   button.Button
//     bg = SDL_Color( 0, 0, 0, SDL_ALPHA_OPAQUE )
//  
//   button.Button:STATE_PRESSED
//     bg = SDL_Color(  48,  48, 48, SDL_ALPHA_OPAQUE )
//
//  CSS
//    CSSSheet
//      class_name = button.Button
//      state      = 
//      props      = 
//        CSSProperty!"bg"( SDL_Color( ... ) )
//    CSSSheet
//      class_name = button.Button
//      state      = STATE_PRESSED
//      props      = 
//        CSSProperty!"bg"( SDL_Color( ... ) )
// 
// Each Object 
//   Each Style
//     Test Object For Style
//       class "button.Button"
//         Apply Style
//           bg = SDL_Color( 0, 0, 0, SDL_ALPHA_OPAQUE )
//     
//     Test Object For Style
//       class "button.Button" and ( state & STATE_PRESSED )
//         Apply Style
//           bg = SDL_Color( 48, 48, 48, SDL_ALPHA_OPAQUE )
//
// CSS
//   CSSProperty[] props;
//
// CSSProperty
//   property_name
//   
//   apply( o )
//     ...
//
// CSSProperty!PNAME : CSSProperty
//   T value
//
//   apply( o )
//     o.PNAME = value
//

void test_css()
{
    auto styles = read_file( "style.dcss" );
    dump_css( styles );
}

CSS read_file( string file_name )
{
    // line-by-line
    //   if indent >
    //     inside this element
    //   if indent <
    //     find parent element
    //   if indent ==
    //     find parent element ( pren parent )
    //   
    // xxx
    //    if =
    //      split by =
    //        property, value
    //        e.property = value
    //    else
    //      add child

    // properties
    //   rect | - direct assign
    //   icon |   rect.w = value.to!( typeof( rect.w ) )
    //   text |
    //   exec   - properties["exec"] = value

    // values
    //   WMODE.DISPLAY is WMODE.DISPLAY
    //   "" is ""
    //   96 is 96
    //   SDL_Color(   0,   0,  0, SDL_ALPHA_OPAQUE ) is SDL_Color(   0,   0,  0, SDL_ALPHA_OPAQUE )


    auto file = File( file_name );

    ParseState st;
    ParseState newst;
    CSS        css = new CSS();
    CSSSheet   sheet = new CSSSheet();
    sheet.class_name = "GObject";
    css.sheets ~= sheet;

    foreach ( cline; file.byLine() )
    {
        string line = cline.to!string;

        if ( line.strip.length == 0 )
            continue;

        parse_line( newst, line );

        // sheet
        if ( newst.indent == 0 ) 
        {
            sheet = new CSSSheet();
            sheet.class_name = newst.name;
            css.sheets ~= sheet;
        }

        // property
        else 
        {
            auto prop = create_css_property( newst.property, newst.value );
            if ( prop !is null )
                sheet.props ~= prop;
        }

        st = newst;
    }

    return css;
}


void parse_line( ref ParseState st, string s )
{
    // tokent:
    //   indent property = value
    //   indent name
    size_t indent = s.countUntil!("a != ' '")();
    string s2     = s[ indent .. $ ];
    auto   splits = s2.split( "=" );

    // Save
    // parent 
    //   prop = value
    if ( splits.length > 1 )
    {    
        st.indent   = indent;
        st.name     = "";
        st.property = splits[0].strip;
        st.value    = splits[1].strip;
        st.has_eq   = true;
    }

    // parent
    //   child
    else
    {    
        st.indent   = indent;
        st.name     = s2.strip;
        st.property = "";
        st.value    = "";
        st.has_eq   = false;
    }
}


class IndRec
{
    size_t  indent;
    GObject e;

    this( size_t indent, GObject e )
    {
        this.indent = indent;
        this.e      = e;
    }
}


void load_childs( GObject o )
{
    //
}


void save_childs_recursive( GObject o, ref File file, int level=0 )
{
    foreach ( c; o.childs )
    {
        save_child_class( c, file, level );
        save_child_properties( c, file, level );
        file.writeln();
        save_childs_recursive( c, file, level+1 );
    }
}


void save_child_class( GObject o, ref File file, int level )
{
    file.writeln( 
        replicate( "  ", level ), 
        o
    );
}


void save_child_properties( GObject o, ref File file, int level )
{
    bool[string] ignore;
    ignore["l_child"] = true;
    ignore["r_child"] = true;
    ignore["parent"]  = true;
    ignore["l"]       = true;
    ignore["r"]       = true;
    ignore["duit_class"] = true;

    size_t max_field_name_len;

    static
    foreach ( field_name; FieldNameTuple!GObject )
        if ( field_name.length > max_field_name_len )
            max_field_name_len = field_name.length;

    static
    foreach ( field_name; FieldNameTuple!GObject )
    {
        if ( field_name in ignore ) {}
        else
            if ( __traits( getMember, o, field_name ) !is __traits( getMember, o, field_name ).init )
            {
                file.writeln( 
                    "  ",
                    replicate( "  ", level ), 
                    field_name.leftJustify( max_field_name_len ), 
                    " = ", 
                    __traits( getMember, o, field_name ) 
                );
            }
    }
}


CSSPropertyBase create_css_property( string property, string value )
{
    CSSPropertyBase prop;

    if ( property == "bindo" )
        return new CSSProperty!"bindo"(
            //GObject.factory( value.strip("\"") )
            new GObject() // FIXME
        );

    static
    foreach ( p; FieldNameTuple!GObject )
    {
        if ( p == property ) return cr_property!p( value );
    }

    //if ( property == "rect.w" ) { e.rect.w = value.to!(typeof(e.rect.w)); return; }
    //if ( property == "rect.x" ) { e.rect.x = value.to!(typeof(e.rect.x)); return; }
    //if ( property == "rect.y" ) { e.rect.y = value.to!(typeof(e.rect.y)); return; }
    //if ( property == "rect.h" ) { e.rect.h = value.to!(typeof(e.rect.h)); return; }

    writeln( "SKIP: property: ", property );

    return null;
}

CSSPropertyBase cr_property( string PROP )( string value )
{
    return
        new CSSProperty!PROP(
            string_to_value!( typeof( __traits( getMember, GObject, PROP ) ) )( value )
        );
}


// SDL_Rect(0, 0, 0, 29)
//auto string_to_value( T )( string value )
//    if ( is( T == struct ) )
//{
//    //
//}

struct ParseState
{
    size_t indent;
    string property;
    string value;
    bool   has_eq;
    string name;
}


void dump_css( CSS css )
{
    writeln( "style.dcss:" );

    foreach ( sheet; css.sheets )
    {
        writeln( "  ", sheet );

        foreach ( prop; sheet.props )
            writeln( "    ", prop );
    }
}


//
class CSS
{
    CSSSheet[] sheets;
}

class CSSSheet
{
    string            class_name;
    BitFlags!STATES   state;
    CSSPropertyBase[] props;

    void apply( GObject o ) {}

    override
    string toString()
    {
        return "CSSSheet( " ~ class_name ~  " )";
    }
}

class CSSPropertyBase
{
    string name;

    void apply( GObject o )
    {
        //
    }
}

class CSSProperty( string PNAME ) : CSSPropertyBase
{
    alias T = typeof( __traits( getMember, GObject, PNAME ) );
    T value;

    this( T value )
    {
        this.value = value;
    }

    override
    void apply( GObject o )
    {
        __traits( getMember, o, PNAME ) = value;
    }

    override
    string toString()
    {
        return "CSSProperty!" ~ PNAME ~ "( " ~ value.to!string ~ " )";
    }
}


//CSSPropertyBase CSSPropertyFactory( string name )
//{
//    static
//    foreach ( field_name; FieldNameTuple!GObject )
//        static
//        if ( [ "l_child", "r_child", "parent", "l", "r", "duit_class" ].canFind( field_name ) ) 
//            if ( field_name == name )
//                return new CSSProperty!field_name(); // Create class

//    return new CSSPropertyBase();
//}

// Mega
//
// CSS
//   // CSSSheet[] links;
//   // GObject[]  links;
//
//   (Object[])[ cast( void* )T.classinfo ] links;
//  
//   add( T )( T c )
//     links[ cast( void* )T.classinfo ] ~= c;
//     c.links[ cast( void* )typeof( this ).classinfo ] ~= this;
//
//
// CSSSheet
//   CSS[] links;
//
//   add( c )
//     links ~= c
//     c.links ~= this
//
// .classinfo is reference to object.TypeInfo_Class
