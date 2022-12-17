module sysmixer;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import treeobject;
import gobject;
import op;
import defs;
import button;
import tools;
import style;
import sdlexception;
import sound : Sound;
import was   : CAudioEndpointVolumeCallback, VolumeMonitor, IAudioEndpointVolumeCallback;
// RegisterSystemNotificationCallback();
// CAudioEndpointVolumeCallback callback;
// VolumeMonitor                monitor;
//
//void RegisterSystemNotificationCallback()
//{
//    auto callback = new CAudioEndpointVolumeCallback( &onMasterVolumeChanged );
//    auto monitor = new VolumeMonitor( callback );
//}
//
//extern ( D )
//void onMasterVolumeChanged( float level )
//{
//    UpdateSoundIcon( false, level );
//    RePaint();
//}


struct SysMixer
{
    void try_volume_up()
    {
        Sound.master_volume_page_up();
    }


    void try_volume_down()
    {
        Sound.master_volume_page_down();
    }


    float get_current_volume()
    {
        return Sound.get_master_volume();
    }
}

SysMixer sys_mixer;
