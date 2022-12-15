module was;

import core.sys.windows.windows;
import core.sys.windows.com;
import core.sys.windows.winbase : GetThreadId;
import core.sys.windows.objbase : CoCreateInstance;
import core.sys.windows.objidl  : PROPVARIANT;
import core.sys.windows.uuid    ;
import core.sys.windows.oaidl   ;
import comhelpers               ;


pragma( lib, "Winmm.lib" );
//pragma( lib, "kernel32" );  // InterlockedIncrement()


/// Helper function to create GUID from string.
///
/// BCDE0395-E52F-467C-8E3D-C4579291692E -> GUID(0xBCDE0395, 0xE52F, 0x467C, [0x8E, 0x3D, 0xC4, 0x57, 0x92, 0x91, 0x69, 0x2E])
GUID makeGuid(string str)()
{
    static assert(str.length==36, "Guid string must be 36 chars long");
    enum GUIDstring = "GUID(0x" ~ str[0..8] ~ ", 0x" ~ str[9..13] ~ ", 0x" ~ str[14..18] ~
        ", [0x" ~ str[19..21] ~ ", 0x" ~ str[21..23] ~ ", 0x" ~ str[24..26] ~ ", 0x" ~ str[26..28]
        ~ ", 0x" ~ str[28..30] ~ ", 0x" ~ str[30..32] ~ ", 0x" ~ str[32..34] ~ ", 0x" ~ str[34..36] ~ "])";
    return mixin(GUIDstring);
}


const IID IID_IMMDeviceEnumerator = makeGuid!"A95664D2-9614-4F35-A746-DE8DB63617E6";
const CLSID CLSID_MMDeviceEnumerator = makeGuid!"BCDE0395-E52F-467C-8E3D-C4579291692E";


enum ERole //__MIDL___MIDL_itf_mmdeviceapi_0000_0000_0002
{	
    eConsole	        = 0,
    eMultimedia	        = ( eConsole + 1 ) ,
    eCommunications	    = ( eMultimedia + 1 ) ,
    ERole_enum_count    = ( eCommunications + 1 ) 
}


enum EDataFlow //__MIDL___MIDL_itf_mmdeviceapi_0000_0000_0001
{	
    eRender	                = 0,
    eCapture	            = ( eRender + 1 ) ,
    eAll	                = ( eCapture + 1 ) ,
    EDataFlow_enum_count    = ( eAll + 1 ) 
}


const IID IID_IMMDeviceCollection = makeGuid!"0BD7A1BE-7A1A-44DB-8397-CC5392387B5E";
extern (Windows) {
    interface IMMDeviceCollection : IUnknown 
    {
        HRESULT GetCount ( UINT* pcDevices );
        HRESULT Item     ( UINT nDevice, IMMDevice* ppDevice );
    }
}


extern (Windows) {
    interface IMMDeviceEnumerator : IUnknown 
    {
        HRESULT EnumAudioEndpoints                      ( EDataFlow dataFlow, DWORD dwStateMask, IMMDeviceCollection* ppDevices );
        HRESULT GetDefaultAudioEndpoint                 ( EDataFlow dataFlow, ERole role, IMMDevice* ppEndpoint );    
        HRESULT GetDevice                               ( LPCWSTR pwstrId, IMMDevice* ppDevice );
        HRESULT RegisterEndpointNotificationCallback    ( IMMNotificationClient pClient );
        HRESULT UnregisterEndpointNotificationCallback  ( IMMNotificationClient pClient );
    }
}


struct PROPERTYKEY
{
    GUID fmtid;
    DWORD pid;
}


const IID IID_IMMNotificationClient = makeGuid!"7991EEC9-7E89-4D85-8390-6C703CEC60C0";
extern (Windows) {
    interface IMMNotificationClient : IUnknown 
    {
        HRESULT OnDeviceStateChanged    ( LPCWSTR pwstrDeviceId, DWORD dwNewState );
        HRESULT OnDeviceAdded           ( LPCWSTR pwstrDeviceId );
        HRESULT OnDeviceRemoved         ( LPCWSTR pwstrDeviceId );
        HRESULT OnDefaultDeviceChanged  ( EDataFlow flow, ERole role, LPCWSTR pwstrDefaultDeviceId );
        HRESULT OnPropertyValueChanged  ( LPCWSTR pwstrDeviceId, const PROPERTYKEY key );
    }
}



