$parent = Split-Path -Path $PSScriptRoot -Parent
if ( $Env:PSModulePath -notlike "*$parent*" ) {
	$Env:PSModulePath = ( ( $Env:PSModulePath.Split(';') + $parent ) -join ";" )
}

Import-Module .\*.psd1 -Force