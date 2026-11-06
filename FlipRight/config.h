// FlipRight -- inverts the polarity of the right channel only.
#define PLUG_NAME "FlipRight"
#define PLUG_CLASS_NAME FlipRight
#define BUNDLE_NAME "FlipRight"
#define SHARED_RESOURCES_SUBPATH "FlipRight"
#define PLUG_UNIQUE_ID 'APdG'

// 1.1.0: 1-1 (pass-through: a mono track has no right channel) replaced by 1-2
// (mono in -> L = x, R = -x). The 2-2 layout keeps its AAX type ID 'IEF2'; the
// new 1-2 layout gets new IDs, so 'IEF1' (the old 1-1) is never reused.
#define PLUG_CHANNEL_IO "1-2 2-2"
#define AAX_TYPE_IDS 'IEF3', 'IEF2'
#define AAX_TYPE_IDS_AUDIOSUITE 'IEA3', 'IEA2'

#define AUV2_ENTRY FlipRight_Entry
#define AUV2_ENTRY_STR "FlipRight_Entry"
#define AUV2_FACTORY FlipRight_Factory
#define AUV2_VIEW_CLASS FlipRight_View
#define AUV2_VIEW_CLASS_STR "FlipRight_View"

#define AAX_PLUG_NAME_STR "FlipRight\nFlpR"
#define AAX_PLUG_CATEGORY_STR "SoundField"
#define CLAP_DESCRIPTION "Right channel polarity inverter"

#include "../common/config-common.h"
