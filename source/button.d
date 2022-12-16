module button;

import std.stdio;
import std.string;
import std.typecons;
import bindbc.sdl;
import op;
import defs;
import gobject;
import sdlexception;


class Button : GObject
{
    string text;
    string font_file = "InputSansCondensed-Regular.ttf";
    int    font_size = 17;


    override
    size_t main( SDL_Event* e )
    {
        //if ( e.type == SDL_MOUSEBUTTONDOWN ) return this.mouse_button( e );
        //if ( e.type == SDL_MOUSEBUTTONUP   ) return this.mouse_button( e );
        //if ( e.type == SDL_KEYDOWN         ) return this.key( e );
        //if ( e.type == SDL_KEYUP           ) return this.key( e );
        //if ( e.type == OP.CLICK            ) return this.click( e );
        //if ( e.type == OP.CLICKED          ) return this.clicked( e );
        return super.main( e );
    }

    size_t key( SDL_Event* e )
    {
        return 0;
    }


    override
    size_t mouse_button( SDL_Event* e )
    {
        super.mouse_button( e );

        if ( e.type == SDL_MOUSEBUTTONDOWN )
        if ( e.button.button == SDL_BUTTON_LEFT )
            return click( e );

        return 0;
    }


    size_t click( SDL_Event* e )
    {
        return 0;
    }


    override
    void render( SDL_Renderer* renderer )
    {
        // bg, borders
        render_bg( renderer );
        render_borders( renderer );
        render_text( renderer );

        // Render childs
        render_childs( renderer );
    }

    //
    void render_text( SDL_Renderer* renderer )
    {
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
