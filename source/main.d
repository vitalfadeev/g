import std.conv;
import std.format;
import std.stdio;
import std.typecons;
import root;
import op;
import defs;
import gobject;
import window;
import windows;
import panel;
import bottom_panel;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;


int main()
{
    // Init
    init_sdl();

    //
    register_custom_events();

    // Tree Root
    Root root = new Root();

    // 1.
    // Panel
    Panel panel;
    create_tree( root, panel );

    // Window
    SDL_Window* window;
    create_window( window );

    // Window size
    //window_size_fromn_gobject( window, panel );

    // Renderer
    SDL_Renderer* renderer;
    create_renderer( window, renderer );

    // Save window for manage
    manage_window( new Window( window, panel, renderer ) );

    // 2.
    // Panel 2
    BottomPanel panel2;
    create_tree2( root, panel2 );

    // Window 2
    SDL_Window* window2;
    create_window2( window2 );

    // Renderer
    SDL_Renderer* renderer2;
    create_renderer( window2, renderer2 );

    // Save window for manage
    manage_window( new Window( window2, panel2, renderer2 ) );

    //
    // Styles
    create_styles( root );

    //
    // Render
    root.push_render();

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

    // Image
    SDLImageSupport ret_image = loadSDLImage();

    if ( ret_image != sdlImageSupport )
    {
        if ( ret_image == SDLImageSupport.noLibrary ) 
            throw new Exception( "The SDL_Image shared library failed to load" );
        else if ( SDLImageSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_Image_2018, etc.)" );
    }

    auto flags = IMG_INIT_PNG | IMG_INIT_JPG;
    if( IMG_Init( flags ) != flags )
        throw new Exception( "ERR: IMG_Init()" );
}


//
void create_tree( ref Root root, ref Panel panel )
{
    // +----------------------------------------------+ Panel
    // | +------------+ +------------+ +------------+ | RBox, CBox, LBox
    // | | +--------+ | | +--------+ | | +---++---+ | | LButton, Clock, RButton
    // | | |        | | | |        | | | |   ||   | | |
    // | | +--------+ | | +--------+ | | +---++---+ | |
    // | +------------+ +------------+ +------------+ |
    // +----------------------------------------------+

    // 1.
    // Panel
    panel = new Panel;
    root.add_child( panel );
    panel.rect.x = 0;
    panel.rect.y = 0;
    panel.w_mode = WMODE.DISPLAY;
    panel.h_mode = HMODE.FIXED;
    panel.rect.h = 29;
    panel.layout_mode = LAYOUT_MODE.HBOX;
    panel.layout_mode_hbox_same_width = true;

    // Boxes    
    auto lbox = new LBox;
    auto cbox = new CBox;
    auto rbox = new RBox;
    panel.add_child( lbox );
    panel.add_child( cbox );
    panel.add_child( rbox );
    lbox.layout_mode = LAYOUT_MODE.HBOX;
    cbox.layout_mode = LAYOUT_MODE.HBOX;
    rbox.layout_mode = LAYOUT_MODE.HBOX;
    rbox.childs_align = CHILDS_ALIGN.RIGHT;
    lbox.layout_mode_hbox_same_width = true;
    cbox.layout_mode_hbox_same_width = true;
    rbox.layout_mode_hbox_same_width = false;

    // L Buttons
    auto lb1 = new LMenuButton;
    lbox.add_child( lb1 );
    lb1.layout_mode = LAYOUT_MODE.FIXED;
    lb1.text = "LMenu";

    // Clock
    auto clk = new Clock;
    cbox.add_child( clk );
    clk.layout_mode = LAYOUT_MODE.FIXED;

    // R Buttons
    auto rb1 = new RMenuButton;
    rbox.add_child( rb1 );
    rb1.text = "Net";
    rb1.w_mode = WMODE.FIXED;
    rb1.rect.w = 64;
    rb1.layout_mode = LAYOUT_MODE.FIXED;

    auto rb2 = new SoundIndicator;
    rbox.add_child( rb2 );
    rb2.text = "Snd";
    rb2.w_mode = WMODE.FIXED;
    rb2.rect.w = 64;
    rb2.layout_mode = LAYOUT_MODE.FIXED;
}


void create_tree2( ref Root root, ref BottomPanel panel2 )
{
    // 2.
    // Bottom Panel
    panel2 = new BottomPanel;
    root.add_child( panel2 );
    panel2.rect.x = 0;
    panel2.rect.y = 200; // 768 - 96 - 100;
    panel2.w_mode = WMODE.DISPLAY;
    panel2.h_mode = HMODE.FIXED;
    panel2.rect.h = 96;
    panel2.layout_mode  = LAYOUT_MODE.HBOX;
    panel2.childs_align = CHILDS_ALIGN.CENTER;

    auto ab1 = new AppButton;
    panel2.add_child( ab1 );
    ab1.text = "App";
    ab1.w_mode = WMODE.FIXED;
    ab1.rect.w = 96;
    ab1.layout_mode = LAYOUT_MODE.FIXED;
    ab1.borders_enable = true;
}


void create_styles( ref Root root )
{
    // CSS
    import style : create_style, apply_styles_recursive;
    create_style();
    apply_styles_recursive( root );    
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
            1366, 29,
            SDL_WINDOW_BORDERLESS
        );

    if ( !window )
        throw new SDLException( "Failed to create window" );

    // Always On Top
    SDL_SetWindowAlwaysOnTop( window, SDL_TRUE );

    // Update
    SDL_UpdateWindowSurface( window );
}


void create_window2( ref SDL_Window* window )
{
    // Window
    window = 
        SDL_CreateWindow(
            "SDL2 Window",
            0, 100,
            1366, 96,
            SDL_WINDOW_BORDERLESS
        );

    if ( !window )
        throw new SDLException( "Failed to create window" );

    // Always On Top
    SDL_SetWindowAlwaysOnTop( window, SDL_TRUE );

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

        while ( SDL_WaitEvent( &e ) > 0 ) 
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
        window.root.layout();

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
