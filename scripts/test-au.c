// test-au.c -- feed a known stereo signal through MissingButtons AU components
// the way a host does (render callback for the input, AudioUnitRender for the
// output) and check every output sample against the expected result.
//
//   clang -framework AudioToolbox -framework CoreFoundation -o /tmp/test-au scripts/test-au.c
//   /tmp/test-au                                  # the installed /Library components
//   /tmp/test-au build-x/out/*.component          # any built components
//
// Each component is loaded from its bundle and registered in this process under
// a private ID, so it does not matter which copy macOS has registered.
// Three host buffer modes are tested:
//   plugin-out  output mData = NULL (the plug-in supplies the output buffers)
//   host-out    separate host output buffers
//   in-place    the host uses the same buffers for input and output

#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#define FRAMES 256
#define BLOCKS 4

static float gHostIn[2][FRAMES];
static float gHostOut[2][FRAMES];
static int gMode;

static float InL(long t) { return (float)((t % 1000) + 1) / 1000.0f; }
static float InR(long t) { return -(float)((t % 700) + 1) / 2000.0f; }

static OSStatus InputCallback(void* ref, AudioUnitRenderActionFlags* flags, const AudioTimeStamp* ts,
                              UInt32 bus, UInt32 n, AudioBufferList* io)
{
  long t0 = (long) ts->mSampleTime;
  for (UInt32 c = 0; c < io->mNumberBuffers && c < 2; c++)
  {
    float* p = (float*) io->mBuffers[c].mData;
    if (gMode == 2 || !p) { p = gHostIn[c]; io->mBuffers[c].mData = p; }
    for (UInt32 s = 0; s < n; s++) p[s] = (c == 0) ? InL(t0 + s) : InR(t0 + s);
  }
  return noErr;
}

static int Expected(const char* name, float l, float r, float* oL, float* oR)
{
  const float k = 0.70710678118654752440f;
  if (!strcmp(name, "Flip"))             { *oL = -l;            *oR = -r; }
  else if (!strcmp(name, "FlipRight"))   { *oL = l;             *oR = -r; }
  else if (!strcmp(name, "Left"))        { *oL = l;             *oR = l; }
  else if (!strcmp(name, "Right"))       { *oL = r;             *oR = r; }
  else if (!strcmp(name, "Mono"))        { *oL = (l + r) * 0.5f; *oR = *oL; }
  else if (!strcmp(name, "MidSide"))     { *oL = (l + r) * k;   *oR = (l - r) * k; }
  else if (!strcmp(name, "Side"))        { *oL = (l - r) * 0.5f; *oR = -*oL; }
  else if (!strcmp(name, "Swap"))        { *oL = r;             *oR = l; }
  else if (!strcmp(name, "SideChainer")) { *oL = 0;             *oR = 0; }  // no sidechain connected
  else return 0;
  return 1;
}

static void Check(OSStatus err, const char* what)
{
  if (err) printf("    %s failed: %d\n", what, (int) err);
}

