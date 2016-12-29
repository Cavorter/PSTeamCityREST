function Get-VCSRoot {
	<#
		.SYNOPSIS
			Retrieves one or more VCS Roots from a TeamCity server
		.DESCRIPTION
			Retrieves object representations of VCS Roots from a TeamCity server. With nothing other than the base parameters specified all VCS Roots will be returned.
			
			By specifying Project or VCSRoot parameters the results can be filtered to roots visible from the specified project or only a specific root.
		
		.PARAMETER Project
			Restricts the returned objects to roots that are visible from the specified Project ID.
		
		.PARAMETER VCSRoot
			The ID of a specific VCSRoot to retrieve.
		
		.PARAMETER All
			Returns all VCS Root objects.
		
		.PARAMETER Server
			URL of the TeamCity server.
			
		.PARAMETER Credential
			Login credentials for the TeamCity server. Credentials are required unless the server administrator has enabled Guest account access.
	#>
	[CmdletBinding(DefaultParameterSetName="All")]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential,
		
		[Parameter(ParameterSetName="All")]
		[switch]$All,
		
		[Parameter(ParameterSetName="Project")]
		[string]$Project,
		
		[Parameter(ParameterSetName="Root")]
		[string]$VCSRoot
	)
	$headers = @{ Accept = 'application/json'}
	$uri = "$Server/httpAuth/app/rest/vcs-roots"
	switch ( $PsCmdlet.ParameterSetName ) {
		"All"		{ Write-Verbose "Returning all roots" }
		"Project" {
			Write-Verbose "Returning roots associated with the project $Project"
			$uri += "?locator=project:(id:$Project)"
		}
		"Root" {
			Write-Verbose "Returning only the $Root root"
			$uri += "/id:$VCSRoot"
		}
	}
	[uri]$uri = $uri
	Write-Verbose "Uri: $($uri.AbsoluteUri)"
	if ( $Credential ) {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri.AbsoluteUri -Credential $Credential
	} else {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri.AbsoluteUri
	}
	Write-Output $result
}