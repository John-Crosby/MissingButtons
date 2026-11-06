// SideChainer -- outputs the sidechain input instead of the main input.
#define PLUG_NAME "SideChainer"
#define PLUG_CLASS_NAME SideChainer
#define BUNDLE_NAME "SideChainer"
#define SHARED_RESOURCES_SUBPATH "SideChainer"
#define PLUG_UNIQUE_ID 'JCsc'
#define PLUG_CHANNEL_IO "\
1-1 \
1.1-1 \
1.2-1 \
2-2 \
2.1-2 \
2.2-2"

#define AUV2_ENTRY SideChainer_Entry
#define AUV2_ENTRY_STR "SideChainer_Entry"
#define AUV2_FACTORY SideChainer_Factory
#define AUV2_VIEW_CLASS SideChainer_View
#define AUV2_VIEW_CLASS_STR "SideChainer_View"

#define AAX_PLUG_NAME_STR "SideChainer\nSdCh"
#define AAX_PLUG_CATEGORY_STR "SWGenerators"
#define CLAP_DESCRIPTION "Routes the sidechain input to the output"

#include "../common/config-common.h"
