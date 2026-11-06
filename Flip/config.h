// Flip -- polarity inverter (every channel).
#define PLUG_NAME "Flip"
#define PLUG_CLASS_NAME Flip
#define BUNDLE_NAME "Flip"
#define SHARED_RESOURCES_SUBPATH "Flip"
#define PLUG_UNIQUE_ID 'FlP9'
#define PLUG_CHANNEL_IO "1-1 2-2"

#define AUV2_ENTRY Flip_Entry
#define AUV2_ENTRY_STR "Flip_Entry"
#define AUV2_FACTORY Flip_Factory
#define AUV2_VIEW_CLASS Flip_View
#define AUV2_VIEW_CLASS_STR "Flip_View"

#define AAX_PLUG_NAME_STR "Flip\nFlip"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define CLAP_DESCRIPTION "Polarity inverter, Phase reverse"

#include "../common/config-common.h"
