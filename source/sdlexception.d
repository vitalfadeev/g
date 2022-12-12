module sdlexception;

import std.conv;
import std.format;
import bindbc.sdl;

//
class SDLException : Exception
{
    this( string msg )
    {
        super( format!"%s: %s"( SDL_GetError().to!string, msg ) );
    }
}