extern (Windows) {
    interface IMMDevice : IUnknown 
    {
        HRESULT Activate            ( const ref IID iid, DWORD dwClsCtx, PROPVARIANT* pActivationParams, void** ppInterface );
        HRESULT OpenPropertyStore   ( DWORD stgmAccess, IPropertyStore* ppProperties );
        HRESULT GetId               ( LPWSTR* ppstrId );
        HRESULT GetState            ( DWORD* pdwState );
    }
}


const IID IID_IPropertyStore = makeGuid!"886d8eeb-8cf2-4446-8d02-cdba1dbdcf99";
extern (Windows) {
    interface IPropertyStore : IUnknown 
    {
        HRESULT GetCount ( DWORD *cProps );
        HRESULT GetAt    ( DWORD iProp, PROPERTYKEY *pkey );
        HRESULT GetValue ( const ref PROPERTYKEY key, PROPVARIANT* pv );
        HRESULT SetValue ( const ref PROPERTYKEY key, PROPVARIANT* propvar );
        HRESULT Commit   ();
    }
}


const IID IID_IAudioEndpointVolumeCallback = makeGuid!"657804FA-D6AD-4496-8A60-352752AF4F89";
extern (Windows) {
    interface IAudioEndpointVolumeCallback : IUnknown
    {
        HRESULT OnNotify ( AUDIO_VOLUME_NOTIFICATION_DATA* pNotify );
    }
}


struct AUDIO_VOLUME_NOTIFICATION_DATA
{
    GUID        guidEventContext;
    BOOL        bMuted;
    float       fMasterVolume;
    UINT        nChannels;
    float[1]    afChannelVolumes;
}


const IID IID_IAudioEndpointVolume = makeGuid!"5CDF2C82-841E-4546-9722-0CF74078229A";
extern (Windows) {
    interface IAudioEndpointVolume : IUnknown
    {
    public:
        HRESULT RegisterControlChangeNotify     ( IAudioEndpointVolumeCallback *pNotify );
        HRESULT UnregisterControlChangeNotify   ( IAudioEndpointVolumeCallback *pNotify );
        HRESULT GetChannelCount                 ( UINT*   pnChannelCount );
        HRESULT SetMasterVolumeLevel            ( float   fLevelDB, LPCGUID pguidEventContext );
        HRESULT SetMasterVolumeLevelScalar      ( float   fLevel,   LPCGUID pguidEventContext );
        HRESULT GetMasterVolumeLevel            ( float*  pfLevelDB );
        HRESULT GetMasterVolumeLevelScalar      ( float*  pfLevel );
        HRESULT SetChannelVolumeLevel           ( UINT    nChannel, float   fLevelDB, LPCGUID pguidEventContext );
        HRESULT SetChannelVolumeLevelScalar     ( UINT    nChannel, float   fLevel,   LPCGUID pguidEventContext );
        HRESULT GetChannelVolumeLevel           ( UINT    nChannel, float*  pfLevelDB );
        HRESULT GetChannelVolumeLevelScalar     ( UINT    nChannel, float*  pfLevel );
        HRESULT SetMute                         ( BOOL    bMute,    LPCGUID pguidEventContext );
        HRESULT GetMute                         ( BOOL*   pbMute );
        HRESULT GetVolumeStepInfo               ( UINT*   pnStep,   UINT*   pnStepCount );
        HRESULT VolumeStepUp                    ( LPCGUID pguidEventContext );
        HRESULT VolumeStepDown                  ( LPCGUID pguidEventContext );
        HRESULT QueryHardwareSupport            ( DWORD*  pdwHardwareSupportMask );
        HRESULT GetVolumeRange                  ( float*  pflVolumeMindB,   float* pflVolumeMaxdB, float* pflVolumeIncrementdB );
    }
}

