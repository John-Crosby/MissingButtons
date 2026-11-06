// MidSide -- M = (L + R) / sqrt 2, S = (L - R) / sqrt 2.
// The matrix is its own inverse: a second instance decodes back to L/R.
#include "IPlug_include_in_plug_hdr.h"

using namespace iplug;

class MidSide final : public Plugin
{
public:
  MidSide(const InstanceInfo& info);
  void ProcessBlock(sample** inputs, sample** outputs, int nFrames) override;
};

#include "IPlug_include_in_plug_src.h"

MidSide::MidSide(const InstanceInfo& info)
: iplug::Plugin(info, MakeConfig(0, 0))
{
}

void MidSide::ProcessBlock(sample** inputs, sample** outputs, int nFrames)
{
  constexpr sample kSqrtHalf = sample(0.70710678118654752440);

  // Read both inputs before writing: the host may process in place.
  for (int s = 0; s < nFrames; s++)
  {
    const sample l = inputs[0][s];
    const sample r = inputs[1][s];
    outputs[0][s] = (l + r) * kSqrtHalf;
    outputs[1][s] = (l - r) * kSqrtHalf;
  }
}
