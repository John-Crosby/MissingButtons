#include "SideChainer.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

SideChainer::SideChainer(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets)){}

#if IPLUG_DSP
void SideChainer::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++) {
    outputs[0][s] = inputs[2][s];
    outputs[1][s] = inputs[3][s];
  }
}
#endif
