// Side -- L = (L - R) / 2, R = (R - L) / 2 (the same signal, polarity inverted).
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Side final : public Plugin
{
public:
  Side(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Side::Side(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Side::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  // Read both inputs before writing: the host may process in place.
  for (int s = 0; s < nFrames; s++)
  {
    const sample d = (inputs[0][s] - inputs[1][s]) * sample(0.5);
    outputs[0][s] = d;
    outputs[1][s] = -d;
  }
}
