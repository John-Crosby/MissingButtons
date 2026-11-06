// Right -- the right channel on both outputs.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Right final : public Plugin
{
public:
  Right(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Right::Right(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Right::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++)
  {
    const sample r = inputs[1][s];
    outputs[0][s] = r;
    outputs[1][s] = r;
  }
}
