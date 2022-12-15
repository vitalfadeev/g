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
import hboxlayout;
import bindbc.sdl;
import bindbc.sdl.ttf;
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
    // SDL
    SDLSupport ret = loadSDL();

    if ( ret != sdlSupport )
    {
        if ( ret == SDLSupport.noLibrary ) 
            throw new Exception( "The SDL shared library failed to load" );
        else if ( SDLSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)" );
    }

    if ( SDL_Init( SDL_INIT_EVERYTHING ) )
        throw new Exception( "ERR: SDL_Init()" );

    // TTF
    SDLTTFSupport ret_ttf = loadSDLTTF();

    if ( ret_ttf != sdlTTFSupport )
    {
        if ( ret_ttf == SDLTTFSupport.noLibrary ) 
            throw new Exception( "The SDL_TTF shared library failed to load" );
        else if ( SDLTTFSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_TTF_2018, etc.)" );
    }

    if ( TTF_Init() )
        throw new Exception( "ERR: TTF_Init()" );
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
    panel.w_mode = WMODE.DISPLAY;
    panel.h_mode = HMODE.FIXED;
    panel.rect.h = 29;
    panel.layout_mode = LAYOUT_MODE.HBOX;
    
    auto lmb  = new LMenuButton;
    auto clck = new Clock;
    auto rmb  = new RMenuButton;
    panel.add_child( lmb  );
    panel.add_child( clck );
    panel.add_child( rmb  );

    lmb.text = "LMenu";
    rmb.text = "RMenu";

    // CSS
    import style : create_style, apply_styles;
    create_style();
    apply_styles( lmb );
    apply_styles( clck );
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
            0,
            1366, 96,
            SDL_WINDOW_BORDERLESS
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

        while ( SDL_PollEvent( &e ) > 0 ) 
        {
            // QUIT
            if ( e.type == SDL_QUIT ) 
                { game_is_still_running = false; break; }

            // TIMER
            else
            if ( e.type == OP.TIMER )
                ( cast( GObject )e.user.data1 ).main( &e ); // FIXME

            // RENDER
            else
            if ( e.type == OP.RENDER )
                obj_windows_main( cast( GObject )e.user.data1, &e );

            // ANY
            else
                all_windows_main( &e );
        }
    }
}


//
void obj_windows_main( GObject obj, SDL_Event* e )
{
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

    foreach ( w; managed_windows )
        w.main( e );
}

// SafeHandle!(SDL_Window,SDL_DestroyWindow)
// SafeHandle!(SDL_Surface,SDL_FreeSurface)
// SafeHandle!(SDL_Texture,SDL_DestroyTexture)
// SafeHandle!(SDL_Renderer,SDL_DestroyRenderer)
