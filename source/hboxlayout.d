module hboxlayout;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import gobject;
import defs;
import layout;


void hbox_layout( GObject o )
{
    // Content Rect
    SDL_Rect crect;
    o.content_rect( &crect );

    // Count childs
    int childs_count;
    foreach ( c; o.childs )
        childs_count++;

    // Same witch
    if ( o.layout_hbox_same_width )
    {
        int same_w = crect.w / childs_count;
        foreach ( c; o.childs )
            ( cast( GObject )c ).rect.w = same_w;
    }

    // Layout
    int x;
    int y = crect.y;
    int h = crect.h;
    foreach ( c; o.childs )
    {
        ( cast( GObject )c ).rect.x = x;
        ( cast( GObject )c ).rect.y = y;
        x += ( cast( GObject )c ).rect.w;
        ( cast( GObject )c ).rect.h = h;
    }
}
