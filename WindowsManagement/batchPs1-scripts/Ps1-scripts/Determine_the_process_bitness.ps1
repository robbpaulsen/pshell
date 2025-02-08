# https://rkeithhill.wordpress.com/2014/04/28/how-to-determine-if-a-process-is-32-or-64-bit/
function ProcessBitness
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$ProcessName
	)

	$Signature = @{
		Namespace = "Kernel32"
		Name      = "Bitness"
		Language  = "CSharp"
		MemberDefinition = @"
[DllImport("kernel32.dll")]
public static extern bool IsWow64Process(System.IntPtr hProcess, [Out] out bool wow64Process);
"@
	}
	if (-not ("Kernel32.Bitness" -as [type]))
	{
		Add-Type @Signature
	}

	Get-Process -Name $ProcessName | ForEach-Object -Process {
		$is32Bit = [int]0
		if ([Kernel32.Bitness]::IsWow64Process($_.Handle, [ref]$is32Bit))
		{
			if ($is32Bit)
			{
				"$($_.Name) is 32-bit"
			}
			else
			{
				"$($_.Name) is 64-bit"
			}
		}
	}
}
ProcessBitness -ProcessName pwsh
