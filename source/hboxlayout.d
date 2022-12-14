module hboxlayout;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import gobject;
import defs;
import layout;


class HBoxLayout : Layout
{
    bool same_width = true;

    override
    void layout()
    {
        //
        int childs_count;
        foreach ( c; childs )
            childs_count++;

        //
        int w = rect.w / childs_count;
        foreach ( c; childs )
            ( cast( GObject )c ).rect.w = w;

        //
        int x;
        int h = rect.h;
        foreach ( c; childs )
        {
            ( cast( GObject )c ).rect.x = x;
            x += ( cast( GObject )c ).rect.w;
            ( cast( GObject )c ).rect.h = h;
        }
    }
}
