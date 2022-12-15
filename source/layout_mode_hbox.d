module layout_mode_hbox;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import gobject;
import defs;
import layout;


void apply( GObject o )
{
    // Content Rect
    SDL_Rect crect;
    o.content_rect( &crect );

    // Count childs
    int childs_count;
    foreach ( c; o.childs )
        childs_count++;


    // Layout
    int x = crect.x;
    int y = crect.y;
    int h = crect.h;
    int w =
        ( o.layout_mode_hbox_same_width ) ?
            ( crect.w / childs_count ) : // Same width
            ( crect.w );
    foreach ( c; o.childs )
    {
        ( cast( GObject )c ).rect.x = x;
        ( cast( GObject )c ).rect.y = y;
        ( cast( GObject )c ).rect.h = h;
        x += ( cast( GObject )c ).rect.w;

        if ( o.layout_mode_hbox_same_width )
            ( cast( GObject )c ).rect.w = w;
    }
}
