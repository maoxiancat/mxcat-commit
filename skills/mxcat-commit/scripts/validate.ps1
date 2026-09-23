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

if ($MyInvocation.InvocationName -ne '.') {
    $piped = New-Object System.Collections.Generic.List[string]
    foreach ($item in $input) {
        $piped.Add([string]$item)
    }
    if ($piped.Count -eq 1) {
        $raw = $piped[0]
    } elseif ($piped.Count -gt 1) {
        $raw = ($piped -join "`n") + "`n"
    } elseif ([Console]::IsInputRedirected) {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [Console]::InputEncoding = $utf8
        $raw = [Console]::In.ReadToEnd()
    } else {
        $raw = ''
    }
    exit (Test-CommitMessage -Message $raw)
}
