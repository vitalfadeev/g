module text;

import std.stdio;
import std.string;
import std.typecons;
import bindbc.sdl;
import op;
import defs;
import gobject;
import sdlexception;


class Text : GObject
{
    string text;
    string font_file = "InputSansCondensed-Regular.ttf";
    int    font_size = 96;

    override
    void render( SDL_Renderer* renderer )
    {
        // bg, borders
        render_bg( renderer );
        render_borders( renderer );

        // Font
        TTF_Font* font = TTF_OpenFont( font_file.toStringz, font_size );
        if ( !font )
            throw new SDLException( "TTF_OpenFont()" );

        //TTF_SetFontStyle( font, TTF_STYLE_BOLD );

        // Color
        SDL_Color white = { 255, 255, 255 };
        SDL_Color bg_c = { 0, 0, 0 };

        // Render
        SDL_Surface* surface_message =
            TTF_RenderText_Solid( font, text.toStringz, white ); 
            //TTF_RenderText_Shaded( font, "Text", white, bg_c ); 

        SDL_Texture* message = 
            SDL_CreateTextureFromSurface( renderer, surface_message );

        // Center
        SDL_Rect message_rect = rect;
        message_rect.w = rect.w - 16 - 16;
        //message_rect.h = 16;
        //message_rect.x = rect.x + ( rect.w - text_width() ) / 2;

        // Copy
        SDL_RenderCopy( renderer, message, null, &message_rect );

        TTF_CloseFont( font );
        SDL_FreeSurface( surface_message );
        SDL_DestroyTexture( message );

        // Render childs
        render_childs( renderer );
    }


    int text_width()
    {
        // Text
        TTF_Font* font = TTF_OpenFont( font_file.toStringz, font_size );
        if ( !font )
            throw new SDLException( "TTF_OpenFont()" );

        //TTF_SetFontStyle( font, TTF_STYLE_BOLD );

        int w;
        int h;
        if ( TTF_SizeText( font, text.toStringz, &w, &h ) )
            throw new SDLException( "TTF_SizeText()" );

        TTF_CloseFont( font );

        return w;
    }
}

