#include "MidSide.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

MidSide::MidSide(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{
 
}

#if IPLUG_DSP
void MidSide::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++) {
      outputs[0][s] = (inputs[0][s] + inputs[1][s]) * 0.70710678118654752440084436210484903928483593768847;
      outputs[1][s] = (inputs[0][s] - inputs[1][s]) * 0.70710678118654752440084436210484903928483593768847;
  }
}
#endif
