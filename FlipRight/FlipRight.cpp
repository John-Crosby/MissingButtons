#include "FlipRight.h"
#include "IPlug_include_in_plug_src.h"
//#include "IControls.h"

FlipRight::FlipRight(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(kNumParams, kNumPresets))
{

}

#if IPLUG_DSP
void FlipRight::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  const int nChans = NInChansConnected();
        if (nChans > 1){
        for (int s = 0; s < nFrames; s++) {
            outputs[0][s] = inputs[0][s];
            outputs[1][s] = inputs[1][s] * -1.;
        }
    }
    else{
        for (int s = 0; s < nFrames; s++) {
            outputs[0][s] = inputs[0][s];
            outputs[1][s] = inputs[0][s] * -1.;
        }
    }

}
#endif
