module treeobject;

import std.stdio;
import bindbc.sdl;


mixin template TreeObject( T )
{
    T parent;
    T l;
    T r;
    T l_child;
    T r_child;


    void add( T b )
    {
        add_r( b );
    }


    void add_child( T b )
    {
        add_r_child( b );
    }


    void add_r( T b )
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


    void add_l( T b )
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


    void add_r_child( T c )
    {
        if ( r_child !is null )
            r_child.r = c;

        c.l = r_child;
        r_child = c;

        if ( l_child is null )
            l_child = c;
        
        c.parent = this;
    }


    void add_l_child( T c )
    {
        if ( l_child !is null )
            l_child = c;

        c.r = l_child;
        l_child = c;

        if ( r_child is null )
            r_child = c;

        c.parent = this;
    }


    void sub( T c )
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
        T front;

        this( T parent )
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


    //
    AllChildsForwardIterator all_childs()
    {
        return AllChildsForwardIterator( this );
    }

    struct AllChildsForwardIterator
    {
        T   front;
        T[] parents;

        this( T root )
        {
            this.front  = root;
        }

        bool empty()
        {
            return ( front is null );
        }

        void popFront()
        {
            if ( front.l_child !is null )
            {
                parents ~= front;
                front = front.l_child;
            }

            else
            if ( front.r !is null )
                front = front.r;

            else
            {
                while ( parents.length > 0 )
                {                
                    front = parents[ $-1 ];
                    parents.length -= 1;

                    if ( front.r !is null )
                    {
                        front = front.r;
                        break;
                    }
                }

                if ( parents.length == 0 )
                    front = null;
            }
        }
    }
}
