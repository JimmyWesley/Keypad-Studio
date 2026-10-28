<#
  Keypad Studio - local bridge
  --------------------------------------------------------------
  Serves the Keypad Studio web UI and exposes a tiny local API
  that drives the official `ch57x-keyboard-tool.exe`:
     GET  /api/ping      -> bridge/exe availability
     GET  /api/status    -> detect a connected supported keyboard
     POST /api/validate  -> validate a YAML config (body = yaml)
     POST /api/upload    -> upload a YAML config to the device
     POST /api/led       -> run a `led` command (body = {args:[...]})
  Nothing leaves this machine. Requires the keyboard on USB and,
  on Windows, the USBDK driver (only for validate/upload/led).
#>

[CmdletBinding()]
param([int]$Port = 0)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IndexFile = Join-Path $ScriptDir "index.html"
# Remembers the last config successfully written to the device (device is write-only,
# so this file IS our record of what's currently on the keyboard).
$StateFile = Join-Path $ScriptDir ".last-config.yaml"

# locate the CLI (studio/ sits next to bin/)
$ExeCandidates = @(
  (Join-Path $ScriptDir "..\bin\ch57x-keyboard-tool.exe"),
  (Join-Path $ScriptDir "ch57x-keyboard-tool.exe"),
  (Join-Path $ScriptDir "..\ch57x-keyboard-tool.exe")
)
$Exe = $null
foreach ($c in $ExeCandidates) { if (Test-Path $c) { $Exe = (Resolve-Path $c).Path; break } }

$SUPPORTED = @(
  @{vid='1189'; pid='8840'; model='ch57x-1'},
  @{vid='1189'; pid='8842'; model='ch57x-1'},
  @{vid='1189'; pid='8850'; model='ch57x-1'},
  @{vid='514c'; pid='8851'; model='ch57x-1'},
  @{vid='1189'; pid='8890'; model='ch57x-2'},
  @{vid='514c'; pid='8850'; model='ch57x-3'}
)

function Write-Line($txt, $color="Gray") { Write-Host $txt -ForegroundColor $color }

function Test-UsbDk {
  if (Test-Path "$env:windir\System32\UsbDkHelper.dll") { return $true }
  if (Get-Service -Name "UsbDk*" -ErrorAction SilentlyContinue) { return $true }
  return $false
}

function Diag-Hint([string]$output) {
  if ([string]::IsNullOrWhiteSpace($output)) { return "" }
  $o = $output.ToLower()
  if (($o -match "find usb device" -or $o -match "entity not found" -or $o -match "no device" -or $o -match "not found") -and -not (Test-UsbDk)) {
    return "O driver USBDK nao esta instalado. Ele e necessario para GRAVAR no teclado no Windows. Instale o USBDK, reconecte o teclado por USB e tente de novo."
  }
  if ($o -match "access" -or $o -match "permission" -or $o -match "busy") {
    return "Acesso negado ao dispositivo. Feche outros programas que usam o teclado, reconecte o cabo USB e tente novamente."
  }
  return ""
}

function Invoke-Cli([string[]]$cliArgs) {
  if (-not $Exe) { return @{ ok=$false; code=-1; output="ch57x-keyboard-tool.exe nao encontrado (esperado em ..\bin\)." } }
  try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    $psi.Arguments = ($cliArgs | ForEach-Object {
      if ($_ -match '[\s"]') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
    }) -join ' '
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @{ ok = ($p.ExitCode -eq 0); code = $p.ExitCode; output = ("$out`n$err").Trim() }
  } catch {
    return @{ ok=$false; code=-1; output="Falha ao executar o CLI: $($_.Exception.Message)" }
  }
}

# These keyboards sometimes drop off the USB bus for a moment between operations,
# which surfaces as "find USB device". Retry such transient failures a few times.
function Invoke-CliRetry([string[]]$cliArgs, [int]$tries=4) {
  $r = $null
  for ($i=1; $i -le $tries; $i++) {
    $r = Invoke-Cli $cliArgs
    if ($r.ok) { return $r }
    if ($r.output -notmatch 'find USB device|device not found|No such device|Entity not found') { return $r }
    Start-Sleep -Milliseconds 500
  }
  return $r
}

function Get-Device {
  try { $all = Get-CimInstance Win32_PnPEntity -ErrorAction Stop } catch { return @{connected=$false; error="pnp"} }
  foreach ($d in $SUPPORTED) {
    $pat = "VID_$($d.vid)&PID_$($d.pid)"
    $m = $all | Where-Object { $_.DeviceID -match $pat } | Select-Object -First 1
    if ($m) { return @{ connected=$true; vid=$d.vid; pid=$d.pid; model=$d.model; name=$m.Name } }
  }
  return @{ connected=$false }
}

function Run-WithTempYaml([string]$verb, [string]$yaml) {
  $tmp = Join-Path $env:TEMP ("keypad_" + [guid]::NewGuid().ToString('N') + ".yaml")
  try {
    [System.IO.File]::WriteAllText($tmp, $yaml, (New-Object System.Text.UTF8Encoding($false)))
    return (Invoke-CliRetry @($verb, $tmp))
  } finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
  }
}

