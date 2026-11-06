// MidSide -- M/S encoder and decoder (the same matrix both ways).
#define PLUG_NAME "MidSide"
#define PLUG_CLASS_NAME MidSide
#define BUNDLE_NAME "MidSide"
#define SHARED_RESOURCES_SUBPATH "MidSide"
#define PLUG_UNIQUE_ID 'MiS7'
#define PLUG_CHANNEL_IO "2-2"

#define AUV2_ENTRY MidSide_Entry
#define AUV2_ENTRY_STR "MidSide_Entry"
#define AUV2_FACTORY MidSide_Factory
#define AUV2_VIEW_CLASS MidSide_View
#define AUV2_VIEW_CLASS_STR "MidSide_View"

#define AAX_PLUG_NAME_STR "MidSide\nM/S"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define CLAP_DESCRIPTION "Mid / Side Encoder Decoder * 0.707"

#include "../common/config-common.h"
