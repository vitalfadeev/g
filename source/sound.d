module sound;

import core.sys.windows.windows;
import core.sys.windows.objidl;
import core.sys.windows.wtypes;
import core.sys.windows.com;
import std.conv;
import was   : WasGetMasterVolume, WasSetMasterVolume;


struct Sound
{
    static float volume_page_size = 5.0f / 100 ; // 5%


    static 
    float get_master_volume()
    {
        return WasGetMasterVolume();
    }


    static 
    void set_master_volume( float level )
    {
        WasSetMasterVolume( level );
    }


    static
    bool master_volume_page_up()
    {
        float volume = get_master_volume();
        float new_volume;

        if ( volume < 1.0 )
        {
            if ( volume > 1.0 - volume_page_size )
                new_volume = 1.0;
            else
                new_volume = volume + volume_page_size;

            set_master_volume( new_volume );

            return true;
        }

        return false;
    }


    static
    bool master_volume_page_down()
    {
        float volume = get_master_volume();
        float new_volume;

        if ( volume > 0 )
        {
            if ( volume < volume_page_size )
                new_volume = 0;
            else
                new_volume = volume - volume_page_size;

            set_master_volume( new_volume );

            return true;
        }

        return false;
    }


    extern ( Windows ) static
    auto RegisterSystemNotificationCallback( void delegate() dg )
    {
        //auto obj = new WasRegisterSystemNotificationClass( dg );
        //return obj;
    }
}

