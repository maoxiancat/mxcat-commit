# 只读标准输入或管道上的提交消息。不创建 commit，不读固定路径。
$ErrorActionPreference = 'Stop'

function Test-CommitMessage {
    param([AllowEmptyString()][string]$Message)

    $headerOk = $false
    $lineNo = 0
    $seenBlank = $false
    $missingSep = $false
    $forbidden = $false

    $lines = @([regex]::Split($Message, "\r?\n"))
    if ($Message.Length -gt 0 -and $Message -match "[\r\n]$" -and $lines.Count -gt 0 -and $lines[-1] -eq '') {
        if ($lines.Count -eq 1) {
            $lines = @()
        } else {
            $lines = @($lines[0..($lines.Count - 2)])
        }
    }

    foreach ($line in @($lines)) {
        $lineNo++
        if ($lineNo -eq 1) {
            if ($line -cmatch '^:[a-z0-9_+-]+: \([a-z0-9]+(-[a-z0-9]+)*\)( !)? .+') {
                $headerOk = $true
            }
        } elseif ($line -eq '') {
            $seenBlank = $true
        } elseif (-not $seenBlank) {
            $missingSep = $true
        }
        $trimmed = $line.TrimStart(' ', "`t")
        if ($trimmed.ToLowerInvariant() -cmatch '^(ai-co-authored-by:|co-authored-by:|jira-refs:)') {
            $forbidden = $true
        }
    }

    $code = 0
    if (-not $headerOk) {
        [Console]::Error.WriteLine('validate: header 不合格')
        $code = 1
    }
    if ($forbidden) {
        [Console]::Error.WriteLine('validate: 含有禁止页脚')
        $code = 1
    }
    if ($missingSep) {
        [Console]::Error.WriteLine('validate: 标题与正文之间缺少空行')
        $code = 1
    }
    return $code
}

function Read-CommitMessage {
    param($Pipeline)

    $raw = ''
    if ([Console]::IsInputRedirected) {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        $stream = [Console]::OpenStandardInput()
        $reader = New-Object System.IO.StreamReader ($stream, $utf8, $false, 1024, $true)
        try {
            $raw = $reader.ReadToEnd()
        } finally {
            $reader.Dispose()
        }
    }
    if (-not [string]::IsNullOrEmpty($raw)) {
        return $raw
    }

    $piped = New-Object System.Collections.Generic.List[string]
    if ($null -ne $Pipeline) {
        foreach ($item in $Pipeline) {
            $piped.Add([string]$item)
        }
    }
    if ($piped.Count -eq 1) {
        return $piped[0]
    }
    if ($piped.Count -gt 1) {
        return (($piped -join "`n") + "`n")
    }
    return ''
}

if ($MyInvocation.InvocationName -ne '.') {
    $pipeline = Get-Variable -Name input -ValueOnly -ErrorAction SilentlyContinue
    exit (Test-CommitMessage -Message (Read-CommitMessage -Pipeline $pipeline))
}
