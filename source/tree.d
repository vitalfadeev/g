module tree;

import std.stdio;
import bindbc.sdl;
import op;


class TreeObject : Object
{
    TreeObject parent;
    TreeObject l;
    TreeObject r;
    TreeObject l_child;
    TreeObject r_child;


    size_t main( SDL_Event* e )
    {
        //if ( e.type == OP.CREATE   ) return this.create( e );
        //if ( e.type == OP.CREATEED ) return this.created( e );
        return 0;
    }


    void add( TreeObject b )
    {
        add_r( b );
    }


    void add_child( TreeObject b )
    {
        add_r_child( b );
    }


    void add_r( TreeObject b )
    {
        r = b;
        b.l = this;
        b.parent = this.parent;

        if ( parent !is null )
        {
            parent.r_child = b;

            if ( parent.l_child is null )
                parent.l_child = b;
        }
    }


    void add_l( TreeObject b )
    {
        l = b;
        b.r = this;
        b.parent = this.parent;

        if ( parent !is null )
        {
            parent.l_child = b;

            if ( parent.r_child is null )
                parent.r_child = b;
        }
    }


    void add_r_child( TreeObject c )
    {
        if ( r_child !is null )
            r_child.r = c;

        c.l = r_child;
        r_child = c;

        if ( l_child is null )
            l_child = c;
        
        c.parent = this;
    }


    void add_l_child( TreeObject c )
    {
        if ( l_child !is null )
            l_child = c;

        c.r = l_child;
        l_child = c;

        if ( r_child is null )
            r_child = c;

        c.parent = this;
    }


    void sub( TreeObject c )
    {
        auto l = c.l;
        auto r = c.r;
        l.r = r;
        r.l = l;

        auto p = c.parent;
        c.parent = null;

        if ( p !is null )
        {
            if ( p.l_child is c )
            {
                p.l_child = r;
            }

            if ( p.r_child is c )
            {
                p.r_child = l;
            }
        }
    }


    //
    bool has_child()
    {
        return ( l_child !is null );
    }
}


class GObject : TreeObject
{
    SDL_Rect  rect;
    ubyte     flags;
    SDL_Color fg;
    SDL_Color bg;


    override
    size_t main( SDL_Event* e )
    {
        if ( e.type == SDL_MOUSEBUTTONDOWN ) return _mouse_button( e );
        if ( e.type == SDL_MOUSEBUTTONUP   ) return _mouse_button( e );
        if ( e.type == OP.RENDER           ) return render( e );
        //if ( e.type == OP.DRAWED ) return this.drawed( e );
        return super.main( e );
    }


    bool hit_test( Sint32 x, Sint32 y )
    {
        SDL_Point point = SDL_Point( x, y );
        return SDL_PointInRect( &point, &rect );
    }


    size_t _mouse_button( SDL_Event* e )
    {
        if ( hit_test( e.button.x, e.button.y ) ) 
            mouse_button( e );

        return 0;
    }


    size_t mouse_button( SDL_Event* e )
    {
        // scan tree
        this.each_child_main( e );

        return 0;
    }


    size_t render( SDL_Event* e )
    {
        return 0;
    }


    void render( SDL_Renderer* renderer )
    {
        // fill rect x, y, w, h
        SDL_SetRenderDrawColor( renderer, bg.r, bg.g, bg.b, bg.a  );
        SDL_RenderFillRect( renderer, &rect );
        // borders rect x, y, w, h
        SDL_SetRenderDrawColor( renderer, fg.r, fg.g, fg.b, fg.a  );
        SDL_RenderDrawRect( renderer, &rect );

        // Render childs
        this.each_child_render( renderer );
    }


    void push_render()
    {
        // Create new SDL render event
        // Push in SDL Event Loop
        SDL_Event e;
        e.type       = cast( SDL_EventType )OP.RENDER;
        e.user.code  = OP.RENDER;
        e.user.data1 = cast( void* )this; // FIXME
        e.user.data2 = null;
        SDL_PushEvent( &e );
    }
}


class Tree
{
    GObject root;

    //
    size_t main( SDL_Event* e )
    {
        return root.main( e );
    }


    //
    void render( SDL_Renderer* renderer, SDL_Rect* viewrect )
    {
        if ( SDL_HasIntersection( viewrect, &root.rect ) )
            root.render( renderer );
    }


    //
    void push_render()
    {
        root.push_render();
    }
}


//
void walk_in_width( FUNC )( GObject root, FUNC callback )
{
    auto cur = root;
    
    callback( cur );

    for ( cur = cast( GObject )cur.l_child; cur !is null; cur = cast( GObject )cur.r )
        walk_in_width( cur, callback );
}


//
void each_child( FUNC )( GObject root, FUNC callback )
{
    GObject cur;
    
    for ( cur = cast( GObject )root.l_child; cur !is null; cur = cast( GObject )cur.r )
        callback( cur );
}


//
void each_child_main( TreeObject root, SDL_Event* e )
{
    TreeObject c;
    
    for ( c = root.l_child; c !is null; c = c.r )
        c.main( e );
}


//
void each_child_render( GObject root, SDL_Renderer* renderer )
{
    TreeObject c;
    
    for ( c = root.l_child; c !is null; c = c.r )
        (cast( GObject )c).render( renderer );
}


//
void dump_tree( Tree tree )
{
    void callback( GObject cur )
    {
        writeln( "  ", cur );
    }

    // scan tree
    each_child( tree.root, &callback );
}
