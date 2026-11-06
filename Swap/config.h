#define PLUG_NAME "Swap"
#define PLUG_MFR "JohnCrosby"
#define PLUG_VERSION_HEX 0x00010001
#define PLUG_VERSION_STR "1.0.1"
#define PLUG_UNIQUE_ID 'sWA3'
#define PLUG_MFR_ID 'JoCr'
#define PLUG_URL_STR "https://john-crosby.com"
#define PLUG_EMAIL_STR "info@john-crosby.com"
#define PLUG_COPYRIGHT_STR "Copyright 2024 JohnCrosby"
#define PLUG_CLASS_NAME Swap

#define BUNDLE_NAME "Swap"
#define BUNDLE_MFR "JohnCrosby"
#define BUNDLE_DOMAIN "com"

#define SHARED_RESOURCES_SUBPATH "Swap"

#define PLUG_CHANNEL_IO "2-2"

#define PLUG_LATENCY 0
#define PLUG_TYPE 0
#define PLUG_DOES_MIDI_IN 0
#define PLUG_DOES_MIDI_OUT 0
#define PLUG_DOES_MPE 0
#define PLUG_DOES_STATE_CHUNKS 0
#define PLUG_HAS_UI 0
#define PLUG_WIDTH 180
#define PLUG_HEIGHT 180
#define PLUG_FPS 60
#define PLUG_SHARED_RESOURCES 0
#define PLUG_HOST_RESIZE 0

#define AUV2_ENTRY Swap_Entry
#define AUV2_ENTRY_STR "Swap_Entry"
#define AUV2_FACTORY Swap_Factory
#define AUV2_VIEW_CLASS Swap_View
#define AUV2_VIEW_CLASS_STR "Swap_View"

#define AAX_TYPE_IDS 'IEF1', 'IEF2'
#define AAX_TYPE_IDS_AUDIOSUITE 'IEA1', 'IEA2'
#define AAX_PLUG_MFR_STR "JoCr"
#define AAX_PLUG_NAME_STR "Swap\nsWA3"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define AAX_DOES_AUDIOSUITE 1

#define VST3_SUBCATEGORY "Fx|Tools"

#define CLAP_MANUAL_URL "https://john-crosby.com"
#define CLAP_SUPPORT_URL "https://john-crosby.com"
#define CLAP_DESCRIPTION "Swaps Left and Right stereo channels"
#define CLAP_FEATURES "audio-effect"//, "utility"

#define APP_NUM_CHANNELS 2
#define APP_N_VECTOR_WAIT 0
#define APP_MULT 1
#define APP_COPY_AUV3 0
#define APP_SIGNAL_VECTOR_SIZE 64
