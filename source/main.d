import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import tree;
import op;
import defs;
import panel;
import bindbc.sdl;


int main()
{
    // Init
    init_sdl();

    //
    register_custom_events();

    // Tree
    Tree tree;
    create_tree( tree );

    // Window, Surface
    SDL_Window*  window;
    create_window( window );

    // Renderer
    SDL_Renderer* renderer;
    create_renderer( window, renderer );

    // Render
    tree.push_render();

    // Event Loop
    event_loop( tree, window, renderer );

    return 0;
}


//
void init_sdl()
{
    SDLSupport ret = loadSDL();

    if ( ret != sdlSupport )
    {
        if ( ret == SDLSupport.noLibrary ) 
            throw new Exception( "The SDL shared library failed to load" );
        else if ( SDLSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)" );
    }

    loadSDL( "sdl2.dll" );
}


//
void create_tree( ref Tree tree )
{
    tree = new Tree;

    // Panel
    auto panel = new Panel;
    tree.root = panel;
    panel.rect.x = 0;
    panel.rect.y = 0;
    panel.rect.w = 1366;
    panel.rect.h = 64;
    
    auto lmb  = new LMenuButton;
    auto rmb  = new RMenuButton;
    auto clck = new Clock;
    panel.add_child( lmb );
    panel.add_child( clck  );
    panel.add_child( rmb  );

    lmb.rect.x = 0;
    lmb.rect.y = 0;
    lmb.rect.w = 256;
    lmb.rect.h = 64;
    lmb.text = "LMenu";
    lmb.bg = SDL_Color( 0,  48,  48, SDL_ALPHA_OPAQUE );
    lmb.fg = SDL_Color( 0, 255, 255, SDL_ALPHA_OPAQUE );

    rmb.rect.x = 1366 - 256;
    rmb.rect.y = 0;
    rmb.rect.w = 256;
    rmb.rect.h = 64;
    rmb.text = "RMenu";
    rmb.bg = SDL_Color(  48, 0,  48, SDL_ALPHA_OPAQUE );
    rmb.fg = SDL_Color( 255, 0, 255, SDL_ALPHA_OPAQUE );

    clck.rect.x = ( 1366 - 256 ) / 2;
    clck.rect.y = 0;
    clck.rect.w = 256;
    clck.rect.h = 64;
    clck.bg = SDL_Color(  48,  48, 0, SDL_ALPHA_OPAQUE );
    clck.fg = SDL_Color( 255, 255, 0, SDL_ALPHA_OPAQUE );
}



//
//class RenderBuffer
//{
//    SDL_Point     offset; // x, y
//    SDL_Surface*  surface;

//    this( int w, int h )
//    {
//        surface = 
//            SDL_CreateRGBSurfaceWithFormat( 0, w, h, 8, SDL_PIXELFORMAT_RGBA8888 );
//    }

//    ~this()
//    {
//        SDL_FreeSurface( surface );
//    }

//    auto rect()
//    {
//        return new SDL_Rect( offset.x, offset.y, surface.w, surface.h );
//    }

//    void saveToBMP()
//    {
//        const char* file = "out.bmp";

//        if ( SDL_SaveBMP( surface, file ) )
//            show_sdl_error();
//    }
//}

//
void create_window( ref SDL_Window* window )
{
    // Window
    window = 
        SDL_CreateWindow(
            "SDL2 Window",
            SDL_WINDOWPOS_CENTERED,
            64,
            1366, 96,
            0
        );

    if ( !window )
        throw new SDLException( "Failed to create window" );

    // Update
    SDL_UpdateWindowSurface( window );    
}


//
void create_renderer( SDL_Window* window, ref SDL_Renderer* renderer )
{
    renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_SOFTWARE );
}

//
void event_loop( Tree tree, ref SDL_Window* window, SDL_Renderer* renderer )
{
    //
    bool game_is_still_running = true;

    //
    while ( game_is_still_running )
    {
        SDL_Event e;

        while ( SDL_PollEvent( &e ) > 0 ) 
        {
            // Process Event
            // SDL_QUIT
            if ( e.type == SDL_QUIT ) 
            {
                game_is_still_running = false;
                break;
            }
            else

            // OP.RENDER
            if ( e.type == OP.RENDER )
            {
                auto obj = cast( GObject )e.user.data1;
                tree.render( renderer, &obj.rect );

                // Raxterize
                SDL_RenderPresent( renderer );
            }
            else

            // ANY
            {
                tree.main( &e );
            }
        }

        // Delay
        SDL_Delay( 100 );
    }
}


//
class SDLException : Exception
{
    this( string msg )
    {
        super( format!"%s: %s"( SDL_GetError().to!string, msg ) );
    }
}


//
void show_sdl_error( string file=__FILE__, int lineno=__LINE__ )
{
    const char* msg = SDL_GetError();
    writeln( "ERR: SDL:", msg, ": ", file, ": ", lineno );
}




//
class Operations
{
    OperationStore store;
}


struct Op
{
    size_t opcode;
    size_t arg;
}


class OperationStore
{
    Op[] store;
    Op*  start;
    Op*  end;

    this()
    {
        store = new Op[](OP_STORE_SIZE);
    }


    bool empty()
    {
        return (start == end);
    }


    auto limit()
    {
        return store.ptr + store.length;
    }


    void put( Op op )
    {
        // check free space
        if ( 
            ( start < end ) && ( end < limit ) ||
            ( start > end ) && ( start - end > 0 )
           )
        {
            // yes free
        }

        //
        if ( start == end )
        {
            *end = op;
            end += 1;
        }
    }
}

// mode 1
// --------------------------
// ^
// start
// end

// mode 2
// ============--------------
// ^          ^
// start
//           end

// mode 3
// ==========================
// ^                        ^
// start
//                        end

// mode 4
// ====----------============
//    ^          ^           
//             start
//   end                    

// mode 5
// ==========================
//              ^^           
//               start
//            end                    

