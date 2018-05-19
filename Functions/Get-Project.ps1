function Get-Project {
	<#
		.SYNOPSIS
			Retrieves one or more projects from the specified TeamCity server
		
		.DESCRIPTION
			By default the function requests all projects through the REST endpoint at http://server.url/httpAuth/app/rest/projects
			
			If the Name or ID parameters are specified only projects that match those parameters are returned.
			
		.PARAMETER Name
			The name of one or more projects to return. Since project names are not unique may return multiple items that have the same name.

		.PARAMETER ID
			The unique ID of the project to return.
		
		.PARAMETER Server
			URL of the TeamCity server.
			
		.PARAMETER Credential
			Login credentials for the TeamCity server.
	#>
	
	[CmdletBinding(DefaultParameterSetName="All")]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName="Name")]
		[string]$Name,

		[Parameter(Mandatory=$true,ParameterSetName="ID")]
		[string]$ID,

		[Parameter(ParameterSetName="All")]
		[switch]$All = $true,

		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	$headers = @{ Accept = 'application/json'}
	$uri = "$Server/httpAuth/app/rest/projects"
	if ( $Name ) { $uri += "/name:$Name" }
	if ( $ID ) { $uri += "/id:$ID" }
	
	$result = Invoke-RestMethod -Headers $headers -Uri $uri -Credential $Credential

	Write-Output $result.project
}