# UserPromptSubmit hook: Telegram channel routing reminder.
# If the inbound prompt contains a Telegram channel tag, inject a system reminder
# telling the model to reply via the reply tool and not via terminal text.
# On no match, exits silently. On malformed input, exits silently — never blocks
# prompt submission.

$ErrorActionPreference = 'Stop'

$payload = [Console]::In.ReadToEnd()

try {
    $data = $payload | ConvertFrom-Json
} catch {
    exit 0
}

$prompt = $data.prompt

if ($prompt -and $prompt -match '<channel source="plugin:telegram:telegram"') {
    $reminder = "TELEGRAM INBOUND DETECTED. The user is reading Telegram, not this terminal. Reply ONLY by calling the mcp__plugin_telegram_telegram__reply tool with the chat_id from the inbound <channel> tag. Plain terminal text will never reach the user."

    $output = @{
        hookSpecificOutput = @{
            hookEventName     = 'UserPromptSubmit'
            additionalContext = $reminder
        }
    } | ConvertTo-Json -Compress -Depth 5

    Write-Output $output
}

exit 0
