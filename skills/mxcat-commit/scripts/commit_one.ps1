# 创建一条 commit。消息来自本次管道或标准输入；路径只取 -- 之后的参数。
$ErrorActionPreference = 'Stop'

function Show-Usage {
    [Console]::Error.WriteLine('usage: commit_one.ps1 [--add] -- <path>...')
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

function Resolve-PhysicalDirectory {
    param([string]$Dir)
    if ($env:OS -eq 'Windows_NT') {
        return ([System.IO.Path]::GetFullPath($Dir)).TrimEnd('\')
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

$add = $false
$rest = @($args)
if ($rest.Count -ge 1 -and $rest[0] -eq '--add') {
    $add = $true
    if ($rest.Count -eq 1) {
        $rest = @()
    } else {
        $rest = @($rest[1..($rest.Count - 1)])
    }
}
if ($rest.Count -lt 2 -or $rest[0] -ne '--') {
    Show-Usage
}
$paths = @($rest[1..($rest.Count - 1)])
if ($paths.Count -eq 0 -or [string]::IsNullOrEmpty($paths[0])) {
    Show-Usage
}

$piped = New-Object System.Collections.Generic.List[string]
foreach ($item in $input) {
    $piped.Add([string]$item)
}
if ($piped.Count -eq 1) {
    $raw = $piped[0]
} elseif ($piped.Count -gt 1) {
    $raw = ($piped -join "`n") + "`n"
} elseif ([Console]::IsInputRedirected) {
    $utf8In = New-Object System.Text.UTF8Encoding $false
    [Console]::InputEncoding = $utf8In
    $raw = [Console]::In.ReadToEnd()
} else {
    $raw = ''
}

$tmp = New-TemporaryFile
try {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmp.FullName, $raw, $utf8)

    . (Join-Path $PSScriptRoot 'validate.ps1')
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

    if ($add) {
        & git add -- @paths
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    } else {
        $unstaged = & git diff -- @paths
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
        $unstagedText = @($unstaged) -join "`n"
        if ($unstagedText -cmatch '.') {
            [Console]::Error.WriteLine('commit_one: 无法只提交这些路径的 staged 部分')
            exit 1
        }
    }

    & git rev-parse --verify --quiet HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $staged = & git -c core.quotePath=false diff --cached --name-status HEAD -- @paths
    } else {
        $staged = & git -c core.quotePath=false diff --cached --name-status -- @paths
    }
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
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
    if ($expected -cne $actual) {
        Show-PathMismatch -Expected $expected -Actual $actual
    }

    & git commit --file $tmp.FullName --only -- @paths
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
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
    Remove-Item -LiteralPath $tmp.FullName -Force -ErrorAction SilentlyContinue
}
