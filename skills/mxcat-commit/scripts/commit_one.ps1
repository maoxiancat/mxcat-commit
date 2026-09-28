# 创建一条 commit。消息来自本次管道或标准输入；路径只取 -- 之后的参数。
$ErrorActionPreference = 'Stop'

function Show-Usage {
    [Console]::Error.WriteLine('usage: commit_one.ps1 [--add] [--hunks <file>] -- <path>...')
    exit 2
}

function Get-SortedPaths {
    param([string[]]$Items)
    $set = New-Object 'System.Collections.Generic.SortedSet[string]' ([StringComparer]::Ordinal)
    foreach ($item in @($Items)) {
        if (-not [string]::IsNullOrEmpty($item)) {
            [void]$set.Add($item)
        }
    }
    return @($set)
}

function Get-CommitPaths {
    param([string[]]$Lines)
    $found = New-Object System.Collections.Generic.List[string]
    foreach ($line in @($Lines)) {
        if ([string]::IsNullOrEmpty($line)) {
            continue
        }
        $parts = $line -split "`t", 3
        if ($parts.Count -ge 3 -and $parts[0] -cmatch '^[RC]') {
            $found.Add($parts[1])
            $found.Add($parts[2])
        } elseif ($parts.Count -ge 2) {
            $found.Add($parts[1])
        }
    }
    return Get-SortedPaths -Items $found.ToArray()
}

function Collapse-RepoPath {
    param([string]$Rel)
    $acc = New-Object System.Collections.Generic.List[string]
    $escaped = $false
    foreach ($seg in ($Rel -split '/')) {
        if ($seg -eq '' -or $seg -eq '.') {
            continue
        }
        if ($seg -eq '..') {
            if ($acc.Count -eq 0) {
                $escaped = $true
                break
            }
            $acc.RemoveAt($acc.Count - 1)
            continue
        }
        [void]$acc.Add($seg)
    }
    return @{ Escaped = $escaped; Path = ($acc -join '/') }
}

