$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-BuildArtifacts" {
	Mock -Command Invoke-RestMethod -With { return $true }

	Context "Parameter Validation" {
		$serverVal = "http://not.a.real.server.url"
		$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))
		$buildVal = "1234"
		
		It "Processes Server Parameter" {
			Get-BuildArtifacts -Server $serverVal -Build $buildVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "$serverVal*" } -Scope It
		}
		
		It "Throws if the Server parameter is missing or not specified" {
			{ Get-BuildArtifacts  -Build $buildVal -Server } | Should Throw
		}
		
		It "Processes Credential Parameter" {
			Get-BuildArtifacts -Server $serverVal -Credential $credentialVal -Build $buildVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Credential -eq $credentialVal	} -Scope It
		}
		
		It "Ignores Credential parameter if not supplied" {
			Get-BuildArtifacts -Server $serverVal -Build $buildVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { !($Credential) }
		}
		
		It "Processes Build parameter" {
			Get-BuildArtifacts -Server $serverVal -Build $buildVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "*$buildVal*" }
		}
		
		It "Throws if the Build parameter is missing or not specified" {
			{ Get-BuildArtifacts -Server $serverVal -Build } | Should Throw
		}
	}
}