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

    & git commit --file $tmp.FullName --only -- @paths
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    $show = & git -c core.quotePath=false --no-pager show --name-status --pretty=format: HEAD
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    $expected = (Get-SortedPaths -Items $paths) -join "`n"
    $actual = (Get-CommitPaths -Lines @($show)) -join "`n"
    if ($expected -cne $actual) {
        [Console]::Error.WriteLine('commit_one: 文件集合与路径参数不一致')
        [Console]::Error.WriteLine('参数:')
        [Console]::Error.WriteLine($expected)
        [Console]::Error.WriteLine('实际:')
        [Console]::Error.WriteLine($actual)
        exit 1
    }
} finally {
    Remove-Item -LiteralPath $tmp.FullName -Force -ErrorAction SilentlyContinue
}
