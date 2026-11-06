// FlipRight -- left unchanged, right polarity inverted.
// Stereo in: L = l, R = -r.  Mono in: L = x, R = -x.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class FlipRight final : public Plugin
{
public:
  FlipRight(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

FlipRight::FlipRight(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void FlipRight::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  const sample* inL = inputs[0];
  const sample* inR = inputs[NInChansConnected() > 1 ? 1 : 0];

  // Read both inputs before writing: the host may process in place.
  for (int s = 0; s < nFrames; s++)
  {
    const sample l = inL[s];
    const sample r = inR[s];
    outputs[0][s] = l;
    outputs[1][s] = -r;
  }
}
