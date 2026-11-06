#define PLUG_NAME "SideChainer"
#define PLUG_MFR "JohnCrosby"
#define PLUG_VERSION_HEX 0x00010002
#define PLUG_VERSION_STR "1.0.2"
#define PLUG_UNIQUE_ID 'JCsc'
#define PLUG_MFR_ID 'JoCr'
#define PLUG_URL_STR "https://john-crosby.com"
#define PLUG_EMAIL_STR "info@john-crosby.com"
#define PLUG_COPYRIGHT_STR "Copyright 2024 JohnCrosby"
#define PLUG_CLASS_NAME SideChainer

#define BUNDLE_NAME "SideChainer"
#define BUNDLE_MFR "JohnCrosby"
#define BUNDLE_DOMAIN "com"

#define SHARED_RESOURCES_SUBPATH "SideChainer"

#define PLUG_CHANNEL_IO "\
1-1 \
1.1-1 \
1.2-1 \
2-2 \
2.1-2 \
2.2-2"

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

#define AUV2_ENTRY SideChainer_Entry
#define AUV2_ENTRY_STR "SideChainer_Entry"
#define AUV2_FACTORY SideChainer_Factory
#define AUV2_VIEW_CLASS SideChainer_View
#define AUV2_VIEW_CLASS_STR "SideChainer_View"

#define AAX_TYPE_IDS 'IEF1', 'IEF2'
#define AAX_TYPE_IDS_AUDIOSUITE 'IEA1', 'IEA2'
#define AAX_PLUG_MFR_STR "JoCr"
#define AAX_PLUG_NAME_STR "SideChainer\nJCsc"
#define AAX_PLUG_CATEGORY_STR "SWGenerators"
#define AAX_DOES_AUDIOSUITE 1

#define VST3_SUBCATEGORY "Fx|Tools"

#define CLAP_MANUAL_URL "https://john-crosby.com"
#define CLAP_SUPPORT_URL "https://john-crosby.com"
#define CLAP_DESCRIPTION "Routing utility"
#define CLAP_FEATURES "audio-effect"//, "utility"

#define APP_NUM_CHANNELS 2
#define APP_N_VECTOR_WAIT 0
#define APP_MULT 1
#define APP_COPY_AUV3 0
#define APP_SIGNAL_VECTOR_SIZE 64
