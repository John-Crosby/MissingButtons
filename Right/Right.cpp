#include "Right.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

Right::Right(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{
 
}

#if IPLUG_DSP
void Right::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++) {
      outputs[1][s] = outputs[0][s] = inputs[1][s];
  }
}
#endif
