function New-VCSRoot {
	<#
		.SYNOPSIS
			Submits an object representation of a VCS Root to a TeamCity server.
		
		.DESCRIPTION
			After generating a new VCS Root using New-VCSRoot or modifying an existing root retrieved with Get-VCSRoot this function will submit that object to a TeamCity server.
		
		.PARAMETER InputObject
			An object representation of a VCS Root to be passed to a TeamCity server.
		
		.PARAMETER Server
			URL of the TeamCity server.
		
		.PARAMETER Credential
			Login credentials for the TeamCity server. Credentials are required unless the server administrator has enabled Guest account access.
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Server,
		
		[pscredential]$Credential,
		
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[PSCustomObject]$InputObject
	)
	$contentType = 'application/json'
	$headers = @{ Accept = $contentType}
	[uri]$uri = "$Server/httpAuth/app/rest/vcs-roots"
	
	$body = $InputObject | ConvertTo-Json -Depth 100 -Compress
	Write-Verbose "Body: $body"
	
	$invokeParams = @{ Headers = $headers; Uri = $uri.AbsoluteUri; Body = $body; ContentType = $contentType; Method = "Post" }
	if ( $Credential ) {
		$invokeParams.Credential = $Credential
	}
	
	$result = Invoke-RestMethod @invokeParams
	Write-Output $result
}