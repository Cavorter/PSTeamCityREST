$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -Command Invoke-RestMethod -With { return $true }

	$serverVal = "http://not.a.real.server.url"
	$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))
	$commonParams = @{ Server = $serverVal }
		
	Context "Common Parameter Validation" {
		It "Processes Server Parameter" {
			Test-Function @commonParams
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "$serverVal*" } -Scope It
		}
		
		It "Throws if the Server parameter is missing or not specified" {
			{ Test-Function -Server } | Should Throw
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
		It "Processes the All parameter" {
			Test-Function @commonParams -All
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $uri -eq "$serverVal/httpAuth/app/rest/vcs-roots" }
		}
		
		It "Defaults to the All parameter if Project or VCSRoot are not specified" {
			Test-Function @commonParams
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $uri -eq "$serverVal/httpAuth/app/rest/vcs-roots" }
		}
		
		It "Proceses the Project parameter" {
			$testVal = "SomeProject"
			Test-Function @commonParams -Project $testVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $uri -eq "$serverVal/httpAuth/app/rest/vcs-roots?locator=project:(id:$testVal)" }
		}
		
		It "Processes the VCSRoot parameter" {
			$testVal = "SomeRoot"
			Test-Function @commonParams -VCSRoot $testVal
			Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $uri -eq "$serverVal/httpAuth/app/rest/vcs-roots/id:$testVal" }
		}
		
		It "Throws if the All and Project parameters are both specified" {
			{ Test-Function @commonParams -All -Project "SomeProject" } | Should Throw
		}
		
		It "Throws if the All and VCSRoot parameters are both specified" {
			{ Test-Function @commonParams -All -VCSRoot "SomeRoot" } | Should Throw
		}
		
		It "Throws if the Project and VCSRoot parameters are both specified" {
			{ Test-Function @commonParams -Project "SomeProject" -VCSRoot "SomeRoot" } | Should Throw
		}
		
		It "Throws if the All, Project, and VCSRoot parameters are both specified" {
			{ Test-Function @commonParams -All -Project "SomeProject" -VCSRoot "SomeRoot" } | Should Throw
		}
	}
}