function To-Json($obj) { $obj | ConvertTo-Json -Depth 6 -Compress }

# ---- pick a port & start listener (localhost prefix is allowed for non-admin) ----
$listener = New-Object System.Net.HttpListener
$chosen = $null
$tryPorts = if ($Port -gt 0) { @($Port) } else { 8787..8799 }
foreach ($p in $tryPorts) {
  try {
    $listener.Prefixes.Clear()
    $listener.Prefixes.Add("http://localhost:$p/")
    $listener.Start()
    $chosen = $p; break
  } catch { $listener = New-Object System.Net.HttpListener }
}
if (-not $chosen) {
  Write-Line "Nao consegui abrir uma porta local (8787-8799)." "Red"
  Read-Host "Pressione Enter para sair"; exit 1
}

$url = "http://localhost:$chosen/"
Write-Host ""
Write-Line "  KEYPAD STUDIO" "Cyan"
Write-Line "  ---------------------------------------------" "DarkGray"
Write-Line "  UI:   $url" "White"
if ($Exe) { Write-Line "  CLI:  $Exe" "DarkGray" } else { Write-Line "  CLI:  NAO ENCONTRADO (validar/enviar ficarao off)" "Yellow" }
if (Test-UsbDk) { Write-Line "  USBDK: instalado (ok para gravar)" "DarkGray" } else { Write-Line "  USBDK: NAO instalado -> necessario para ENVIAR ao teclado" "Yellow" }
Write-Line "  ---------------------------------------------" "DarkGray"
Write-Line "  Deixe esta janela aberta. Feche-a para encerrar." "DarkGray"
Write-Host ""

try { Start-Process $url } catch {}

function Send-Json($ctx, $obj, [int]$status=200) {
  $json = To-Json $obj
  $buf = [System.Text.Encoding]::UTF8.GetBytes($json)
  $ctx.Response.StatusCode = $status
  $ctx.Response.ContentType = "application/json; charset=utf-8"
  $ctx.Response.Headers.Add("Cache-Control","no-store")
  $ctx.Response.ContentLength64 = $buf.Length
  $ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
  $ctx.Response.OutputStream.Close()
}
function Send-File($ctx, $path, $type) {
  $buf = [System.IO.File]::ReadAllBytes($path)
  $ctx.Response.StatusCode = 200
  $ctx.Response.ContentType = $type
  $ctx.Response.ContentLength64 = $buf.Length
  $ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
  $ctx.Response.OutputStream.Close()
}
function Read-Body($ctx) {
  $sr = New-Object System.IO.StreamReader($ctx.Request.InputStream, $ctx.Request.ContentEncoding)
  try { return $sr.ReadToEnd() } finally { $sr.Dispose() }
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.AbsolutePath
    $method = $ctx.Request.HttpMethod

    switch -regex ("$method $path") {
      '^GET /api/ping$' {
        Send-Json $ctx @{ ok=$true; version="1.1"; exe=[bool]$Exe; usbdk=(Test-UsbDk); last=(Test-Path $StateFile) }; break
      }
      '^GET /api/last$' {
        if (Test-Path $StateFile) { Send-Json $ctx @{ ok=$true; yaml=([System.IO.File]::ReadAllText($StateFile)) } }
        else { Send-Json $ctx @{ ok=$false } }
        break
      }
      '^GET /api/status$' {
        Send-Json $ctx (Get-Device); break
      }
      '^POST /api/validate$' {
        $r = Run-WithTempYaml "validate" (Read-Body $ctx)
        Send-Json $ctx @{ ok=$r.ok; output=$r.output }; break
      }
      '^POST /api/upload$' {
        $body = Read-Body $ctx
        $r = Run-WithTempYaml "upload" $body
        if ($r.ok) { try { [System.IO.File]::WriteAllText($StateFile, $body, (New-Object System.Text.UTF8Encoding($false))) } catch {} }
        Send-Json $ctx @{ ok=$r.ok; output=$r.output; usbdk=(Test-UsbDk); hint=(Diag-Hint $r.output) }; break
      }
      '^POST /api/led$' {
        $body = Read-Body $ctx
        $ledArgs = @()
        try { $ledArgs = @((ConvertFrom-Json $body).args) } catch {}
        if (-not $ledArgs) { $ledArgs = @() }
        $r = Invoke-CliRetry (@("led") + $ledArgs)
        Send-Json $ctx @{ ok=$r.ok; output=$r.output; usbdk=(Test-UsbDk); hint=(Diag-Hint $r.output) }; break
      }
      '^GET /(index\.html)?$' {
        if (Test-Path $IndexFile) { Send-File $ctx $IndexFile "text/html; charset=utf-8" }
        else { Send-Json $ctx @{ ok=$false; output="index.html nao encontrado" } 404 }
        break
      }
      default {
        Send-Json $ctx @{ ok=$false; output="not found" } 404
      }
    }
  } catch {
    try { if ($ctx) { Send-Json $ctx @{ ok=$false; output=$_.Exception.Message } 500 } } catch {}
  }
}
