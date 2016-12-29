$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -Command Invoke-RestMethod -With { return $true }

	$inVal = '{"id":"someRoot","name":"Some Root"}'
	
	$serverVal = "http://not.a.real.server.url"
	$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))
	
	$commonParams = @{ InputObject = ( $inVal | ConvertFrom-Json ); Server = $serverVal }
		
	Context "Common Parameter Validation" {
		It "Processes Server Parameter" {
			Test-Function @commonParams
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "$serverVal*" } -Scope It
		}
		
		It "Throws if the Server parameter is missing or not specified" {
			{ Test-Function -In ( $inVal | ConvertFrom-Json ) -Server } | Should Throw
		}
		
		It "Processes Credential Parameter" {
			Test-Function @commonParams -Credential $credentialVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Credential -eq $credentialVal	} -Scope It
		}
		
		It "Ignores Credential parameter if not supplied" {
			Test-Function @commonParams
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { !($Credential) }
		}
	}
	
	Context "Specific Parameter Validation" {
		It "Throws if the InputObject parameter is mising or not specified" {
			{ Test-Function -Server $serverVal -In } | Should Throw
		}
		
		It "Proceses the InputObject parameter" {
			Test-Function @commonParams
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Body -eq $inVal } -Scope It
		}
		
		It "Proceses the InputObject parameter via the pipeline" {
			$inVal | ConvertFrom-Json | Test-Function -Server $serverVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Body -eq $inVal } -Scope It
		}
    }
}
