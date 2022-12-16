module vboxlayout;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import gobject;
import defs;
import layout;


class VBoxLayout : Layout
{
    override
    void layout()
    {
        int y;

        foreach ( c; childs )
        {
            ( cast( GObject )c ).rect.y = y;
            y += ( cast( GObject )c ).rect.h;
        }
    }
}
