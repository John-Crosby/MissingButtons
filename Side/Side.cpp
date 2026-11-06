#include "Side.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

Side::Side(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{
 

}

#if IPLUG_DSP
void Side::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++) {
      outputs[0][s] = (inputs[0][s] - inputs[1][s]) * 0.5;
      outputs[1][s] = (inputs[1][s] - inputs[0][s]) * 0.5;
  }
}
#endif
