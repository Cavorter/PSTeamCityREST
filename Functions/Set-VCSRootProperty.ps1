function Set-VCSRootProperty {
	<#
		.SYNOPSIS
			Sets the value of a property on a VCS Root
		.DESCRIPTION
			Sets the value of a specific property for a specified VCS Root on a TeamCity server. If the property does not already exists it will be created.
		.PARAMETER VCSRoot
			The ID of a VCS Root that you would like to update
		.PARAMETER Property
			The name of the property to be set
		.PARAMETER Value
			The value to set the property to
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential,
		
		[Parameter(Mandatory=$true)]
		[string]$VCSRoot,
		
		[Parameter(Mandatory=$true)]
		[string]$Property,
		
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[string]$Value
	)
	
	[uri]$uri = "$Server/httpAuth/app/rest/vcs-roots/id:$VCSRoot/properties/$Property"
	Write-Verbose "Uri: $($uri.AbsoluteUri)"
	
	$invokeParams = @{ Method = "Put"; Uri = $uri.AbsoluteUri; Body = $Value; ContentType = "text/plain" }
	if ( $Credential ) { $invokeParams.Credential = $Credential }
	
	$result = Invoke-RestMethod @invokeParams
	Write-Output $result
}