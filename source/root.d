module root;

import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import defs;
import treeobject;
import gobject;


class Root : GObject
{
    override
    bool hit_test( Sint32 x, Sint32 y )
    {
        return true;
    }

    //
    void render( SDL_Renderer* renderer, SDL_Rect* viewrect )
    {
        if ( SDL_HasIntersection( viewrect, &rect ) )
            super.render( renderer );
    }

    override
    void push_render()
    {
        foreach ( c; childs )
            c.push_render();
    }
}


//
void walk_in_width( FUNC )( GObject root, FUNC callback )
{
    callback( root );

    foreach ( c; root.childs )
        walk_in_width( c, callback );
}


//
void dump_tree( Root root )
{
    foreach ( c; root.childs )
        writeln( "  ", c );
}
