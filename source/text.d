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
    int    font_size = 32;

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
        SDL_Color bg_c  = { 0, 0, 0 };

        // Content Rect
        SDL_Rect trect;
        {
            // Content Rect
            SDL_Rect crect;
            content_rect( &crect );

            // Text Rect
            int w;
            int h;
            if ( TTF_SizeText( font, text.toStringz, &w, &h ) )
                throw new SDLException( "TTF_SizeText()" );
            trect.x = crect.x;
            trect.y = crect.y;
            trect.w = w;
            trect.h = h;

            // Center Text inside Content Rect
            center_rect_in_rect( &trect, &crect );

            // Clip
            SDL_RenderSetClipRect( renderer, &crect );
        }

        // Render
        SDL_Surface* text_surface =
            TTF_RenderText_Solid( font, text.toStringz, white ); 
            //TTF_RenderText_Shaded( font, "Text", white, bg_c ); 

        SDL_Texture* text_texture = 
            SDL_CreateTextureFromSurface( renderer, text_surface );

        // Copy
        SDL_RenderCopy( renderer, text_texture, null, &trect );

        // Free
        SDL_RenderSetClipRect( renderer, null );
        TTF_CloseFont( font );
        SDL_FreeSurface( text_surface );
        SDL_DestroyTexture( text_texture );

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

