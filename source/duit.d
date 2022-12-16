module duit;

import std.algorithm;
import std.uni;
import std.stdio;
import std.string;
import std.array;
import std.conv;
import root;
import gobject;
import std.range;
import std.functional;

void test1()
{
    auto root = read_file( "test.duit" );
    dump_tree2( root );
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

        if ( newst.indent > st.indent )
            e = e;
        else if ( newst.indent < st.indent )
            e = find_parent( indents, newst.indent, e );
        else if ( newst.indent == st.indent )
            e = find_parent( indents, newst.indent, e );

        if ( newst.has_eq ) {
            //assign_property( e, newst.property, newst.value );
        }
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
    auto c = new GObject();
    c.duit_class = name;
    indents ~= new IndRec( indent, c );
    e.add_child( c );
    return c;
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

/*
void assign_property( GObject e, string property, string value )
{
    // property = value

    static
    foreach ( p; Properties!GObject )
    {
        if ( p == property ) asgn_property!p( e, value );
    }
}

void asgn_property( PROP )( GObject e, string value )
{
    auto memb = get_member( GObject, PROP );
    auto TYPE = typeof( memb );
    auto tvalue = string_to_value!TYPE( value );
    set_memb( e, memb, tvalue );
}


//void string_to_value( TYPE:enum )( string value )
//{
//    //
//}


auto string_to_value( TYPE:enum )( string value )
{
    static
    foreach ( en; enum_members!enum )
    {
        if ( en.to!string == value ) return en;
    }

    return TYPE.init; // default
}
*/
struct ParseState
{
    size_t indent;
    string property;
    string value;
    bool   has_eq;
    string name;
}


void dump_tree2( GObject root, int level=0 )
{
    writeln( replicate( "  ", level ), root, ": ", root.duit_class );

    foreach ( c; root.childs )
        dump_tree2( c, level+1 );

}
