module tree;

import std.stdio;
import std.typecons;
import bindbc.sdl;
import op;
import style;
import states;
import gobject;
import treeobject;


class Tree
{
    GObject root;

    //
    size_t main( SDL_Event* e )
    {
        return root.main( e );
    }


    //
    void layout()
    {
        root.layout();
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


    //
    AllChildsForwardIterator all_childs()
    {
        return AllChildsForwardIterator( this );
    }

    struct AllChildsForwardIterator
    {
        TreeObject front;
        TreeObject[] parents;

        this( Tree tree )
        {
            this.front  = tree.root;
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


//
void walk_in_width( FUNC )( GObject root, FUNC callback )
{
    callback( root );

    foreach ( c; root.childs )
        walk_in_width( c, callback );
}


//
void dump_tree( Tree tree )
{
    foreach ( c; tree.root.childs )
        writeln( "  ", c );
}
