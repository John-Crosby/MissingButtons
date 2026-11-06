// Flip -- inverts the polarity of every channel.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class Flip final : public Plugin
{
public:
  Flip(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

Flip::Flip(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void Flip::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  const int nChans = NInChansConnected();

  for (int c = 0; c < nChans; c++)
  {
    const sample* in = inputs[c];
    sample* out = outputs[c];

    for (int s = 0; s < nFrames; s++)
      out[s] = -in[s];
  }
}
