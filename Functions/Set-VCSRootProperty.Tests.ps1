$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -Command Invoke-RestMethod -With { return $true }

	$serverVal = "http://not.a.real.server.url"
	$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))
	
	$rootVal = "SomeVCSRootID"
	$propVal = "SomeProperty"
	$valVal = "SomeValue"
	
	$commonParams = @{ Server = $serverVal; VCSRoot = $rootVal; Property = $propVal; Value = $valVal }
	$assertParams = @{ Command = "Invoke-RestMethod"; Scope = "It" }
		
	Context "Common Parameter Validation" {
		It "Processes Server Parameter" {
			Test-Function @commonParams
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "$serverVal*" }
		}
		
		It "Throws if the Server parameter is missing or not specified" {
			{ Test-Function -Server } | Should Throw
		}
		
		It "Processes Credential Parameter" {
			Test-Function @commonParams -Credential $credentialVal
			Assert-MockCalled @assertParams -ParameterFilter { $Credential -eq $credentialVal	}
		}
		
		It "Ignores Credential parameter if not supplied" {
			Test-Function @commonParams
			Assert-MockCalled @assertParams -ParameterFilter { !($Credential) }
		}
	}
	
	Context "Specific Parameter Validation" {
		It "Throws if the VCSRoot parameter is missing or not specified" {
			{ Test-Function -Server $serverVal -Property $propVal -Value $valVal -VCSRoot } | Should Throw
		}
		
		It "Processes the VCSRoot parameter" {
			Test-Function @commonParams
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/app/rest/vcs-roots/id:$rootVal*" }
		}
		
		It "Throws if the Property parameter is missing or not specified" {
			{ Test-Function -Server $serverVal -VCSRoot $rootVal -Value $valVal -Property } | Should Throw
		}
		
		It "Processes the Property parameter" {
			Test-Function @commonParams
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/properties/$propVal" }
		}
		
		It "Throws if the Value parameter is missing or not specified" {
			{ Test-Function -Server $serverVal -VCSRoot $rootVal -Property $propVal -Value } | Should Throw
		}
		
		It "Processes the VCSRoot parameter" {
			Test-Function @commonParams
			Assert-MockCalled @assertParams -ParameterFilter { $Body -like $valVal }
		}
    }
}