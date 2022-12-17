module duit;

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

void test()
{
    auto root = read_file( "test.duit" );
    dump_tree2( root );
}

void test1()
{
    auto root = read_file( "panel1.duit" );
    dump_tree2( root );

    auto file = File( "panel1-saved.duit", "w" );
    root.save_childs_recursive( file );
}


void test2()
{
    auto root = read_file( "panel2.duit" );
    dump_tree2( root );

    auto file = File( "panel2-saved.duit", "w" );
    root.save_childs_recursive( file );
}


GObject read_file( string file_name )
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
    Root       root = new Root();
    GObject    e = root;
    IndRec[]   indents;
    indents ~= new IndRec( 0, root );

    foreach ( cline; file.byLine() )
    {
        string line = cline.to!string;

        if ( line.strip.length == 0 )
            continue;

        parse_line( newst, line );
        //write(line);

        if ( newst.indent > st.indent )
            e = e;
        else if ( newst.indent < st.indent )
            e = find_parent( indents, newst.indent, e );
        else if ( newst.indent == st.indent )
            e = find_parent( indents, newst.indent, e );

        if ( newst.has_eq )
            assign_property( e, newst.property, newst.value );
        else
            e = add_child( indents, newst.indent, e, newst.name );

        st = newst;
    }

    return root;
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

GObject add_child( ref IndRec[] indents, size_t indent, GObject e, string name )
{
    GObject c;
    writeln( object.TypeInfo_Class.find( name ) );

    if ( object.TypeInfo_Class.find( name ) is null )
        c = new GObject();
    else
        c = cast( GObject ) Object.factory( name );

    c.duit_class = name;

    indents ~= new IndRec( indent, c );

    e.add_child( c );

    return c;
}


void load_childs( GObject o )
{
    //
}


void save_childs_recursive( GObject o, ref File file, int level=0 )
{
    foreach ( c; o.childs )
    {
        save_child_class( o, file, level );
        save_child_properties( o, file, level );
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


GObject find_parent( ref IndRec[] indents, size_t indent, GObject e )
{
    IndRec cur;

    while ( indents.length > 0 )
    {
        cur = indents.back;

        if ( cur.indent < indent )
            return cur.e;

        indents.popBack();
    }

    return cur.e;
}

void assign_property( GObject e, string property, string value )
{
    // property = value

    if ( property == "bindo" ) { 
        e.bindo = cast( GObject )Object.factory( value.strip("\"") ); 
        return; 
    }

    static
    foreach ( p; FieldNameTuple!GObject )
    {
        if ( p == property ) { asgn_property!p( e, value ); return; }
    }

    if ( property == "rect.w" ) { e.rect.w = value.to!(typeof(e.rect.w)); return; }
    if ( property == "rect.x" ) { e.rect.x = value.to!(typeof(e.rect.x)); return; }
    if ( property == "rect.y" ) { e.rect.y = value.to!(typeof(e.rect.y)); return; }
    if ( property == "rect.h" ) { e.rect.h = value.to!(typeof(e.rect.h)); return; }

    if ( property == "text" ) { 
        if ( cast(Button)e )
            (cast(Button)e).text = value.strip("\""); 
        return; 
    }

    writeln( "SKIP: property: ", property );
}

void asgn_property( string PROP )( GObject e, string value )
{
    //pragma( msg, PROP );
    __traits( getMember, e, PROP ) = 
        string_to_value!( typeof( __traits( getMember, e, PROP ) ) )( value );
}


//void string_to_value( TYPE:enum )( string value )
//{
//    //
//}


auto string_to_value( T )( string value )
    if ( is( T == string ) )
{
    return value;
}

auto string_to_value( T )( string value )
    if ( is( T == ubyte ) )
{
    return ubyte.init;
}

auto string_to_value( T )( string value )
    if ( is( T == SDL_Color ) )
{
    return SDL_Color.init;
}

auto string_to_value( T )( string value )
    if ( is( T == SDL_Rect ) )
{
    return SDL_Rect.init;
}

auto string_to_value( T )( string value )
    if ( is( T == int ) )
{
    return value.to!int;
}

auto string_to_value( T )( string value )
    if ( is( T == bool ) )
{
    return ( value == "true" ) ? true : false;
}

auto string_to_value( T )( string value )
    if ( is( T == BitFlags!STATES ) )
{
    return STATE_NORMAL;
}

auto string_to_value( T )( string value )
    if ( is( T == GObject ) )
{
    return null;
}

auto string_to_value( T )( string value )
    if ( is( T == enum ) )
{
    static
    foreach ( emb; EnumMembers!T )
    {
        if ( T.stringof ~ "." ~ emb.stringof == value ) return emb; // WMODE.FIXED
        if ( emb.stringof == value ) return emb;                    // FIXED
    }

    return T.init; // default
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


void dump_tree2( GObject o, int level=0 )
{
    writeln( replicate( "  ", level ), o, ": ", o.duit_class, ": ", o.w_mode, ": ", o.layout_mode );

    foreach ( c; o.childs )
        dump_tree2( c, level+1 );

}
