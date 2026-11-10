# ============================================================
# Perfil PowerShell - Kali-Windows style
# ============================================================

# --- 1) PSReadLine: sugerencias + Tab inteligente ---
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    param($key, $arg)
    $b = $null; $c = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$b, [ref]$c)
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    $a = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$a, [ref]$c)
    if ($b -eq $a) { [Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete() }
}

# --- 2) ANSI VT ---
try {
    if (-not ([System.Management.Automation.PSTypeName]'VTMode').Type) {
        Add-Type -TypeDefinition 'using System;
using System.Runtime.InteropServices;
public class VTMode {
    [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
    [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
    [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
}' -ErrorAction SilentlyContinue
    }
    $h = [VTMode]::GetStdHandle(-11)
    $m = 0
    if ([VTMode]::GetConsoleMode($h, [ref]$m)) {
        [VTMode]::SetConsoleMode($h, $m -bor 0x0004) | Out-Null
    }
} catch {}

$ESC   = [char]27
$RESET = "${ESC}[0m"

# --- 2.5) Detectar admin (afecta paletas y prompt) ---
$isAdminSession = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# --- 3) Paletas (azules en normal, rojas en admin) ---
if ($isAdminSession) {
    $artStops = @(
        @(0x9E, 0x1E, 0x1E),
        @(0xFF, 0x3B, 0x3B),
        @(0xFF, 0xE0, 0xE0)
    )
    $iceStops = @(
        @(0xFF, 0x3B, 0x3B),
        @(0xFF, 0x6B, 0x6B),
        @(0xFF, 0xE0, 0xE0)
    )
    $ruleStops = @(
        @(0x5C, 0x1B, 0x1B),
        @(0x7A, 0x2F, 0x2F),
        @(0xA0, 0x4A, 0x4A)
    )
    $infoStops = @(
        @(0xCC, 0xCC, 0xCC),
        @(0xAA, 0x88, 0x88)
    )
} else {
    $artStops = @(
        @(0x1E, 0x5A, 0x9E),
        @(0x00, 0xB4, 0xFF),
        @(0xE0, 0xF7, 0xFF)
    )
    $iceStops = @(
        @(0x00, 0xB4, 0xFF),
        @(0x4E, 0xCD, 0xC4),
        @(0xE0, 0xF7, 0xFF)
    )
    $ruleStops = @(
        @(0x1B, 0x3A, 0x5C),
        @(0x2F, 0x4F, 0x7A),
        @(0x4A, 0x6F, 0xA0)
    )
    $infoStops = @(
        @(0xCC, 0xCC, 0xCC),
        @(0x88, 0x99, 0xAA)
    )
}

$tagStops = @(
    @(0xFF, 0xE0, 0x66),
    @(0xFF, 0xA5, 0x50)
)

# --- 4) Helpers ---
function Get-GradRgb {
    param([double]$t, $stops)
    $t = [Math]::Max(0.0, [Math]::Min(1.0, $t))
    $n = $stops.Count - 1
    $seg = [Math]::Min([int]($t * $n), $n - 1)
    $lt  = ($t * $n) - $seg
    $a = $stops[$seg]; $b = $stops[$seg + 1]
    $r  = [int]($a[0] + ($b[0] - $a[0]) * $lt)
    $g  = [int]($a[1] + ($b[1] - $a[1]) * $lt)
    $bl = [int]($a[2] + ($b[2] - $a[2]) * $lt)
    "$r;$g;$bl"
}

function Colorize-Line {
    param([string]$Text, $Stops, [int]$MaxWidth)
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($ch -eq ' ') { [void]$sb.Append(' '); continue }
        $t = if ($MaxWidth -le 1) { 0.0 } else { $i / ($MaxWidth - 1) }
        $rgb = Get-GradRgb -t $t -stops $Stops
        [void]$sb.Append("${ESC}[38;2;${rgb}m$ch$RESET")
    }
    $sb.ToString()
}

# --- 5) Dragon ---
$artLines = @(
    '⠀⠀⠀⠀⠠⠤⠤⠤⠤⠤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠛⠿⢶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⢀⣀⣀⣠⣤⣤⣴⠶⠶⠶⠶⠶⠶⠶⠶⠶⠿⠿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⡴⠶⠶⠿⠿⠿⣧⡀⠀⠀⠀⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠞⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣦⣤⣄⣈⡑⢦⣀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⣠⠔⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠉⠉⠉⠉⠙⠛⠿⣿⣮⣷⣤⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢻⣯⣧⡀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢷⡤⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⠿⣿⣶⣶⣦⣄⣀⠀⠀⠀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣯⡛⠻⢦⡀⠀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣆⠀⠙⢆⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣆⠀⠈⢣',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡆⠀⠈',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⠀',
    '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠀'
)

# --- 6) Logo ---
$logoLines = @(
    '█▄▀ ▄▀█ █   █ ▄▄ █ █ █ █ █▄ █ █▀▄ █▀█ █ █ █ █▀▀',
    '█ █ █▀█ █▄▄ █    ▀▄▀▄▀ █ █ ▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄▄█'
)

# --- 7) Banner composite: dragon izquierda + info derecha ---
$bullet = [char]0x2022
$pipe   = [char]0x2502

$dragonTrim = @($artLines | ForEach-Object { $_.TrimEnd([char]0x2800, [char]0x20) })
$dragonW = 0
foreach ($l in $dragonTrim) { if ($l.Length -gt $dragonW) { $dragonW = $l.Length } }
$totalH = $dragonTrim.Count

$ruleText = [string]::new($bullet, $logoLines[0].Length)

$admBanner = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$admText = if ($admBanner) { 'Si' } else { 'No' }
$wv = [Environment]::OSVersion.Version
$winText = "$($wv.Major).$($wv.Minor).$($wv.Build)"

$rightRows = @(
    [pscustomobject]@{ Text = $logoLines[0];                          Stops = $iceStops },
    [pscustomobject]@{ Text = $logoLines[1];                          Stops = $iceStops },
    [pscustomobject]@{ Text = $ruleText;                              Stops = $ruleStops },
    [pscustomobject]@{ Text = 'A   K a l i   L i n u x   b a s e d';  Stops = $tagStops },
    [pscustomobject]@{ Text = 'W i n d o w s   T e r m i n a l';     Stops = $tagStops },
    [pscustomobject]@{ Text = '';                                     Stops = $null },
    [pscustomobject]@{ Text = "Usuario    : $env:USERNAME";           Stops = $infoStops },
    [pscustomobject]@{ Text = "Equipo     : $env:COMPUTERNAME";       Stops = $infoStops },
    [pscustomobject]@{ Text = "PowerShell : $($PSVersionTable.PSVersion)"; Stops = $infoStops },
    [pscustomobject]@{ Text = "Windows    : $winText";                Stops = $infoStops },
    [pscustomobject]@{ Text = "Home       : $HOME";                   Stops = $infoStops },
    [pscustomobject]@{ Text = "Admin      : $admText";                Stops = $infoStops }
)

$rightW = 0
foreach ($r in $rightRows) { if ($r.Text.Length -gt $rightW) { $rightW = $r.Text.Length } }

$rightStart = [Math]::Max(0, [int](($totalH - $rightRows.Count) / 2))

Write-Host ""
for ($row = 0; $row -lt $totalH; $row++) {
    $lRaw = $dragonTrim[$row]
    $lColored = Colorize-Line -Text $lRaw -Stops $artStops -MaxWidth $dragonW
    $lPad = ' ' * ($dragonW - $lRaw.Length)
    $left = $lColored + $lPad

    $idx = $row - $rightStart
    $right = ''
    if ($idx -ge 0 -and $idx -lt $rightRows.Count) {
        $r = $rightRows[$idx]
        if ($r.Text.Length -gt 0 -and $null -ne $r.Stops) {
            $rColored = Colorize-Line -Text $r.Text -Stops $r.Stops -MaxWidth $rightW
            $rPad = ' ' * ($rightW - $r.Text.Length)
            $right = $rColored + $rPad
        }
    }

    $sep = "${ESC}[90m${pipe}${RESET}"
    Write-Host ("{0}  {1}  {2}" -f $left, $sep, $right)
}
Write-Host ""

# --- 8) Prompt tipo Kali (rojo si admin) ---
function prompt {
    $full = $PWD.ProviderPath
    $userHome = [Environment]::GetFolderPath("UserProfile")
    if ($full -like "$userHome*") { $short = "~" + $full.Substring($userHome.Length) } else { $short = $full }
    $u = [Environment]::UserName
    $h = $env:COMPUTERNAME
    $adm = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $idColor = if ($adm) { 'Red' } else { 'Blue' }
    Write-Host "+--(" -ForegroundColor Green -NoNewline
    Write-Host $u -ForegroundColor $idColor -NoNewline
    Write-Host "@" -ForegroundColor $idColor -NoNewline
    Write-Host $h -ForegroundColor $idColor -NoNewline
    Write-Host ")-[" -ForegroundColor Green -NoNewline
    Write-Host $short -ForegroundColor White -NoNewline
    Write-Host "]" -ForegroundColor Green
    Write-Host '$ ' -ForegroundColor Green -NoNewline
    " "
}