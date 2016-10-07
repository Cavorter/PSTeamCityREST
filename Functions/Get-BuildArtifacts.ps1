function Get-BuildArtifacts {
	<#
		.SYNOPSIS
			Gets a list of artifacts from a particular TeamCity build
		.DESCRIPTION
			Retrieves a list of the file artifacts for a build with a specific ID from a TeamCity server.
		.PARAMETER Server
			URL of the TeamCity server.
			
		.PARAMETER Credential
			Login credentials for the TeamCity server. Credentials are required unless the server administrator has enabled Guest account access.
			
		.PARAMETER Build
			The buildId of the executed build of a configuration
	#>
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential,
		
		[Parameter(Mandatory=$true)]
		[string]$Build
	)
	$headers = @{ Accept = 'application/json'}
	$uri = "$Server/httpAuth/app/rest/builds/id:$Build/artifacts/children/"
	if ( $Credential ) {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri -Credential $Credential
	} else {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri
	}
	Write-Output $result
}
