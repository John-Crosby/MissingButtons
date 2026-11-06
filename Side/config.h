// Side -- the side signal, (L - R) / 2 left and its inverse right.
#define PLUG_NAME "Side"
#define PLUG_CLASS_NAME Side
#define BUNDLE_NAME "Side"
#define SHARED_RESOURCES_SUBPATH "Side"
#define PLUG_UNIQUE_ID 'sde4'
#define PLUG_CHANNEL_IO "2-2"

#define AUV2_ENTRY Side_Entry
#define AUV2_ENTRY_STR "Side_Entry"
#define AUV2_FACTORY Side_Factory
#define AUV2_VIEW_CLASS Side_View
#define AUV2_VIEW_CLASS_STR "Side_View"

#define AAX_PLUG_NAME_STR "Side\nSide"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define CLAP_DESCRIPTION "Side from Stereo extractor"

#include "../common/config-common.h"
