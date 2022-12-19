module op;

import bindbc.sdl;
import defs;


struct _OP
{
    Uint32 CREATE;
    Uint32 CREATED;
    Uint32 RENDER;
    Uint32 RENDERED;
    Uint32 KEYDOWN;
    Uint32 KEYUP;
    Uint32 CLICK;
    Uint32 CLICKED;
    Uint32 TIMER;
    Uint32 GET_TEXT;
    Uint32 GET_IMAGE;
}
shared
_OP OP;

// SDL_UserEvent()
// SDL_RegisterEvents()
void register_custom_events()
{
    OP.CREATE    = SDL_RegisterEvents( 1 );
    OP.CREATED   = SDL_RegisterEvents( 1 );
    OP.RENDER    = SDL_RegisterEvents( 1 );
    OP.RENDERED  = SDL_RegisterEvents( 1 );
    OP.KEYDOWN   = SDL_RegisterEvents( 1 );
    OP.KEYUP     = SDL_RegisterEvents( 1 );
    OP.CLICK     = SDL_RegisterEvents( 1 );
    OP.CLICKED   = SDL_RegisterEvents( 1 );
    OP.TIMER     = SDL_RegisterEvents( 1 );
    OP.GET_TEXT  = SDL_RegisterEvents( 1 );
    OP.GET_IMAGE = SDL_RegisterEvents( 1 );
}
