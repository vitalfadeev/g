import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import tree;
import op;
import defs;
import gobject;
import window;
import windows;
import panel;
import bindbc.sdl;
import sdlexception;


int main()
{
    // Init
    init_sdl();

    //
    register_custom_events();

    // Tree
    Tree tree;
    create_tree( tree );

    // Window
    SDL_Window* window;
    create_window( window );

    // Window size
    window_size_fromn_gobject( window, tree.root );

    // Renderer
    SDL_Renderer* renderer;
    create_renderer( window, renderer );

    // Save window for manage
    manage_window( new Window( window, tree, renderer ) );

    // Render
    tree.push_render();

    // Event Loop
    event_loop();

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
    //lmb.bg = SDL_Color( 0,  48,  48, SDL_ALPHA_OPAQUE );
    //lmb.fg = SDL_Color( 0, 255, 255, SDL_ALPHA_OPAQUE );

    rmb.rect.x = 1366 - 256;
    rmb.rect.y = 0;
    rmb.rect.w = 256;
    rmb.rect.h = 64;
    rmb.text = "RMenu";
    //rmb.bg = SDL_Color(  48, 0,  48, SDL_ALPHA_OPAQUE );
    //rmb.fg = SDL_Color( 255, 0, 255, SDL_ALPHA_OPAQUE );

    clck.rect.x = ( 1366 - 256 ) / 2;
    clck.rect.y = 0;
    clck.rect.w = 256;
    clck.rect.h = 64;
    clck.bg = SDL_Color(  48,  48, 0, SDL_ALPHA_OPAQUE );
    clck.fg = SDL_Color( 255, 255, 0, SDL_ALPHA_OPAQUE );

    // CSS
    import style : styles, Style1, Style2, Style3, apply_styles;
    styles ~= new Style1();
    styles ~= new Style2();
    styles ~= new Style3();

    apply_styles( lmb );
    //apply_styles( clck );
    apply_styles( rmb );
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
            0,
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
void window_size_fromn_gobject( SDL_Window* window, GObject o )
{
    SDL_SetWindowSize( window, o.rect.w, o.rect.h );
}


//
void create_renderer( SDL_Window* window, ref SDL_Renderer* renderer )
{
    renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_SOFTWARE );
}

//
void event_loop()
{
    //
    bool game_is_still_running = true;

    //
    while ( game_is_still_running )
    {
        SDL_Event e;

        // Process Event
        while ( SDL_PollEvent( &e ) > 0 ) 
        {
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

                // Find
                Window[] obj_windows;
                find_windows_with_object( obj_windows, obj );

                // Render
                foreach ( window; obj_windows )
                {
                    // Layout
                    window.tree.layout();

                    // Render
                    obj.render( window.renderer );

                    // Raxterize
                    SDL_RenderPresent( window.renderer );
                }
            }
            else

            // ANY
            {
                all_windows_main( &e );
            }
        }

        // Delay
        //SDL_Delay( 100 );
    }
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

