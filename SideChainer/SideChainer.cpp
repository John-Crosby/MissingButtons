// SideChainer -- the sidechain input replaces the main input.
// The sidechain starts at input channel 2 (after the two main-bus channels).
// A mono sidechain goes to both outputs; with no sidechain the output is silent.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class SideChainer final : public Plugin
{
public:
  SideChainer(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

SideChainer::SideChainer(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void SideChainer::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  const sample* scL = inputs[2];
  const sample* scR = inputs[IsChannelConnected(ERoute::kInput, 3) ? 3 : 2];

  for (int s = 0; s < nFrames; s++)
  {
    const sample l = scL[s];
    const sample r = scR[s];
    outputs[0][s] = l;
    outputs[1][s] = r;
  }
}
