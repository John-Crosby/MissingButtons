// Left -- the left channel on both outputs.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Left final : public Plugin
{
public:
  Left(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Left::Left(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Left::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  for (int s = 0; s < nFrames; s++)
  {
    const sample l = inputs[0][s];
    outputs[0][s] = l;
    outputs[1][s] = l;
  }
}
