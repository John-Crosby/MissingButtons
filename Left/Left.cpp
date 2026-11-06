#include "Left.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

Left::Left(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{
 
}

#if IPLUG_DSP
void Left::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++) {
    outputs[1][s] = outputs[0][s] = inputs[0][s];
  }
}
#endif