class DeviceEnumerator
{
    IMMDeviceEnumerator deviceEnumerator;


    this()
    {
        if ( Init() )
        {
            // OK
        }
        else
        {
            throw new Exception( "Was init failed" );
        }
    }


    ~this()
    {
        Close();
    }


    bool Init()
    {
        HRESULT hres = 
            CoCreateInstance( 
                &CLSID_MMDeviceEnumerator, 
                NULL, 
                CLSCTX_INPROC_SERVER, 
                &IID_IMMDeviceEnumerator, 
                cast( void** )&deviceEnumerator
            );

        return SUCCEEDED( hres );
    }


    void Close()
    {

        deviceEnumerator.Release();
    }


    bool GetDefaultAudioEndpoint( IMMDevice* mmDevice )
    {
        HRESULT hres = deviceEnumerator.GetDefaultAudioEndpoint( EDataFlow.eRender, ERole.eConsole, mmDevice );

        return SUCCEEDED( hres );
    }
}


float WasGetMasterVolume()
{
    HRESULT hres;

    auto de = new DeviceEnumerator();

    IMMDevice mmDevice;
    de.GetDefaultAudioEndpoint( &mmDevice );

    IAudioEndpointVolume audioEndpointVolume;
    hres = mmDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, NULL, cast( void** )&audioEndpointVolume );

    float volume;
    hres = audioEndpointVolume.GetMasterVolumeLevelScalar ( &volume );

    audioEndpointVolume.Release();
    mmDevice.Release();

    return volume;
}


void WasSetMasterVolume( float newVolume )
{
    HRESULT hres;

    auto de = new DeviceEnumerator();

    IMMDevice mmDevice;
    de.GetDefaultAudioEndpoint( &mmDevice );

    IAudioEndpointVolume audioEndpointVolume;
    hres = mmDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, NULL, cast( void** )&audioEndpointVolume );

    hres = audioEndpointVolume.SetMasterVolumeLevelScalar( newVolume, NULL );

    audioEndpointVolume.Release();
    mmDevice.Release();
}

/*
extern (Windows) {
    class AudioEndpointVolumeCallback : IAudioEndpointVolumeCallback
    {
        void delegate() listenerDg;


        this ( void delegate() listenerDg )
        {
            this.listenerDg = listenerDg;
        }


        HRESULT OnNotify ( AUDIO_VOLUME_NOTIFICATION_DATA* pNotify )
        {
            // pNotify.fMasterVolume

            if ( listenerDg )
                listenerDg();
        
            return S_OK;
        }


        // COM specific
        mixin ComObjectMixin!();
    }


    class WasRegisterSystemNotificationClass
    {
        DeviceEnumerator            de;
        IMMDevice                   mmDevice;
        IAudioEndpointVolume        audioEndpointVolume;
        AudioEndpointVolumeCallback notifyCallback;

        this( void delegate() dg )
        {
            HRESULT hres;

            de = new DeviceEnumerator();

            de.GetDefaultAudioEndpoint( &mmDevice );

            hres = mmDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, NULL, cast( void** )&audioEndpointVolume );

            notifyCallback = new AudioEndpointVolumeCallback( dg );

            hres = audioEndpointVolume.RegisterControlChangeNotify( cast( IAudioEndpointVolumeCallback* )notifyCallback );
        }


        ~this()
        {
            audioEndpointVolume.Release();
            mmDevice.Release();
        }
    }


    void WasRegisterSystemNotificationCallback( void delegate() dg )
    {
        HRESULT hres;

        auto de = new DeviceEnumerator();

        IMMDevice mmDevice;
        de.GetDefaultAudioEndpoint( &mmDevice );

        IAudioEndpointVolume audioEndpointVolume;
        hres = mmDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, NULL, cast( void** )&audioEndpointVolume );

        auto notifyCallback = new AudioEndpointVolumeCallback( dg );
        hres = audioEndpointVolume.RegisterControlChangeNotify( cast( IAudioEndpointVolumeCallback* )notifyCallback );

        audioEndpointVolume.Release();
        mmDevice.Release();
    }
}
*/






