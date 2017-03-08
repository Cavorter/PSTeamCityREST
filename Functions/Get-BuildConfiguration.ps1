function Get-BuildConfiguration {
	<#
		.SYNOPSIS
			Retrieves one or more build configurations from a TeamCity server.
		.DESCRIPTION
			Implements the GET method of the app/rest/buildTypes/ REST endpoint.
		.PARAMETER Id
			The ID of the build configuration to retrieve
		.PARAMETER Name
			The Name of the build configuration to retrieve
		.PARAMETER Server
			URL of the TeamCity server.
		.PARAMETER Credential
			Login credentials for the TeamCity server. Credentials are required unless the server administrator has enabled Guest account access.
		.LINKS
			https://confluence.jetbrains.com/display/TCD10/REST+API#RESTAPI-BuildConfigurationAndTemplateSettings
	#>
	
	[CmdletBinding(DefaultParameterSetName='All')]
	Param (
		[Parameter(Mandatory=$false,ParameterSetName='All')]
		[switch]$All,
		
		[Parameter(Mandatory=$true,ParameterSetName='Id')]
		[string]$Id,
		
		[Parameter(Mandatory=$true,ParameterSetName='Name')]
		[string]$Name,
		
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential
	)
	
	$headers = @{ Accept = 'application/json'}
	$uri = "$Server/httpAuth/app/rest/buildTypes/"
	switch ( $PsCmdlet.ParameterSetName ) {
		"Id"	{ $uri += $Id }
		"Name"	{ $uri += $Name }
	}
	Write-Verbose "Uri: $uri"
	
	$invokeParams = @{ Headers = $headers; Uri = $uri }
	if ( $Credential ) { $invokeParams.Credential = $Credential }
	
	$result = Invoke-RestMethod @invokeParams
	if ( $PsCmdlet.ParameterSetName -eq "All" ) {
		Write-Output $result.buildType
	} else {
		Write-Output $result
	}
}