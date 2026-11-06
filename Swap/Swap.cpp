// Swap -- left and right exchanged.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Swap final : public Plugin
{
public:
  Swap(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Swap::Swap(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Swap::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  // Read both inputs before writing: the host may process in place.
  for (int s = 0; s < nFrames; s++)
  {
    const sample l = inputs[0][s];
    const sample r = inputs[1][s];
    outputs[0][s] = r;
    outputs[1][s] = l;
  }
}
