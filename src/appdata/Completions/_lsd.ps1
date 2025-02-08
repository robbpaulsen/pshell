
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'lsd' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'lsd'
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
        'lsd' {
            [CompletionResult]::new('--color', 'color', [CompletionResultType]::ParameterName, 'When to use terminal colours [default: auto]')
            [CompletionResult]::new('--icon', 'icon', [CompletionResultType]::ParameterName, 'When to print the icons [default: auto]')
            [CompletionResult]::new('--icon-theme', 'icon-theme', [CompletionResultType]::ParameterName, 'Whether to use fancy or unicode icons [default: fancy]')
            [CompletionResult]::new('--config-file', 'config-file', [CompletionResultType]::ParameterName, 'Provide a custom lsd configuration file')
            [CompletionResult]::new('--depth', 'depth', [CompletionResultType]::ParameterName, 'Stop recursing into directories after reaching specified depth')
            [CompletionResult]::new('--permission', 'permission', [CompletionResultType]::ParameterName, 'How to display permissions [default: rwx for linux, attributes for windows]')
            [CompletionResult]::new('--size', 'size', [CompletionResultType]::ParameterName, 'How to display size [default: default]')
            [CompletionResult]::new('--date', 'date', [CompletionResultType]::ParameterName, 'How to display date [default: date] [possible values: date, locale, relative, +date-time-format]')
            [CompletionResult]::new('--sort', 'sort', [CompletionResultType]::ParameterName, 'Sort by TYPE instead of name')
            [CompletionResult]::new('--group-dirs', 'group-dirs', [CompletionResultType]::ParameterName, 'Sort the directories then the files')
            [CompletionResult]::new('--blocks', 'blocks', [CompletionResultType]::ParameterName, 'Specify the blocks that will be displayed and in what order')
            [CompletionResult]::new('-I', 'I ', [CompletionResultType]::ParameterName, 'Do not display files/directories with names matching the glob pattern(s). More than one can be specified by repeating the argument')
            [CompletionResult]::new('--ignore-glob', 'ignore-glob', [CompletionResultType]::ParameterName, 'Do not display files/directories with names matching the glob pattern(s). More than one can be specified by repeating the argument')
            [CompletionResult]::new('--hyperlink', 'hyperlink', [CompletionResultType]::ParameterName, 'Attach hyperlink to filenames [default: never]')
            [CompletionResult]::new('--truncate-owner-after', 'truncate-owner-after', [CompletionResultType]::ParameterName, 'Truncate the user and group names if they exceed a certain number of characters')
            [CompletionResult]::new('--truncate-owner-marker', 'truncate-owner-marker', [CompletionResultType]::ParameterName, 'Truncation marker appended to a truncated user or group name')
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'Do not ignore entries starting with . ')
            [CompletionResult]::new('--all', 'all', [CompletionResultType]::ParameterName, 'Do not ignore entries starting with . ')
            [CompletionResult]::new('-A', 'A ', [CompletionResultType]::ParameterName, 'Do not list implied . and ..')
            [CompletionResult]::new('--almost-all', 'almost-all', [CompletionResultType]::ParameterName, 'Do not list implied . and ..')
            [CompletionResult]::new('-F', 'F ', [CompletionResultType]::ParameterName, 'Append indicator (one of */=>@|) at the end of the file names')
            [CompletionResult]::new('--classify', 'classify', [CompletionResultType]::ParameterName, 'Append indicator (one of */=>@|) at the end of the file names')
            [CompletionResult]::new('-l', 'l', [CompletionResultType]::ParameterName, 'Display extended file metadata as a table')
            [CompletionResult]::new('--long', 'long', [CompletionResultType]::ParameterName, 'Display extended file metadata as a table')
            [CompletionResult]::new('--ignore-config', 'ignore-config', [CompletionResultType]::ParameterName, 'Ignore the configuration file')
            [CompletionResult]::new('-1', '1', [CompletionResultType]::ParameterName, 'Display one entry per line')
            [CompletionResult]::new('--oneline', 'oneline', [CompletionResultType]::ParameterName, 'Display one entry per line')
            [CompletionResult]::new('-R', 'R ', [CompletionResultType]::ParameterName, 'Recurse into directories')
            [CompletionResult]::new('--recursive', 'recursive', [CompletionResultType]::ParameterName, 'Recurse into directories')
            [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'For ls compatibility purposes ONLY, currently set by default')
            [CompletionResult]::new('--human-readable', 'human-readable', [CompletionResultType]::ParameterName, 'For ls compatibility purposes ONLY, currently set by default')
            [CompletionResult]::new('--tree', 'tree', [CompletionResultType]::ParameterName, 'Recurse into directories and present the result as a tree')
            [CompletionResult]::new('-d', 'd', [CompletionResultType]::ParameterName, 'Display directories themselves, and not their contents (recursively when used with --tree)')
            [CompletionResult]::new('--directory-only', 'directory-only', [CompletionResultType]::ParameterName, 'Display directories themselves, and not their contents (recursively when used with --tree)')
            [CompletionResult]::new('--total-size', 'total-size', [CompletionResultType]::ParameterName, 'Display the total size of directories')
            [CompletionResult]::new('-t', 't', [CompletionResultType]::ParameterName, 'Sort by time modified')
            [CompletionResult]::new('--timesort', 'timesort', [CompletionResultType]::ParameterName, 'Sort by time modified')
            [CompletionResult]::new('-S', 'S ', [CompletionResultType]::ParameterName, 'Sort by size')
            [CompletionResult]::new('--sizesort', 'sizesort', [CompletionResultType]::ParameterName, 'Sort by size')
            [CompletionResult]::new('-X', 'X ', [CompletionResultType]::ParameterName, 'Sort by file extension')
            [CompletionResult]::new('--extensionsort', 'extensionsort', [CompletionResultType]::ParameterName, 'Sort by file extension')
            [CompletionResult]::new('-G', 'G ', [CompletionResultType]::ParameterName, 'Sort by git status')
            [CompletionResult]::new('--gitsort', 'gitsort', [CompletionResultType]::ParameterName, 'Sort by git status')
            [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Natural sort of (version) numbers within text')
            [CompletionResult]::new('--versionsort', 'versionsort', [CompletionResultType]::ParameterName, 'Natural sort of (version) numbers within text')
            [CompletionResult]::new('-U', 'U ', [CompletionResultType]::ParameterName, 'Do not sort. List entries in directory order')
            [CompletionResult]::new('--no-sort', 'no-sort', [CompletionResultType]::ParameterName, 'Do not sort. List entries in directory order')
            [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reverse the order of the sort')
            [CompletionResult]::new('--reverse', 'reverse', [CompletionResultType]::ParameterName, 'Reverse the order of the sort')
            [CompletionResult]::new('--group-directories-first', 'group-directories-first', [CompletionResultType]::ParameterName, 'Groups the directories at the top before the files. Same as --group-dirs=first')
            [CompletionResult]::new('--classic', 'classic', [CompletionResultType]::ParameterName, 'Enable classic mode (display output similar to ls)')
            [CompletionResult]::new('--no-symlink', 'no-symlink', [CompletionResultType]::ParameterName, 'Do not display symlink target')
            [CompletionResult]::new('-i', 'i', [CompletionResultType]::ParameterName, 'Display the index number of each file')
            [CompletionResult]::new('--inode', 'inode', [CompletionResultType]::ParameterName, 'Display the index number of each file')
            [CompletionResult]::new('-g', 'g', [CompletionResultType]::ParameterName, 'Show git status on file and directory" Only when used with --long option')
            [CompletionResult]::new('--git', 'git', [CompletionResultType]::ParameterName, 'Show git status on file and directory" Only when used with --long option')
            [CompletionResult]::new('-L', 'L ', [CompletionResultType]::ParameterName, 'When showing file information for a symbolic link, show information for the file the link references rather than for the link itself')
            [CompletionResult]::new('--dereference', 'dereference', [CompletionResultType]::ParameterName, 'When showing file information for a symbolic link, show information for the file the link references rather than for the link itself')
            [CompletionResult]::new('-Z', 'Z ', [CompletionResultType]::ParameterName, 'Print security context (label) of each file')
            [CompletionResult]::new('--context', 'context', [CompletionResultType]::ParameterName, 'Print security context (label) of each file')
            [CompletionResult]::new('--header', 'header', [CompletionResultType]::ParameterName, 'Display block headers')
            [CompletionResult]::new('--system-protected', 'system-protected', [CompletionResultType]::ParameterName, 'Includes files with the windows system protection flag set. This is the same as --all on other platforms')
            [CompletionResult]::new('-N', 'N ', [CompletionResultType]::ParameterName, 'Print entry names without quoting')
            [CompletionResult]::new('--literal', 'literal', [CompletionResultType]::ParameterName, 'Print entry names without quoting')
            [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Print help information')
            [CompletionResult]::new('-V', 'V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
