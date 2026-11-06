# mb_add_plugin(): called from <Plugin>/CMakeLists.txt; the plug-in name is the folder name.
# Builds MB_FORMATS from <Plugin>/<Plugin>.cpp + <Plugin>/config.h, no UI, float samples,
# and gives the macOS bundles Info.plists generated from config.h (so there are no
# per-plug-in plist files to keep in step).

set(MB_PLIST_DIR "${CMAKE_CURRENT_LIST_DIR}/plist")

option(MB_SAMPLE_DOUBLE "Process in double (iPlug2's default) instead of float" OFF)
if(MB_SAMPLE_DOUBLE)
  set(MB_SAMPLE_TYPE SAMPLE_TYPE_DOUBLE)
else()
  set(MB_SAMPLE_TYPE SAMPLE_TYPE_FLOAT)
endif()

# Value of "#define <key> <value>" in the text; quotes and '' stripped.
function(_mb_define out text key)
  if(NOT text MATCHES "#define ${key}[ \t]+([^\n]*)")
    message(FATAL_ERROR "mb_add_plugin: ${key} not found in config.h / common/config-common.h")
  endif()
  string(STRIP "${CMAKE_MATCH_1}" _v)
  string(REGEX REPLACE "^[\"']" "" _v "${_v}")
  string(REGEX REPLACE "[\"']$" "" _v "${_v}")
  set(${out} "${_v}" PARENT_SCOPE)
endfunction()

function(_mb_info_plists name)
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/config.h" _cfg)
  file(READ "${MB_ROOT}/common/config-common.h" _common)
  set(_all "${_cfg}\n${_common}")

  _mb_define(MB_NAME        "${_all}" PLUG_NAME)
  _mb_define(MB_BUNDLE_NAME "${_all}" BUNDLE_NAME)
  _mb_define(MB_UNIQUE_ID   "${_all}" PLUG_UNIQUE_ID)
  _mb_define(MB_MFR         "${_all}" PLUG_MFR)
  _mb_define(MB_MFR_ID      "${_all}" PLUG_MFR_ID)
  _mb_define(MB_VERSION_STR "${_all}" PLUG_VERSION_STR)
  _mb_define(MB_VERSION_HEX "${_all}" PLUG_VERSION_HEX)
  _mb_define(MB_COPYRIGHT   "${_all}" PLUG_COPYRIGHT_STR)
  _mb_define(_domain        "${_all}" BUNDLE_DOMAIN)
  _mb_define(_bmfr          "${_all}" BUNDLE_MFR)
  _mb_define(MB_AU_FACTORY  "${_all}" AUV2_FACTORY)
  _mb_define(MB_AU_VIEW     "${_all}" AUV2_VIEW_CLASS)
  math(EXPR MB_VERSION_INT "${MB_VERSION_HEX}" OUTPUT_FORMAT DECIMAL)
  string(LENGTH "${MB_UNIQUE_ID}" _len)
  if(NOT _len EQUAL 4)
    message(FATAL_ERROR "${name}: PLUG_UNIQUE_ID must be 4 characters")
  endif()
  set(MB_MIN_MACOS "${CMAKE_OSX_DEPLOYMENT_TARGET}")
  set(_out "${CMAKE_BINARY_DIR}/plist/${name}")
  set(MB_AU_BUNDLE_ID "${_domain}.${_bmfr}.audiounit.${MB_BUNDLE_NAME}")

  configure_file("${MB_PLIST_DIR}/AU-Info.plist.in" "${_out}/${name}-AU-Info.plist" @ONLY)

  # format suffix | bundle id part | package type | signature | extra keys
  foreach(_f "vst3|vst3|BNDL|${MB_UNIQUE_ID}" "clap|clap|BNDL|${MB_UNIQUE_ID}" "aax|aax|TDMw|PTul")
    string(REPLACE "|" ";" _f "${_f}")
    list(GET _f 0 _suffix)
    list(GET _f 1 _idpart)
    list(GET _f 2 MB_PKG_TYPE)
    list(GET _f 3 MB_SIGNATURE)
    set(MB_BUNDLE_ID "${_domain}.${_bmfr}.${_idpart}.${MB_BUNDLE_NAME}")
    set(MB_EXTRA_KEYS "")
    if(_suffix STREQUAL "aax")
      set(MB_EXTRA_KEYS "\t<key>LSMultipleInstancesProhibited</key>\n\t<string>true</string>\n\t<key>LSPrefersCarbon</key>\n\t<false/>\n\t<key>NSAppleScriptEnabled</key>\n\t<string>No</string>\n")
    endif()
    string(TOUPPER "${_suffix}" _up)
    configure_file("${MB_PLIST_DIR}/Bundle-Info.plist.in" "${_out}/${name}-${_up}-Info.plist" @ONLY)
  endforeach()

  foreach(_t "au|AU" "vst3|VST3" "clap|CLAP" "aax|AAX")
    string(REPLACE "|" ";" _t "${_t}")
    list(GET _t 0 _suffix)
    list(GET _t 1 _up)
    if(TARGET ${name}-${_suffix})
      set_target_properties(${name}-${_suffix} PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${_out}/${name}-${_up}-Info.plist")
    endif()
  endforeach()
endfunction()

function(mb_add_plugin)
  get_filename_component(name "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  iplug_add_plugin(${name}
    SOURCES
      ${name}.cpp
      config.h
      ${MB_ROOT}/common/config-common.h
    UI NONE
    DEFINES NO_IGRAPHICS ${MB_SAMPLE_TYPE}
    FORMATS ${MB_FORMATS}
  )

  if(APPLE)
    _mb_info_plists(${name})
  endif()
endfunction()
