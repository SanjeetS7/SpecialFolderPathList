﻿<#
.SYNOPSIS
特殊フォルダーに関係するdata.jsに載っていないCLSIDの情報を返す
#>

[CmdletBinding()]
param([switch]$All)

Set-StrictMode -Version Latest

if (!$All) {
	$dataFile = (Resolve-Path "$($MyInvocation.MyCommand.Path)\..\..\src\modules\data.js").Path
	$dataText = @(Get-Content -LiteralPath $dataFile) -join "`n"
}

$clsidKey = Get-Item "Microsoft.PowerShell.Core\Registry::HKEY_CLASSES_ROOT\CLSID"

# CLSIDは数が多すぎるのでいったんエクスポートしてから処理する
$regFile = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
reg.exe export HKCR\CLSID $regFile > $null

Get-Content -LiteralPath $regFile |
	Where-Object { $_ -match "^\[HKEY_CLASSES_ROOT\\CLSID\\({.+?})\\(?:ShellFolder|shell(?:ex)?)\]$"} |
	ForEach-Object { $matches[1].ToUpper() } |
	Get-Unique |
	Where-Object { $All -or !$datatext.Contains($_) } |
	ForEach-Object {
		try {
			$clsid = $_
			$subKey = $clsidKey.OpenSubKey($clsid)
			
			Write-Output (
				New-Object psobject -Property @{
					"Key" = "shell:::$clsid"
					"Name" = $subKey.GetValue("")
				} | Select-Object Key, Name
			)
		} finally {
			$subKey.Close()
		}
	}

Remove-Item -LiteralPath $regFile
$clsidKey.Close()
