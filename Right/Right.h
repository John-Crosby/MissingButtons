#pragma once

#include "IPlug_include_in_plug_hdr.h"

const int kNumPresets = 0;

enum EParams
{
  kNumParams = 0
};

using namespace iplug;
using namespace igraphics;

class Right final : public Plugin
{
public:
  Right(const InstanceInfo& info);

#if IPLUG_DSP // http://bit.ly/2S64BDd
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
#endif
};
