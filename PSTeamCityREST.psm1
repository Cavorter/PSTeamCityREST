foreach ( $function in (Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -Exclude *.Test.*) ) {
	. $function.FullName
}