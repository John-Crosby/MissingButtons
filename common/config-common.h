// MissingButtons -- settings shared by all nine plug-ins.
// Each <Plugin>/config.h sets the plug-in's identity and then includes this file.
//
// The version below is the version of the whole collection: CMake, the macOS
// installer and the Windows installer all read it from here.
//
// Never change PLUG_MFR, PLUG_MFR_ID, BUNDLE_*, the unique IDs or the AAX type
// IDs: hosts find the plug-ins in saved sessions by them.

#ifndef MISSINGBUTTONS_CONFIG_COMMON_H
#define MISSINGBUTTONS_CONFIG_COMMON_H

#define PLUG_VERSION_HEX 0x00010100
#define PLUG_VERSION_STR "1.1.0"

#define PLUG_MFR "JohnCrosby"
#define PLUG_MFR_ID 'JoCr'
#define PLUG_URL_STR "https://john-crosby.com"
#define PLUG_EMAIL_STR "info@john-crosby.com"
#define PLUG_COPYRIGHT_STR "Copyright 2024-2026 John Crosby"

#define BUNDLE_MFR "JohnCrosby"
#define BUNDLE_DOMAIN "com"

// No UI, no parameters, no presets, no state, no latency.
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

// AAX: one type ID per PLUG_CHANNEL_IO entry, in the same order
// (a plug-in with a different layout list defines its own before including this).
#ifndef AAX_TYPE_IDS
  #define AAX_TYPE_IDS 'IEF1', 'IEF2'
  #define AAX_TYPE_IDS_AUDIOSUITE 'IEA1', 'IEA2'
#endif
#define AAX_PLUG_MFR_STR "JoCr"
#define AAX_DOES_AUDIOSUITE 1

#define VST3_SUBCATEGORY "Fx|Tools"

#define CLAP_MANUAL_URL "https://john-crosby.com"
#define CLAP_SUPPORT_URL "https://john-crosby.com"
#define CLAP_FEATURES "audio-effect"

#endif
