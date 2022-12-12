module treeobject;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import style;
import states;
import gobject;


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


    //
    ChildsForwardIterator childs()
    {
        return ChildsForwardIterator( this );
    }

    struct ChildsForwardIterator
    {
        TreeObject front;

        this( TreeObject parent )
        {
            this.front  = parent.l_child;
        }

        bool empty()
        {
            return ( front is null );
        }

        void popFront()
        {
            front = front.r;
        }
    }
}


//
void each_child( FUNC )( TreeObject root, FUNC callback )
{
    foreach ( c; root.childs )
        callback( c );
}


//
void each_child_main( TreeObject root, SDL_Event* e )
{
    foreach ( c; root.childs )
        c.main( e );
}


