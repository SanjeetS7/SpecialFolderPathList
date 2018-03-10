<#
.SYNOPSIS
data.js�ɍڂ��Ă������t�H���_�[�Ƃ��Ďg���Ȃ�CLSID���܂����W�X�g���ɑ��݂��Ă��邩���ׂ�
#>

[CmdletBinding()]
param()

$dataFile = (Resolve-Path "$($MyInvocation.MyCommand.Path)\..\..\src\modules\data.js").Path
$dataText = @(Get-Content -LiteralPath $dataFile) -join "`n"
$unusableText = ($dataText -csplit 'category: "Unusable"', 2, "SimpleMatch")[1]

([regex]"\{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\}").Matches($unusableText) |
	ForEach-Object {
		$clsid = $_.Value
		$path = "Microsoft.PowerShell.Core\Registry::HKEY_CLASSES_ROOT\CLSID\$clsid"
		$exists = Test-path $path
		
		New-Object psobject |
			Select-Object @(
				@{ Name = "Clsid"; Expression = { $clsid } }
				@{ Name = "Exists"; Expression = { $exists } }
				@{ Name = "Name"; Expression = { if ($exists) { (Get-Item $path).GetValue("") } } }
			)
	}