module layout_mode_hbox;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import gobject;
import defs;
import layout;


void apply( GObject o )
{
    // same width
    // custom width
    //   align left
    //   align center
    //   align right
    if ( o.layout_mode_hbox_same_width )
        _same_width( o );
    else
        switch ( o.childs_align )
        {
            case CHILDS_ALIGN.LEFT:   _childs_align_left( o );   break;
            case CHILDS_ALIGN.CENTER: _childs_align_center( o ); break;
            case CHILDS_ALIGN.RIGHT:  _childs_align_right( o );  break;
            default:
        }
}


void _same_width( GObject o )
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
    int w = crect.w / childs_count;

    foreach ( c; o.childs )
    {
        c.rect.x = x;
        c.rect.y = y;
        c.rect.h = h;
        c.rect.w = w;

        x += w;
    }
}

void _childs_align_left( GObject o )
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
        c.rect.x = x;
        c.rect.y = y;
        c.rect.h = h;
        x += c.rect.w;

        if ( o.layout_mode_hbox_same_width )
            c.rect.w = w;
    }
}

void _childs_align_center( GObject o )
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
        c.rect.x = x;
        c.rect.y = y;
        c.rect.h = h;
        x += c.rect.w;

        if ( o.layout_mode_hbox_same_width )
            c.rect.w = w;
    }
}

void _childs_align_right( GObject o )
{
    // Content Rect
    SDL_Rect crect;
    o.content_rect( &crect );

    // Count childs
    int childs_count;
    int childs_w;
    foreach ( c; o.childs )
    {
        childs_count++;

        if ( c.w_mode == WMODE.FIXED )
            childs_w += c.rect.w;
        else
            childs_w += c.rect.w;
    }

    // Layout
    int x = crect.x + ( crect.w - childs_w );
    int y = crect.y;
    int h = crect.h;
    int w = crect.w;
    foreach ( c; o.childs )
    {
        c.rect.x = x;
        c.rect.y = y;
        c.rect.h = h;

        x += c.rect.w;
    }
}
