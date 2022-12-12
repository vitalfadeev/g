module vboxlayout;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import tree;
import op;
import gobject;
import button;
import defs;


class VBoxLayout : GObject
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
