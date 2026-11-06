// Mono -- (L + R) / 2 on both outputs.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Mono final : public Plugin
{
public:
  Mono(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Mono::Mono(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Mono::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++)
  {
    const sample m = (inputs[0][s] + inputs[1][s]) * sample(0.5);
    outputs[0][s] = m;
    outputs[1][s] = m;
  }
}