static int TestComponent(const char* path, int index)
{
  char name[256];
  const char* base = strrchr(path, '/');
  base = base ? base + 1 : path;
  snprintf(name, sizeof(name), "%s", base);
  char* dot = strstr(name, ".component");
  if (dot) *dot = 0;
  while (strlen(name) && name[strlen(name) - 1] == '/') name[strlen(name) - 1] = 0;

  printf("%s  (%s)\n", name, path);
  float dummyL, dummyR;
  if (!Expected(name, 0, 0, &dummyL, &dummyR)) { printf("    unknown plug-in name\n"); return 1; }

  CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*) path, strlen(path), true);
  CFBundleRef bundle = url ? CFBundleCreate(NULL, url) : NULL;
  if (!bundle || !CFBundleLoadExecutable(bundle)) { printf("    cannot load the bundle\n"); return 1; }
  char factoryName[300];
  snprintf(factoryName, sizeof(factoryName), "%s_Factory", name);
  CFStringRef fn = CFStringCreateWithCString(NULL, factoryName, kCFStringEncodingUTF8);
  AudioComponentFactoryFunction factory = (AudioComponentFactoryFunction) CFBundleGetFunctionPointerForName(bundle, fn);
  if (!factory) { printf("    %s not exported\n", factoryName); return 1; }

  AudioComponentDescription desc = { kAudioUnitType_Effect, 'Tst0' + (OSType) index, 'MBts', 0, 0 };
  AudioComponent comp = AudioComponentRegister(&desc, CFSTR("MBtest"), 0x10000, factory);
  AudioUnit unit = NULL;
  if (!comp || AudioComponentInstanceNew(comp, &unit) || !unit) { printf("    cannot instantiate\n"); return 1; }

  AudioStreamBasicDescription asbd = { 0 };
  asbd.mSampleRate = 48000;
  asbd.mFormatID = kAudioFormatLinearPCM;
  asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
  asbd.mBytesPerPacket = 4; asbd.mFramesPerPacket = 1; asbd.mBytesPerFrame = 4;
  asbd.mChannelsPerFrame = 2; asbd.mBitsPerChannel = 32;
  Check(AudioUnitSetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(asbd)), "input format");
  Check(AudioUnitSetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, sizeof(asbd)), "output format");
  UInt32 maxFrames = FRAMES;
  Check(AudioUnitSetProperty(unit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFrames, sizeof(maxFrames)), "max frames");
  AURenderCallbackStruct cb = { InputCallback, NULL };
  Check(AudioUnitSetProperty(unit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &cb, sizeof(cb)), "render callback");
  OSStatus err = AudioUnitInitialize(unit);
  if (err) { printf("    AudioUnitInitialize failed: %d\n", (int) err); return 1; }

  static const char* modeNames[] = { "plugin-out", "host-out", "in-place" };
  int failures = 0;
  for (gMode = 0; gMode < 3; gMode++)
  {
    double maxErr = 0; int firstBad = -1; float gotL = 0, gotR = 0, expL = 0, expR = 0;
    for (int b = 0; b < BLOCKS; b++)
    {
      struct { AudioBufferList list; AudioBuffer extra; } abl;
      memset(&abl, 0, sizeof(abl));
      abl.list.mNumberBuffers = 2;
      for (int c = 0; c < 2; c++)
      {
        abl.list.mBuffers[c].mNumberChannels = 1;
        abl.list.mBuffers[c].mDataByteSize = FRAMES * sizeof(float);
        abl.list.mBuffers[c].mData = gMode == 0 ? NULL : gMode == 1 ? gHostOut[c] : gHostIn[c];
      }
      AudioTimeStamp ts = { 0 };
      ts.mSampleTime = (Float64)(gMode * 100000 + b * FRAMES);
      ts.mFlags = kAudioTimeStampSampleTimeValid;
      AudioUnitRenderActionFlags flags = 0;
      err = AudioUnitRender(unit, &flags, &ts, 0, FRAMES, &abl.list);
      if (err) { printf("    %-10s AudioUnitRender failed: %d\n", modeNames[gMode], (int) err); failures++; break; }
      const float* oL = (const float*) abl.list.mBuffers[0].mData;
      const float* oR = (const float*) abl.list.mBuffers[1].mData;
      long t0 = (long) ts.mSampleTime;
      for (int s = 0; s < FRAMES; s++)
      {
        float eL, eR;
        Expected(name, InL(t0 + s), InR(t0 + s), &eL, &eR);
        double e = fmax(fabs(oL[s] - eL), fabs(oR[s] - eR));
        if (!(e <= maxErr)) maxErr = e;   // also catches NaN
        if (e > 1e-6 && firstBad < 0) { firstBad = b * FRAMES + s; gotL = oL[s]; gotR = oR[s]; expL = eL; expR = eR; }
      }
    }
    if (err) continue;
    if (firstBad < 0) printf("    %-10s OK\n", modeNames[gMode]);
    else
    {
      failures++;
      printf("    %-10s FAIL  max error %g; first at frame %d: got (%g, %g) expected (%g, %g)\n",
             modeNames[gMode], maxErr, firstBad, gotL, gotR, expL, expR);
    }
  }
  AudioUnitUninitialize(unit);
  AudioComponentInstanceDispose(unit);
  return failures;
}

int main(int argc, char** argv)
{
  static const char* names[] = { "Flip", "FlipRight", "Left", "Right", "Mono", "MidSide", "Side", "Swap", "SideChainer" };
  int failures = 0, n = 0;
  if (argc > 1)
    for (int i = 1; i < argc; i++) failures += TestComponent(argv[i], n++);
  else
    for (int i = 0; i < 9; i++)
    {
      char path[512];
      snprintf(path, sizeof(path), "/Library/Audio/Plug-Ins/Components/%s.component", names[i]);
      failures += TestComponent(path, n++);
    }
  printf("\n%s\n", failures ? "SOME TESTS FAILED" : "ALL OK");
  return failures ? 1 : 0;
}