function Get-WindowsFinalDirectory {
    param([string]$Dir)
    try {
        if (-not ('Mxcat.NativePath' -as [type])) {
        Add-Type -Namespace Mxcat -Name NativePath -UsingNamespace @(
            'System.Runtime.InteropServices',
            'System.Text',
            'Microsoft.Win32.SafeHandles'
        ) -MemberDefinition @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern Microsoft.Win32.SafeHandles.SafeFileHandle CreateFile(
    string name,
    uint access,
    uint share,
    IntPtr security,
    uint disposition,
    uint flags,
    IntPtr template);
[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern uint GetFinalPathNameByHandle(
    Microsoft.Win32.SafeHandles.SafeFileHandle handle,
    System.Text.StringBuilder buffer,
    uint length,
    uint flags);
'@
    }
    $handle = [Mxcat.NativePath]::CreateFile(
        $Dir,
        [uint32]2147483648,
        [uint32]7,
        [IntPtr]::Zero,
        [uint32]3,
        [uint32]33554432,
        [IntPtr]::Zero)
    if ($handle.IsInvalid) {
        return $null
    }
    try {
        $buffer = New-Object System.Text.StringBuilder 4096
        $got = [Mxcat.NativePath]::GetFinalPathNameByHandle($handle, $buffer, [uint32]$buffer.Capacity, [uint32]0)
        if ($got -eq 0) {
            return $null
        }
        if ($got -gt $buffer.Capacity) {
            $buffer = New-Object System.Text.StringBuilder ([int]$got)
            $got = [Mxcat.NativePath]::GetFinalPathNameByHandle($handle, $buffer, [uint32]$buffer.Capacity, [uint32]0)
            if ($got -eq 0) {
                return $null
            }
        }
        $full = $buffer.ToString()
        if ($full.StartsWith('\\?\UNC\')) {
            $full = '\' + $full.Substring(7)
        } elseif ($full.StartsWith('\\?\')) {
            $full = $full.Substring(4)
        }
        return $full.TrimEnd('\')
    } finally {
        $handle.Dispose()
    }
    } catch {
        return $null
    }
}

function Resolve-PhysicalDirectory {
    param([string]$Dir)
    if ($env:OS -eq 'Windows_NT') {
        $final = Get-WindowsFinalDirectory -Dir $Dir
        if ([string]::IsNullOrEmpty($final)) {
            return ([System.IO.Path]::GetFullPath($Dir)).TrimEnd('\')
        }
        return $final
    }
    $out = & /bin/sh -c 'CDPATH= cd -P -- "$1" && pwd' sh $Dir 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty([string]$out)) {
        return $null
    }
    return ([string]$out).Trim()
}

function ConvertTo-RepoPath {
    param(
        [string]$Path,
        [string]$Root,
        [string]$Prefix
    )
    if (Test-Path -LiteralPath $Path -PathType Container) {
        [Console]::Error.WriteLine("commit_one: 路径是目录: $Path")
        exit 1
    }
    $p = $Path -replace '\\', '/'
    while ($p.StartsWith('./')) {
        $p = $p.Substring(2)
    }
    $rooted = $p.StartsWith('/') -or $p -cmatch '^[A-Za-z]:/'
    if ($rooted) {
        $parent = [System.IO.Path]::GetDirectoryName($Path)
        $base = [System.IO.Path]::GetFileName($Path)
        $physParent = Resolve-PhysicalDirectory -Dir $parent
        $physRoot = Resolve-PhysicalDirectory -Dir $Root
        if ([string]::IsNullOrEmpty($physParent)) {
            $fullSlash = ([System.IO.Path]::GetFullPath($Path)) -replace '\\', '/'
        } else {
            $fullSlash = (($physParent -replace '\\', '/').TrimEnd('/')) + '/' + $base
        }
        if ([string]::IsNullOrEmpty($physRoot)) {
            $rootSlash = (([System.IO.Path]::GetFullPath($Root)) -replace '\\', '/').TrimEnd('/')
        } else {
            $rootSlash = ($physRoot -replace '\\', '/').TrimEnd('/')
        }
        $cmp = [StringComparison]::Ordinal
        if ($rootSlash -cmatch '^[A-Za-z]:') {
            $cmp = [StringComparison]::OrdinalIgnoreCase
        }
        if ($fullSlash.StartsWith($rootSlash + '/', $cmp)) {
            $p = $fullSlash.Substring($rootSlash.Length + 1)
        } elseif ($fullSlash.Equals($rootSlash, $cmp)) {
            [Console]::Error.WriteLine("commit_one: 路径是目录: $Path")
            exit 1
        } else {
            [Console]::Error.WriteLine("commit_one: 路径不在仓库内: $Path")
            exit 1
        }
    } else {
        $p = (($Prefix -replace '\\', '/') + $p)
    }
    $collapsed = Collapse-RepoPath -Rel $p
    if ($collapsed.Escaped) {
        [Console]::Error.WriteLine("commit_one: 路径不在仓库内: $Path")
        exit 1
    }
    if ([string]::IsNullOrEmpty($collapsed.Path)) {
        [Console]::Error.WriteLine("commit_one: 路径是目录: $Path")
        exit 1
    }
    return $collapsed.Path
}

function Show-PathMismatch {
    param([string]$Expected, [string]$Actual)
    [Console]::Error.WriteLine('commit_one: 文件集合与路径参数不一致')
    [Console]::Error.WriteLine('参数:')
    [Console]::Error.WriteLine($Expected)
    [Console]::Error.WriteLine('实际:')
    [Console]::Error.WriteLine($Actual)
    exit 1
}

function Write-CommitError {
    param([string]$Message)
    [Console]::Error.WriteLine("commit_one: $Message")
    exit 1
}

function Save-GitBlob {
    param([string]$Root, [string]$Blob, [string]$Dest)
    if ($env:OS -eq 'Windows_NT') {
        $rootQ = $Root.Replace('"', '""')
        $destQ = $Dest.Replace('"', '""')
        $line = "git -C `"$rootQ`" cat-file blob $Blob > `"$destQ`""
        & cmd.exe /d /s /c $line
    } else {
        & /bin/sh -c 'git -C "$1" cat-file blob "$2" > "$3"' sh $Root $Blob $Dest
    }
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function New-CommitSymlink {
    param([string]$Path, [string]$Target)
    $parent = [System.IO.Path]::GetDirectoryName($Path)
    $leaf = [System.IO.Path]::GetFileName($Path)
    if ([string]::IsNullOrEmpty($parent)) {
        $parent = [System.IO.Directory]::GetCurrentDirectory()
    }
    $escapedParent = [System.Management.Automation.WildcardPattern]::Escape($parent)
    New-Item -ItemType SymbolicLink -Path $escapedParent -Name $leaf -Target $Target -ErrorAction Stop | Out-Null
}

function Set-SwappedFileMode {
    param([string]$Root, [string]$Dest, [string]$RepoPath, [string]$Mode)
    if ($Mode -ceq '100755') {
        if ($env:OS -ne 'Windows_NT') {
            & chmod a+x $Dest
            if ($LASTEXITCODE -ne 0) {
                exit $LASTEXITCODE
            }
        }
        $executable = $false
        if ($env:OS -ne 'Windows_NT') {
            & /bin/test -x $Dest
            $executable = ($LASTEXITCODE -eq 0)
        }
        if (-not $executable) {
            & git -C $Root update-index --chmod=+x -- $RepoPath
            if ($LASTEXITCODE -ne 0) {
                exit $LASTEXITCODE
            }
        }
        return
    }
    if ($env:OS -ne 'Windows_NT') {
        & chmod a-x $Dest
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }
}

function Test-AcceptedMode {
    param([string]$Mode)
    return $Mode -eq '100644' -or $Mode -eq '100755' -or $Mode -eq '120000'
}

function Get-StagedRenameNew {
    param([string]$Path)
    $lines = & git -C $root -c core.quotePath=false diff --cached --name-status -M HEAD
    if ($LASTEXITCODE -ne 0) {
        return ''
    }
    foreach ($raw in @($lines)) {
        $fields = ([string]$raw).TrimEnd("`r") -split "`t", 3
        if ($fields.Count -lt 3) {
            continue
        }
        if ($fields[0].StartsWith('R') -and ($fields[1] -ceq $Path)) {
            return $fields[2]
        }
    }
    return ''
}

function Test-WorktreeHas {
    param([string]$Rel)
    $dest = Join-Path $root ($Rel -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    return Test-Path -LiteralPath $dest
}

function Split-ModeBlob {
    param([string]$Line)
    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }
    $parts = ($Line.Trim() -split '\s+', 4)
    if ($parts.Count -lt 2) {
        return $null
    }
    return @{ Mode = $parts[0]; Blob = $parts[1] }
}

function Split-TreeModeBlob {
    param([string]$Line)
    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }
    $parts = ($Line.Trim() -split '\s+', 4)
    if ($parts.Count -lt 3) {
        return $null
    }
    return @{ Mode = $parts[0]; Blob = $parts[2] }
}

function Test-FixedMessagePath {
    param([string]$Path)
    $banned = @('/tmp/commit_msg.txt', '/private/tmp/commit_msg.txt')
    $slash = ($Path -replace '\\', '/')
    if ($banned -contains $slash) {
        return $true
    }
    if (Test-Path -LiteralPath $Path) {
        $full = ([System.IO.Path]::GetFullPath($Path)) -replace '\\', '/'
        if ($banned -contains $full) {
            return $true
        }
    }
    return $false
}

function Split-PatchLines {
    param([AllowEmptyString()][string]$Text)
    $parts = @(([string]$Text).Split([string[]]@("`n"), [System.StringSplitOptions]::None))
    if ($parts.Count -gt 0 -and $parts[-1] -eq '' -and ([string]$Text).EndsWith("`n")) {
        if ($parts.Count -eq 1) {
            return @()
        }
        return @($parts[0..($parts.Count - 2)])
    }
    return @($parts)
}

function Get-PatchPaths {
    param([string]$PatchText)
    $paths = New-Object System.Collections.Generic.List[string]
    foreach ($raw in @(Split-PatchLines -Text $PatchText)) {
        $line = $raw.TrimEnd("`r")
        if (-not $line.StartsWith('diff --git a/')) {
            continue
        }
        $rest = $line.Substring(13)
        $idx = $rest.IndexOf(' b/')
        if ($idx -lt 0) {
            continue
        }
        $a = $rest.Substring(0, $idx)
        $b = $rest.Substring($idx + 3)
        if ($a -cne $b) {
            return @{ Rename = $a; Paths = @() }
        }
        $paths.Add($a)
    }
    return @{ Rename = $null; Paths = @($paths) }
}

function Get-HunkTexts {
    param([string]$DiffText, [string]$Path)
    $wantLine = "diff --git a/$Path b/$Path"
    $want = $false
    $buf = $null
    $hunks = New-Object System.Collections.Generic.List[string]
    foreach ($raw in @(Split-PatchLines -Text $DiffText)) {
        $line = $raw.TrimEnd("`r")
        if ($line.StartsWith('diff --git ')) {
            if ($null -ne $buf) {
                $hunks.Add($buf)
                $buf = $null
            }
            $want = ($line -ceq $wantLine)
            continue
        }
        if ($line.StartsWith('index ') -or $line.StartsWith('--- ') -or $line.StartsWith('+++ ')) {
            continue
        }
        if ($line.StartsWith('@@ ')) {
            if ($want) {
                if ($null -ne $buf) {
                    $hunks.Add($buf)
                }
                $buf = $line
            }
            continue
        }
        if ($want -and $null -ne $buf) {
            $buf = $buf + "`n" + $line
        }
    }
    if ($null -ne $buf) {
        $hunks.Add($buf)
    }
    return @($hunks)
}

function Test-HunkSubset {
    param([string]$PatchText, [string]$FullText, [string]$Path)
    $part = @(Get-HunkTexts -DiffText $PatchText -Path $Path)
    $full = @(Get-HunkTexts -DiffText $FullText -Path $Path)
    if ($part.Count -eq 0) {
        return $false
    }
    foreach ($hunk in $part) {
        $ok = $false
        foreach ($cand in $full) {
            if ($hunk -ceq $cand) {
                $ok = $true
                break
            }
        }
        if (-not $ok) {
            return $false
        }
    }
    return $true
}

function Assert-SplittablePath {
    param([string]$Path)
    & git cat-file -e "HEAD:$Path" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-CommitError "无法按 hunk 拆分该路径: $Path"
    }
    $num = & git -C $root -c core.quotePath=false diff --numstat HEAD -- $Path
    if ($LASTEXITCODE -ne 0) {
        Write-CommitError "无法按 hunk 拆分该路径: $Path"
    }
    $numText = (@($num) -join "`n")
    if ($numText.StartsWith('-')) {
        Write-CommitError "无法按 hunk 拆分该路径: $Path"
    }
    foreach ($argsDiff in @(
            @('-C', $root, '-c', 'core.quotePath=false', 'diff', '--name-status', '-M', 'HEAD', '--', $Path),
            @('-C', $root, '-c', 'core.quotePath=false', 'diff', '--cached', '--name-status', '-M', 'HEAD', '--', $Path)
        )) {
        $ns = & git @argsDiff
        if ($LASTEXITCODE -ne 0) {
            continue
        }
        foreach ($raw in @($ns)) {
            if ([string]::IsNullOrEmpty([string]$raw)) {
                continue
            }
            $code = ([string]$raw).Split("`t")[0]
            if ($code -cmatch '^[RC]') {
                Write-CommitError "无法按 hunk 拆分该路径: $Path"
            }
        }
    }
}

$add = $false
$hunks = $null
$argv = @($args)
$rest = New-Object System.Collections.Generic.List[string]
$i = 0
while ($i -lt $argv.Count) {
    $item = [string]$argv[$i]
    if ($item -eq '--add') {
        $add = $true
        $i++
        continue
    }
    if ($item -eq '--hunks') {
        if (($i + 1) -ge $argv.Count) {
            Show-Usage
        }
        $hunks = [string]$argv[$i + 1]
        $i += 2
        continue
    }
    if ($item -eq '--') {
        $i++
        while ($i -lt $argv.Count) {
            $rest.Add([string]$argv[$i])
            $i++
        }
        break
    }
    Show-Usage
}
$paths = @($rest)
if ($paths.Count -eq 0 -or [string]::IsNullOrEmpty($paths[0])) {
    Show-Usage
}

. (Join-Path $PSScriptRoot 'validate.ps1')
$pipeline = Get-Variable -Name input -ValueOnly -ErrorAction SilentlyContinue
$raw = Read-CommitMessage -Pipeline $pipeline

$tmp = New-TemporaryFile
$swaps = @()
$committed = $false
$indexPath = $null
$indexBackup = $null
$indexMissing = $false
try {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmp.FullName, $raw, $utf8)

    $valid = Test-CommitMessage -Message $raw
    if ($valid -ne 0) {
        exit $valid
    }

    $root = [string](& git rev-parse --show-toplevel)
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    $root = $root.Trim()
    $prefix = & git rev-parse --show-prefix
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    if ($null -eq $prefix) {
        $prefix = ''
    } else {
        $prefix = ([string]$prefix).Trim()
    }
    $expectedItems = New-Object System.Collections.Generic.List[string]
    foreach ($path in @($paths)) {
        [void]$expectedItems.Add((ConvertTo-RepoPath -Path $path -Root $root -Prefix $prefix))
    }
    $expected = (Get-SortedPaths -Items $expectedItems.ToArray()) -join "`n"
    $expectedSet = @($expectedItems)
    $indexPath = [string](& git rev-parse --path-format=absolute --git-path index)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($indexPath)) {
        $indexPath = [string](& git rev-parse --git-path index)
    }
    $indexPath = $indexPath.Trim()
    if (-not [System.IO.Path]::IsPathRooted($indexPath)) {
        $indexPath = Join-Path (Get-Location) $indexPath
    }
    $indexBackup = Join-Path ([System.IO.Path]::GetTempPath()) ('commit-one-index-' + [guid]::NewGuid().ToString('n'))
    if (Test-Path -LiteralPath $indexPath) {
        Copy-Item -LiteralPath $indexPath -Destination $indexBackup -Force
    } else {
        $indexMissing = $true
    }
    $partial = New-Object System.Collections.Generic.List[string]
    $pending = New-Object System.Collections.Generic.List[hashtable]

    if (-not [string]::IsNullOrEmpty($hunks)) {
        if (Test-FixedMessagePath -Path $hunks) {
            Write-CommitError '不得读取固定共享路径'
        }
        if (-not (Test-Path -LiteralPath $hunks -PathType Leaf)) {
            Write-CommitError '找不到补丁文件'
        }
        $hunksAbs = [System.IO.Path]::GetFullPath($hunks)
        $patchText = [System.IO.File]::ReadAllText($hunksAbs)
        $parsed = Get-PatchPaths -PatchText $patchText
        if (-not [string]::IsNullOrEmpty($parsed.Rename)) {
            Write-CommitError "无法按 hunk 拆分该路径: $($parsed.Rename)"
        }
        if (@($parsed.Paths).Count -eq 0) {
            Write-CommitError '补丁不是这些路径的完整 hunk 子集'
        }
        $seenPartial = @{}
        foreach ($pp in @($parsed.Paths)) {
            if ($seenPartial.ContainsKey($pp)) {
                continue
            }
            $seenPartial[$pp] = $true
            $known = $false
            foreach ($item in $expectedSet) {
                if ($item -ceq $pp) {
                    $known = $true
                    break
                }
            }
            if (-not $known) {
                Write-CommitError "补丁路径不在参数中: $pp"
            }
            Assert-SplittablePath -Path $pp
            $fullDiff = & git -C $root -c core.quotePath=false diff HEAD -- $pp
            if ($LASTEXITCODE -ne 0) {
                Write-CommitError '补丁不是这些路径的完整 hunk 子集'
            }
            $fullText = @($fullDiff) -join "`n"
            if (-not (Test-HunkSubset -PatchText $patchText -FullText $fullText -Path $pp)) {
                Write-CommitError '补丁不是这些路径的完整 hunk 子集'
            }
            $partial.Add($pp)
        }
        $idx = Join-Path ([System.IO.Path]::GetTempPath()) ('commit-one-' + [guid]::NewGuid().ToString('n'))
        $prevIndex = $env:GIT_INDEX_FILE
        $env:GIT_INDEX_FILE = $idx
        try {
            & git -C $root read-tree HEAD
            if ($LASTEXITCODE -ne 0) {
                Write-CommitError '补丁不是这些路径的完整 hunk 子集'
            }
            & git -C $root apply --cached --whitespace=nowarn -- $hunksAbs
            if ($LASTEXITCODE -ne 0) {
                Write-CommitError '补丁不是这些路径的完整 hunk 子集'
            }
            foreach ($pp in @($partial)) {
                $stageLine = [string](& git -C $root ls-files -s -- $pp)
                if ($LASTEXITCODE -ne 0) {
                    Write-CommitError '补丁不是这些路径的完整 hunk 子集'
                }
                $stage = Split-ModeBlob -Line $stageLine
                if ($null -eq $stage) {
                    Write-CommitError '补丁不是这些路径的完整 hunk 子集'
                }
                if (-not (Test-AcceptedMode -Mode $stage.Mode)) {
                    Write-CommitError "无法提交该路径的类型: $pp"
                }
                $head = Split-TreeModeBlob -Line ([string](& git -C $root ls-tree HEAD -- $pp))
                $headMode = ''
                $headBlob = ''
                if ($null -ne $head) {
                    $headMode = $head.Mode
                    $headBlob = $head.Blob
                }
                if ($stage.Mode -ceq $headMode -and $stage.Blob -ceq $headBlob) {
                    Write-CommitError '补丁不是这些路径的完整 hunk 子集'
                }
                $pending.Add(@{ Path = $pp; Mode = $stage.Mode; Blob = $stage.Blob })
            }
        } finally {
            if ($null -eq $prevIndex) {
                Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
            } else {
                $env:GIT_INDEX_FILE = $prevIndex
            }
            Remove-Item -LiteralPath $idx -Force -ErrorAction SilentlyContinue
        }
    }

    $whole = New-Object System.Collections.Generic.List[string]
    for ($n = 0; $n -lt $paths.Count; $n++) {
        $norm = $expectedSet[$n]
        $isPartial = $false
        foreach ($pp in @($partial)) {
            if ($pp -ceq $norm) {
                $isPartial = $true
                break
            }
        }
        if (-not $isPartial) {
            $whole.Add($paths[$n])
        }
    }

    if ($add) {
        $kept = New-Object System.Collections.Generic.List[string]
        $toAdd = New-Object System.Collections.Generic.List[string]
        $seen = New-Object System.Collections.Generic.List[string]
        foreach ($path in @($whole)) {
            $norm = ConvertTo-RepoPath -Path $path -Root $root -Prefix $prefix
            $seenAlready = $false
            foreach ($seenPath in @($seen)) {
                if ($seenPath -ceq $norm) {
                    $seenAlready = $true
                    break
                }
            }
            if ($seenAlready) {
                continue
            }
            $seen.Add($norm)
            $isPartial = $false
            foreach ($pp in @($partial)) {
                if ($pp -ceq $norm) {
                    $isPartial = $true
                    break
                }
            }
            if ($isPartial) {
                continue
            }
            $renameNew = Get-StagedRenameNew -Path $norm
            if (-not [string]::IsNullOrEmpty($renameNew)) {
                $hasNew = $false
                foreach ($item in $expectedSet) {
                    if ($item -ceq $renameNew) {
                        $hasNew = $true
                        break
                    }
                }
                if (-not $hasNew) {
                    Write-CommitError "改名必须同时给出新旧路径: $norm"
                }
                $kept.Add($path)
                continue
            }
            $stageLine = [string](& git -C $root ls-files -s -- $norm)
            $headLine = [string](& git -C $root ls-tree HEAD -- $norm)
            $hasIndex = -not [string]::IsNullOrWhiteSpace($stageLine)
            $hasHead = -not [string]::IsNullOrWhiteSpace($headLine)
            $hasWork = Test-WorktreeHas -Rel $norm
            if ((-not $hasIndex) -and $hasHead -and $hasWork) {
                $pending.Add(@{ Path = $norm; Mode = 'absent'; Blob = '-' })
                $kept.Add($path)
                continue
            }
            if ((-not $hasIndex) -and $hasHead) {
                $kept.Add($path)
                continue
            }
            if (-not $hasWork) {
                if ($hasHead -and $hasIndex) {
                    $stage = Split-ModeBlob -Line $stageLine
                    $head = Split-TreeModeBlob -Line $headLine
                    $indexMode = ''
                    $indexBlob = ''
                    $headMode = ''
                    $headBlob = ''
                    if ($null -ne $stage) {
                        $indexMode = $stage.Mode
                        $indexBlob = $stage.Blob
                    }
                    if ($null -ne $head) {
                        $headMode = $head.Mode
                        $headBlob = $head.Blob
                    }
                    $indexDiffers = -not [string]::IsNullOrEmpty($indexBlob) -and -not ($indexMode -ceq $headMode -and $indexBlob -ceq $headBlob)
                    if ($indexDiffers) {
                        if (-not (Test-AcceptedMode -Mode $indexMode)) {
                            Write-CommitError "无法提交该路径的类型: $norm"
                        }
                        $pending.Add(@{ Path = $norm; Mode = $indexMode; Blob = $indexBlob })
                        $partial.Add($norm)
                        continue
                    }
                }
                $kept.Add($path)
                $toAdd.Add($path)
                continue
            }
            & git diff --quiet -- $path
            $unstaged = ($LASTEXITCODE -ne 0)
            if ($unstaged) {
                $stage = Split-ModeBlob -Line ([string](& git -C $root ls-files -s -- $norm))
                $head = Split-TreeModeBlob -Line ([string](& git -C $root ls-tree HEAD -- $norm))
                $indexMode = ''
                $indexBlob = ''
                $headMode = ''
                $headBlob = ''
                if ($null -ne $stage) {
                    $indexMode = $stage.Mode
                    $indexBlob = $stage.Blob
                }
                if ($null -ne $head) {
                    $headMode = $head.Mode
                    $headBlob = $head.Blob
                }
                $indexDiffers = -not [string]::IsNullOrEmpty($indexBlob) -and -not ($indexMode -ceq $headMode -and $indexBlob -ceq $headBlob)
                if ($indexDiffers) {
                    & git diff --quiet HEAD -- $path
                    if ($LASTEXITCODE -ne 0) {
                        if (-not (Test-AcceptedMode -Mode $indexMode)) {
                            Write-CommitError "无法提交该路径的类型: $norm"
                        }
                        $pending.Add(@{ Path = $norm; Mode = $indexMode; Blob = $indexBlob })
                        $partial.Add($norm)
                        continue
                    }
                }
            }
            $kept.Add($path)
            $toAdd.Add($path)
        }
        if ($toAdd.Count -gt 0) {
            & git add -- @toAdd
            if ($LASTEXITCODE -ne 0) {
                exit $LASTEXITCODE
            }
        }
        $whole = $kept
    } else {
        $whole = New-Object System.Collections.Generic.List[string]
        for ($n = 0; $n -lt $paths.Count; $n++) {
            $path = $paths[$n]
            $norm = $expectedSet[$n]
            $already = $false
            foreach ($pp in @($partial)) {
                if ($pp -ceq $norm) {
                    $already = $true
                    break
                }
            }
            if ($already) {
                continue
            }
            $renameNew = Get-StagedRenameNew -Path $norm
            if (-not [string]::IsNullOrEmpty($renameNew)) {
                $hasNew = $false
                foreach ($item in $expectedSet) {
                    if ($item -ceq $renameNew) {
                        $hasNew = $true
                        break
                    }
                }
                if (-not $hasNew) {
                    Write-CommitError "改名必须同时给出新旧路径: $norm"
                }
            }
            $stageLine = [string](& git -C $root ls-files -s -- $norm)
            $headLine = [string](& git -C $root ls-tree HEAD -- $norm)
            $hasIndex = -not [string]::IsNullOrWhiteSpace($stageLine)
            $hasHead = -not [string]::IsNullOrWhiteSpace($headLine)
            if ((-not $hasIndex) -and $hasHead -and (Test-WorktreeHas -Rel $norm)) {
                $pending.Add(@{ Path = $norm; Mode = 'absent'; Blob = '-' })
                $whole.Add($path)
                continue
            }
            & git diff --quiet -- $path
            if ($LASTEXITCODE -eq 0) {
                $whole.Add($path)
                continue
            }
            $stage = Split-ModeBlob -Line ([string](& git -C $root ls-files -s -- $norm))
            $head = Split-TreeModeBlob -Line ([string](& git -C $root ls-tree HEAD -- $norm))
            $indexMode = ''
            $indexBlob = ''
            $headMode = ''
            $headBlob = ''
            if ($null -ne $stage) {
                $indexMode = $stage.Mode
                $indexBlob = $stage.Blob
            }
            if ($null -ne $head) {
                $headMode = $head.Mode
                $headBlob = $head.Blob
            }
            if ([string]::IsNullOrEmpty($indexBlob) -or ($indexMode -ceq $headMode -and $indexBlob -ceq $headBlob)) {
                Write-CommitError '没有可提交的已暂存改动'
            }
            if (-not (Test-AcceptedMode -Mode $indexMode)) {
                Write-CommitError "无法提交该路径的类型: $norm"
            }
            $pending.Add(@{ Path = $norm; Mode = $indexMode; Blob = $indexBlob })
            $partial.Add($norm)
        }
    }

    if ($whole.Count -gt 0) {
        & git rev-parse --verify --quiet HEAD 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $staged = & git -c core.quotePath=false diff --cached --name-status HEAD -- @whole
        } else {
            $staged = & git -c core.quotePath=false diff --cached --name-status -- @whole
        }
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        $wholeNorms = New-Object System.Collections.Generic.List[string]
        foreach ($path in @($whole)) {
            $wholeNorms.Add((ConvertTo-RepoPath -Path $path -Root $root -Prefix $prefix))
        }
        $expectedWhole = (Get-SortedPaths -Items $wholeNorms.ToArray()) -join "`n"
        $stagedPaths = Get-CommitPaths -Lines @($staged)
        $collapsedStaged = New-Object System.Collections.Generic.List[string]
        foreach ($stagedPath in @($stagedPaths)) {
            $shown = Collapse-RepoPath -Rel (($stagedPath -replace '\\', '/'))
            if ($shown.Escaped -or [string]::IsNullOrEmpty($shown.Path)) {
                [void]$collapsedStaged.Add($stagedPath)
            } else {
                [void]$collapsedStaged.Add($shown.Path)
            }
        }
        $actual = (Get-SortedPaths -Items $collapsedStaged.ToArray()) -join "`n"
        if ($expectedWhole -cne $actual) {
            Show-PathMismatch -Expected $expectedWhole -Actual $actual
        }
    }

    $made = New-Object System.Collections.Generic.List[hashtable]
    foreach ($item in @($pending)) {
        $dest = Join-Path $root ($item.Path -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        $backup = $null
        $linkTo = $null
        $kind = 'm'
        $existing = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        if ($null -ne $existing) {
            $isLink = ([int]$existing.Attributes -band [int][System.IO.FileAttributes]::ReparsePoint) -ne 0
            if ($isLink) {
                $kind = 'l'
                if ($existing.PSObject.Properties['LinkTarget'] -and $existing.LinkTarget) {
                    $linkTo = [string]$existing.LinkTarget
                } elseif ($existing.Target) {
                    $linkTo = [string]@($existing.Target)[0]
                }
            } else {
                $kind = 'f'
                $backup = New-TemporaryFile
                Copy-Item -LiteralPath $dest -Destination $backup.FullName -Force
            }
        }
        $made.Add(@{ Path = $item.Path; Kind = $kind; Backup = $(if ($backup) { $backup.FullName } else { $null }); LinkTo = $linkTo; Dest = $dest; Mode = $item.Mode })
        $swaps = @($made)
        if (Test-Path -LiteralPath $dest) {
            Remove-Item -LiteralPath $dest -Force
        }
        if ($item.Mode -ceq 'absent') {
            continue
        }
        $blobFile = Join-Path ([System.IO.Path]::GetTempPath()) ('commit-one-blob-' + [guid]::NewGuid().ToString('n'))
        Save-GitBlob -Root $root -Blob $item.Blob -Dest $blobFile
        if ($item.Mode -eq '120000') {
            $blobBytes = [System.IO.File]::ReadAllBytes($blobFile)
            $target = [System.Text.Encoding]::UTF8.GetString($blobBytes)
            try {
                New-CommitSymlink -Path $dest -Target $target
            } catch {
                Remove-Item -LiteralPath $blobFile -Force -ErrorAction SilentlyContinue
                Write-CommitError "无法提交该路径的类型: $($item.Path)"
            }
        } else {
            Copy-Item -LiteralPath $blobFile -Destination $dest -Force
            Set-SwappedFileMode -Root $root -Dest $dest -RepoPath $item.Path -Mode $item.Mode
        }
        Remove-Item -LiteralPath $blobFile -Force -ErrorAction SilentlyContinue
    }

    & git commit --file $tmp.FullName --only -- @paths
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    $committed = $true

    foreach ($item in @($pending)) {
        if ($item.Mode -ceq 'absent') {
            $gone = [string](& git -C $root ls-tree HEAD -- $item.Path)
            if (-not [string]::IsNullOrWhiteSpace($gone)) {
                Write-CommitError '文件 diff 与指定 hunk 不一致'
            }
            continue
        }
        $got = Split-TreeModeBlob -Line ([string](& git -C $root ls-tree HEAD -- $item.Path))
        if ($LASTEXITCODE -ne 0 -or $null -eq $got -or $got.Mode -cne $item.Mode -or $got.Blob -cne $item.Blob) {
            Write-CommitError '文件 diff 与指定 hunk 不一致'
        }
    }

    $show = & git -c core.quotePath=false --no-pager show --name-status --pretty=format: HEAD
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    $shownPaths = Get-CommitPaths -Lines @($show)
    $collapsedShown = New-Object System.Collections.Generic.List[string]
    foreach ($shownPath in @($shownPaths)) {
        $shown = Collapse-RepoPath -Rel (($shownPath -replace '\\', '/'))
        if ($shown.Escaped -or [string]::IsNullOrEmpty($shown.Path)) {
            [void]$collapsedShown.Add($shownPath)
        } else {
            [void]$collapsedShown.Add($shown.Path)
        }
    }
    $actual = (Get-SortedPaths -Items $collapsedShown.ToArray()) -join "`n"
    if ($expected -cne $actual) {
        Show-PathMismatch -Expected $expected -Actual $actual
    }
} finally {
    if (-not $committed -and -not [string]::IsNullOrEmpty($indexPath)) {
        if ($indexMissing) {
            if (Test-Path -LiteralPath $indexPath) {
                Remove-Item -LiteralPath $indexPath -Force -ErrorAction SilentlyContinue
            }
        } elseif (-not [string]::IsNullOrEmpty($indexBackup) -and (Test-Path -LiteralPath $indexBackup)) {
            Copy-Item -LiteralPath $indexBackup -Destination $indexPath -Force
        }
    }
    if (-not [string]::IsNullOrEmpty($indexBackup) -and (Test-Path -LiteralPath $indexBackup)) {
        Remove-Item -LiteralPath $indexBackup -Force -ErrorAction SilentlyContinue
    }
    foreach ($swap in @($swaps)) {
        if ([string]::IsNullOrEmpty($swap.Dest)) {
            continue
        }
        $left = Get-Item -LiteralPath $swap.Dest -Force -ErrorAction SilentlyContinue
        if ($null -ne $left) {
            Remove-Item -LiteralPath $swap.Dest -Force -ErrorAction SilentlyContinue
        }
        if ($swap.Kind -eq 'f' -and -not [string]::IsNullOrEmpty($swap.Backup)) {
            Copy-Item -LiteralPath $swap.Backup -Destination $swap.Dest -Force
            Remove-Item -LiteralPath $swap.Backup -Force -ErrorAction SilentlyContinue
        } elseif ($swap.Kind -eq 'l' -and -not [string]::IsNullOrEmpty($swap.LinkTo)) {
            New-CommitSymlink -Path $swap.Dest -Target $swap.LinkTo
        }
    }
    Remove-Item -LiteralPath $tmp.FullName -Force -ErrorAction SilentlyContinue
}
