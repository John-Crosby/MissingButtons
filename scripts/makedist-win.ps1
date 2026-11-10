<#
makedist-win.ps1 -- build, sign and package the MissingButtons Windows installer
(all nine plug-ins). Run it through makedist-win.bat (it bypasses the PowerShell
execution policy):

  scripts\makedist-win.bat                     VST3 + CLAP + AAX
  scripts\makedist-win.bat -NoAax              without AAX
  scripts\makedist-win.bat -NoBuild            sign + package what is already in build-win\out
  scripts\makedist-win.bat -SavePacePassword   store the PACE password (once), then stop

Output: installer\build-win\MissingButtons-<version>-win.exe, and the CMake
build log in installer\build-win\build-win.log.

Before every run: SimplySign Desktop connected (tray icon -> Connect, token from
the phone app). The Certum code-signing certificate is then in the Windows
certificate store and is found here by itself; set WIN_CERT_SHA1 to pick one by
thumbprint.

One-time setup:
  - Visual Studio 2022 (Desktop C++ with CMake tools, Windows SDK for signtool),
    Inno Setup 6, PACE Eden tools (wraptool; set WRAPTOOL=...\wraptool.exe if it
    is not found), the AAX SDK in iPlug2\Dependencies\IPlug\AAX_SDK
  - PACE password: scripts\makedist-win.bat -SavePacePassword
    Stored in Windows Credential Manager as the generic credential
    "PACE wraptool" (the counterpart of the macOS Keychain item); never written
    in this file or a log. Shared with the other John Crosby plug-ins.

Steps: CMake build (Visual Studio 2022, x64, Release) into a fresh build-win ->
sign the VST3 + CLAP binaries with signtool and each AAX with PACE wraptool
under its own wrap config GUID (Certum certificate, SHA-256, RFC 3161
timestamp) -> check every AAX exports ACFRegisterPlugin and every signature
verifies and is timestamped -> Inno Setup, which signs the setup and the
uninstaller with the same certificate -> check the setup's signature.
#>
param([switch]$NoAax, [switch]$NoBuild, [switch]$SavePacePassword)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

# ---- configuration ---------------------------------------------------------------
$Name           = 'MissingButtons'
$PaceAccount    = 'krizaj.janez@gmail.com'
$PaceCredential = 'PACE wraptool'
$CertIssuer     = 'Certum'
$TimestampUrl   = 'http://time.certum.pl'
$WraptoolSignOptions = "/fd sha256 /tr $TimestampUrl /td sha256"

# Plug-in -> PACE Central wrap configuration GUID (same table as makedist-mac.sh).
$Plugins = [ordered]@{
  Flip        = '70DA6F30-3598-11F0-9A88-005056928F3B'
  FlipRight   = 'BF0CE5C0-3598-11F0-9A88-005056928F3B'
  Left        = '1CAC7CE0-3599-11F0-9A88-005056928F3B'
  Right       = 'FDC48AB0-3599-11F0-AB63-00505692AD3E'
  Mono        = 'B3E5DDE0-3599-11F0-BC08-005056920FF7'
  MidSide     = '6751AE00-3599-11F0-BC08-005056920FF7'
  Side        = '49967C00-359A-11F0-88CE-00505692C25A'
  Swap        = 'DB668490-359A-11F0-88CE-00505692C25A'
  SideChainer = '93B14770-359A-11F0-9A88-005056928F3B'
}

$Out     = 'installer\build-win'
$Build   = 'build-win'
$BinDir  = "$Build\out"
$WithAax = -not $NoAax

function Fail([string]$msg) { Write-Host "=== FAILED: $msg ===" -ForegroundColor Red; exit 1 }
function Step([string]$msg) { Write-Host ''; Write-Host "=== $msg ===" -ForegroundColor Cyan }

