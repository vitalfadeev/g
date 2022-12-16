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
            c.rect.y = y;
            y += c.rect.h;
        }
    }
}
