
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'halp' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'halp'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'halp' {
            [CompletionResult]::new('--check', 'check', [CompletionResultType]::ParameterName, 'Sets the argument to check')
            [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Sets the configuration file')
            [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Sets the configuration file')
            [CompletionResult]::new('--no-version', 'no-version', [CompletionResultType]::ParameterName, 'Disable checking the version information')
            [CompletionResult]::new('--no-help', 'no-help', [CompletionResultType]::ParameterName, 'Disable checking the help information')
            [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Enables verbose logging')
            [CompletionResult]::new('--verbose', 'verbose', [CompletionResultType]::ParameterName, 'Enables verbose logging')
            [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', 'V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('plz', 'plz', [CompletionResultType]::ParameterValue, 'Get additional help')
            break
        }
        'halp;plz' {
            [CompletionResult]::new('-m', 'm', [CompletionResultType]::ParameterName, 'Sets the manual page command to run')
            [CompletionResult]::new('--man-cmd', 'man-cmd', [CompletionResultType]::ParameterName, 'Sets the manual page command to run')
            [CompletionResult]::new('--cheat-sh-url', 'cheat-sh-url', [CompletionResultType]::ParameterName, 'Use a custom URL for cheat.sh')
            [CompletionResult]::new('--eg-url', 'eg-url', [CompletionResultType]::ParameterName, 'Use a custom provider URL for `eg` pages')
            [CompletionResult]::new('--cheat-url', 'cheat-url', [CompletionResultType]::ParameterName, 'Use a custom URL for cheat sheets')
            [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, 'Sets the pager to use')
            [CompletionResult]::new('--pager', 'pager', [CompletionResultType]::ParameterName, 'Sets the pager to use')
            [CompletionResult]::new('--no-pager', 'no-pager', [CompletionResultType]::ParameterName, 'Disables the pager')
            [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