# ---- Windows Credential Manager (generic credential) ----------------------------
Add-Type -Namespace JC -Name Cred -MemberDefinition @'
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct CREDENTIAL {
  public int Flags; public int Type; public string TargetName; public string Comment;
  public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
  public int CredentialBlobSize; public IntPtr CredentialBlob; public int Persist;
  public int AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName;
}
[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool CredRead(string target, int type, int flags, out IntPtr cred);
[DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool CredWrite(ref CREDENTIAL cred, int flags);
[DllImport("advapi32.dll")]
public static extern void CredFree(IntPtr cred);
'@

function Read-StoredPassword([string]$target) {
  $p = [IntPtr]::Zero
  if (-not [JC.Cred]::CredRead($target, 1, 0, [ref]$p)) { return $null }
  try {
    $c = [Runtime.InteropServices.Marshal]::PtrToStructure($p, [type][JC.Cred+CREDENTIAL])
    return [Runtime.InteropServices.Marshal]::PtrToStringUni($c.CredentialBlob, [int]($c.CredentialBlobSize / 2))
  } finally { [JC.Cred]::CredFree($p) }
}

function Write-StoredPassword([string]$target, [string]$user, [Security.SecureString]$secure) {
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $bytes = [Text.Encoding]::Unicode.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  $blob = [Runtime.InteropServices.Marshal]::AllocHGlobal($bytes.Length)
  try {
    [Runtime.InteropServices.Marshal]::Copy($bytes, 0, $blob, $bytes.Length)
    $c = New-Object 'JC.Cred+CREDENTIAL'
    $c.Type = 1; $c.TargetName = $target; $c.UserName = $user; $c.Persist = 2
    $c.CredentialBlobSize = $bytes.Length; $c.CredentialBlob = $blob
    if (-not [JC.Cred]::CredWrite([ref]$c, 0)) {
      Fail "CredWrite failed (error $([Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
    }
  } finally { [Runtime.InteropServices.Marshal]::FreeHGlobal($blob) }
}

if ($SavePacePassword) {
  $pw = Read-Host "PACE (iLok) password for $PaceAccount" -AsSecureString
  Write-StoredPassword $PaceCredential $PaceAccount $pw
  Write-Host "Saved in Windows Credential Manager as `"$PaceCredential`"."
  exit 0
}

# ---- tools ----------------------------------------------------------------------
function Find-First([string[]]$patterns) {
  foreach ($p in $patterns) {
    $hit = Get-ChildItem $p -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
    if ($hit) { return $hit.FullName }
  }
  return $null
}

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = $null
if (Test-Path $vswhere) { $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1 }

$cmake = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if (-not $cmake -and $vsPath) {
  $c = "$vsPath\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
  if (Test-Path $c) { $cmake = $c }
}
if (-not $NoBuild -and -not $cmake) { Fail 'CMake not found (Visual Studio 2022 "C++ CMake tools", or cmake.org)' }

$dumpbin = $null
if ($vsPath) { $dumpbin = Find-First @("$vsPath\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe") }

# Newest Windows SDK first: folder names are versions (10.0.xxxxx.0).
$signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
  Sort-Object { try { [version]$_.Directory.Parent.Name } catch { [version]'0.0' } } -Descending |
  Select-Object -First 1 -ExpandProperty FullName
if (-not $signtool) { Fail 'signtool.exe not found (install the Windows SDK from the Visual Studio Installer)' }

$iscc = Find-First @("${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe", "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
                     "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe")
if (-not $iscc) { Fail 'Inno Setup 6 not found' }

$wraptool = $null; $pacePw = $null
if ($WithAax) {
  $wraptool = $env:WRAPTOOL
  if (-not $wraptool) { $wraptool = (Get-Command wraptool -ErrorAction SilentlyContinue).Source }
  if (-not $wraptool) {
    $wraptool = Find-First @("$env:ProgramFiles\PACEAntiPiracy\Eden\Fusion\Versions\*\wraptool.exe",
                             "$env:ProgramFiles\PACEAntiPiracy\Eden\Fusion\Versions\*\bin\wraptool.exe",
                             "${env:ProgramFiles(x86)}\PACEAntiPiracy\Eden\Fusion\Versions\*\wraptool.exe",
                             "${env:ProgramFiles(x86)}\PACEAntiPiracy\Eden\Fusion\Versions\*\bin\wraptool.exe")
  }
  if (-not $wraptool -or -not (Test-Path $wraptool)) { Fail 'wraptool not found -- install PACE Eden tools, set WRAPTOOL=..., or use -NoAax' }
  $pacePw = Read-StoredPassword $PaceCredential
  if (-not $pacePw) { Fail "PACE password not in Credential Manager -- run: scripts\makedist-win.bat -SavePacePassword" }
}

# ---- version + certificate --------------------------------------------------------
$m = Select-String -Path common\config-common.h -Pattern '^#define PLUG_VERSION_STR "([^"]+)"' | Select-Object -First 1
if (-not $m) { Fail 'PLUG_VERSION_STR not found in common\config-common.h' }
$Version = $m.Matches[0].Groups[1].Value

if ($env:WIN_CERT_SHA1) {
  $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $env:WIN_CERT_SHA1.ToUpper() } | Select-Object -First 1
} else {
  $cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert |
    Where-Object { $_.Issuer -match $CertIssuer -and $_.NotAfter -gt (Get-Date) -and $_.NotBefore -lt (Get-Date) } |
    Sort-Object NotAfter -Descending | Select-Object -First 1
}
if (-not $cert) { Fail "no $CertIssuer code-signing certificate in the store -- connect SimplySign Desktop (tray icon -> Connect) and run again" }
$Thumb = $cert.Thumbprint

Write-Host "=== $Name $Version Windows distribution ($($Plugins.Count) plug-ins) ===" -ForegroundColor Cyan
Write-Host "    AAX: $(if ($WithAax) { 'yes' } else { 'no' })   build: $(if ($NoBuild) { 'no (using build-win\out)' } else { 'yes' })"
Write-Host "    certificate: $($cert.Subject)"
Write-Host "                 $Thumb, valid until $($cert.NotAfter.ToString('yyyy-MM-dd'))"
Write-Host "    signtool: $signtool"
if ($WithAax) { Write-Host "    wraptool: $wraptool" }
if (-not $NoBuild) { Write-Host "    cmake:    $cmake" }
New-Item -ItemType Directory -Force $Out | Out-Null

# ---- 1. build -------------------------------------------------------------------
if (-not $NoBuild) {
  if ($WithAax -and -not (Test-Path ..\..\Dependencies\IPlug\AAX_SDK\CMakeLists.txt)) {
    Fail 'AAX SDK missing in iPlug2\Dependencies\IPlug\AAX_SDK -- add it or use -NoAax'
  }
  $formats = 'VST3;CLAP'
  if ($WithAax) { $formats += ';AAX' }
  Step "build $formats (CMake, Visual Studio 2022, x64 Release)"
  if (Test-Path $Build) { Remove-Item -Recurse -Force $Build }
  $log = "$Out\build-win.log"
  $ErrorActionPreference = 'Continue'
  & $cmake -S . -B $Build -G 'Visual Studio 17 2022' -A x64 "-DMB_FORMATS=$formats" -DIPLUG_DEPLOY_PLUGINS=OFF *> $log
  $rc = $LASTEXITCODE
  if (-not $rc) {
    & $cmake --build $Build --config Release --parallel *>> $log
    $rc = $LASTEXITCODE
  }
  $ErrorActionPreference = 'Stop'
  if ($rc) {
    Select-String -Path $log -Pattern 'error|CMake Error' | Select-Object -First 30 | ForEach-Object { Write-Host $_.Line }
    Fail "build failed -- full log in $log"
  }
  Write-Host 'BUILD SUCCEEDED'
}

# ---- 2. check -------------------------------------------------------------------
Step 'check build output'
$signFiles = @()
foreach ($p in $Plugins.Keys) {
  $files = @("$BinDir\$p.vst3\Contents\x86_64-win\$p.vst3", "$BinDir\$p.clap")
  if ($WithAax) { $files += "$BinDir\$p.aaxplugin\Contents\x64\$p.aaxplugin" }
  foreach ($f in $files) {
    if (-not (Test-Path $f)) { Fail "build output missing: $f" }
  }
  $signFiles += $files[0], $files[1]
  if ($WithAax) {
    if ($dumpbin) {
      $ErrorActionPreference = 'Continue'
      $exports = & $dumpbin /exports $files[2] 2>&1 | Out-String
      $ErrorActionPreference = 'Stop'
      if ($exports -notmatch '\bACFRegisterPlugin\b') { Fail "aax/${p}: ACFRegisterPlugin not exported -- AAX_Exports not linked" }
    }
  }
  Write-Host ("    {0,-12} {1}" -f $p, (Get-Item $files[0]).LastWriteTime.ToString('yyyy-MM-dd HH:mm'))
}
if ($WithAax -and -not $dumpbin) { Write-Host '    (dumpbin not found: AAX export check skipped)' -ForegroundColor Yellow }

# ---- 3. sign --------------------------------------------------------------------
function Test-Signature([string]$file) {
  $ErrorActionPreference = 'Continue'
  $text = & $signtool verify /pa /v $file 2>&1 | Out-String
  if ($LASTEXITCODE) { Write-Host $text; Fail "${file}: signature does not verify" }
  if ($text -match 'not timestamped') { Write-Host $text; Fail "${file}: signed WITHOUT a timestamp" }
  Write-Host "${file}: signed + timestamped OK" -ForegroundColor Green
}

Step "sign VST3 + CLAP ($($signFiles.Count) files, signtool)"
& $signtool sign /sha1 $Thumb /fd sha256 /tr $TimestampUrl /td sha256 /d $Name @signFiles
if ($LASTEXITCODE) { Fail 'signtool failed -- is SimplySign Desktop still connected?' }
foreach ($f in $signFiles) { Test-Signature $f }

if ($WithAax) {
  foreach ($p in $Plugins.Keys) {
    Step "sign AAX $p (PACE wraptool, $($Plugins[$p]))"
    $bundle = "$BinDir\$p.aaxplugin"
    $bin = "$bundle\Contents\x64\$p.aaxplugin"
    & $wraptool sign --verbose --account $PaceAccount --password $pacePw --wcguid $Plugins[$p] `
      --signid $Thumb --extrasigningoptions $WraptoolSignOptions --in $bundle --out $bundle
    if ($LASTEXITCODE) { Fail "wraptool sign failed for $p" }
    # sign takes the bundle, but on Windows verify wants the binary inside it.
    & $wraptool verify --verbose --in $bin
    if ($LASTEXITCODE) { Fail "wraptool verify failed for $p" }
    Test-Signature $bin
  }
}
$pacePw = $null

# ---- 4. installer ---------------------------------------------------------------
Step 'installer (Inno Setup, signs setup + uninstaller)'
# Inno runs this for the setup and the uninstaller: $q = a quote, $f = the file.
$signCmd = "signtool=`$q$signtool`$q sign /sha1 $Thumb /fd sha256 /tr $TimestampUrl /td sha256 /d `$q$Name installer`$q `$f"
$isccArgs = @("/DAppVer=$Version", '/DSIGN', "/S$signCmd")
if ($WithAax) { $isccArgs += '/DWITH_AAX' }
& $iscc @isccArgs "installer\$Name.iss"
if ($LASTEXITCODE) { Fail 'Inno Setup failed' }

$Final = "$Out\$Name-$Version-win.exe"
Test-Signature $Final

Write-Host ''
Write-Host "=== done: $Final ===" -ForegroundColor Green
exit 0
