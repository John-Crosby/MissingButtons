// Mono -- (L + R) / 2 on both outputs.
#define PLUG_NAME "Mono"
#define PLUG_CLASS_NAME Mono
#define BUNDLE_NAME "Mono"
#define SHARED_RESOURCES_SUBPATH "Mono"
#define PLUG_UNIQUE_ID 'moNo'
#define PLUG_CHANNEL_IO "2-2"

#define AUV2_ENTRY Mono_Entry
#define AUV2_ENTRY_STR "Mono_Entry"
#define AUV2_FACTORY Mono_Factory
#define AUV2_VIEW_CLASS Mono_View
#define AUV2_VIEW_CLASS_STR "Mono_View"

#define AAX_PLUG_NAME_STR "Mono\nMono"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define CLAP_DESCRIPTION "Stereo to Mono Converter"

#include "../common/config-common.h"
