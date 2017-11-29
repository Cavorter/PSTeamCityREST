$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-TCProjects" {
	Mock -Command Invoke-RestMethod -MockWith { return $true }

	Context "Parameter Validation" {
		$serverVal = "http://not.a.real.server.url"
		$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))
		
		It "Processes Server Parameter" {
			Get-TCProjects -Server $serverVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "$serverVal*" } -Scope It
		}
		
		It "Throws if the Server parameter is missing or not specified" {
			{ Get-TCProjects -Server } | Should Throw
		}
		
		It "Processes Credential Parameter" {
			Get-TCProjects -Server $serverVal -Credential $credentialVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Credential -eq $credentialVal	} -Scope It
		}
		
		It "Ignores Credential parameter if not supplied" {
			Get-TCProjects -Server $serverVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { !($Credential) }
		}
	}
}