extern (Windows) 
class CAudioEndpointVolumeCallback : IAudioEndpointVolumeCallback
{
    alias CallbackFunc = extern ( D ) void delegate( float level );

    LONG _cRef;
	DWORD mThreadId;
	CallbackFunc dg;


    this( CallbackFunc dg ) 
    {
        _cRef     = 1;
        this.dg   = dg;
		mThreadId = GetThreadId( GetCurrentThread() );
	}


    ULONG AddRef()
    {
        _cRef++;
        return _cRef;
        //return InterlockedIncrement( &_cRef );
    }


    ULONG Release()
    {
        _cRef--;
        ULONG ulRef = _cRef;
        //ULONG ulRef = InterlockedDecrement( &_cRef );

        if ( 0 == ulRef )
            this.destroy();

        return ulRef;
    }


    HRESULT QueryInterface( REFIID riid, VOID **ppvInterface )
    {
        if ( &IID_IUnknown == riid )
        {
            AddRef();
            *ppvInterface = cast( IUnknown* )this;
        }
        else 
        if ( &IID_IAudioEndpointVolumeCallback == riid )
        {
            AddRef();
            *ppvInterface = cast( IAudioEndpointVolumeCallback* )this;
        }
        else
        {
            *ppvInterface = NULL;
            return E_NOINTERFACE;
        }

        return S_OK;
    }
    

    HRESULT OnNotify( AUDIO_VOLUME_NOTIFICATION_DATA* pNotify )
    {
        if ( pNotify == NULL )
            return E_INVALIDARG;

		if ( dg ) 
        {
            // pNotify.fMasterVolume
			// PostThreadMessage( mThreadId, WM_USER, EVENT_VOLBEYONDLIMIT, NULL );
            // MessageBoxA( null, "OnNotify()", null, MB_OK );
            dg( pNotify.fMasterVolume );
		}
        
        return S_OK;
    }
}


auto runtime_error( string s )
{
    return new Exception( s );
}


class VolumeMonitor 
{
public:
	static IMMDeviceEnumerator pDeviceEnumerator;
	IMMDevice                  pDevice;
	IAudioEndpointVolume       pAudioEndpointVolume;


    this( IAudioEndpointVolumeCallback cb )
    {
        HRESULT hr;

        pDevice = NULL;
        pAudioEndpointVolume = NULL;

        if ( !pDeviceEnumerator ) 
        {
            hr = CoCreateInstance(
                                  &CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL,
                                  &IID_IMMDeviceEnumerator, cast( void** )&pDeviceEnumerator );
            if ( FAILED( hr ) )
                throw runtime_error( "CoCreateInstance" );
        }

        hr = pDeviceEnumerator.GetDefaultAudioEndpoint( EDataFlow.eRender, ERole.eMultimedia, &pDevice );

        if ( FAILED( hr ) )
            throw runtime_error( "GetDefaultAudioEndpoint" );

        hr = pDevice.Activate( IID_IAudioEndpointVolume, CLSCTX_ALL, NULL, cast( void** )&pAudioEndpointVolume );

        if ( FAILED( hr ) ) 
        {
            pDevice.Release();
            throw runtime_error( "Activate" );
        }

        hr = pAudioEndpointVolume.RegisterControlChangeNotify( cast( IAudioEndpointVolumeCallback* )cb );

        if ( FAILED( hr ) ) 
        {
            pAudioEndpointVolume.Release();
            pDevice.Release();
            throw runtime_error( "RegisterControlChangeNotify" );
        }
    }


	~this() 
    {
		pAudioEndpointVolume.Release();
		pDevice.Release();
	}

    /*
	IAudioEndpointVolume *operator->() const 
    {
		return pAudioEndpointVolume;
	}
    */
}


void WasRegisterSystemNotificationCallback()
{
    //  auto callback = new CAudioEndpointVolumeCallback( 0.6f );
	// auto monitor = new VolumeMonitor( callback );
}


