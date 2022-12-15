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
void create_tree( ref Tree tree )
{
    tree = new Tree;

    // +----------------------------------------------+ Panel
    // | +------------+ +------------+ +------------+ | RBox, CBox, LBox
    // | | +--------+ | | +--------+ | | +---++---+ | | LButton, Clock, RButton
    // | | |        | | | |        | | | |   ||   | | |
    // | | +--------+ | | +--------+ | | +---++---+ | |
    // | +------------+ +------------+ +------------+ |
    // +----------------------------------------------+

    // Panel
    auto panel = new Panel;
    tree.root = panel;
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
    lbox.w_mode = WMODE.FIXED;
    cbox.w_mode = WMODE.FIXED;
    rbox.w_mode = WMODE.FIXED;
    //lbox.rect.w = 1366/3;
    //cbox.rect.w = 1366/3;
    //rbox.rect.w = 1366/3;
    //lbox.layout_mode_hbox_same_width = true;
    lbox.layout_mode_hbox_same_width = true;
    cbox.layout_mode_hbox_same_width = true;
    rbox.layout_mode_hbox_same_width = true;

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
    rb1.text = "R1";
    rb1.rect.w = 64;
    rb1.layout_mode = LAYOUT_MODE.FIXED;

    auto rb2 = new SoundIndicator;
    rbox.add_child( rb2 );
    rb2.text = "R2";
    rb2.rect.w = 64;
    rb2.layout_mode = LAYOUT_MODE.FIXED;

    // CSS
    import style : create_style, apply_styles_recursive;
    create_style();
    apply_styles_recursive( panel );
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
