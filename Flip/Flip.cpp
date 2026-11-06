#include "Flip.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

Flip::Flip(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{

}

#if IPLUG_DSP
void Flip::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  const int nChans = NInChansConnected();
  for (int c = 0; c < nChans; c++) {
    for (int s = 0; s < nFrames; s++) {
      outputs[c][s] = inputs[c][s] * -1.;
    }
  }
}
#endif
