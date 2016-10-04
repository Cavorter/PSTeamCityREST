foreach ( $function in (Get-ChildItem -Path .\Functions\*.ps1 -Exclude *.Test.*) ) {
	. $function.FullName
}