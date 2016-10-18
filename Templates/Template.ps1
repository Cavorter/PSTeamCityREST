function Get-TCProjects {
	<#
		.SYOPSIS
			Retrieves a list of Projects from the specified TeamCity server
		
		.DESCRIPTION
			This function requests the complete list of projects from the TeamCity server through the REST endpoint at http://url/httpAuth/app/rest/projects
			
			The list of projects returned is limited to those that the supplied credentials has access to.
			
		.PARAMETER Server
			URL of the TeamCity server.
			
		.PARAMETER Credential
			Login credentials for the TeamCity server. Credentials are required unless the server administrator has enabled Guest account access.
	#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential
	)
	
	$headers = @{ Accept = 'application/json'}
	$uri = "$Server/httpAuth/app/rest/projects"
	if ( $Credential ) {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri -Credential $Credential
	} else {
		$result = Invoke-RestMethod -Headers $headers -Uri $uri
	}
	Write-Output $result.project
}
