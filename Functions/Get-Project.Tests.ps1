$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	. $PSScriptRoot\..\TestContent\StandardTests.ps1
	
	Invoke-StandardParamTests -FunctionName $functionName

	Context "Other Parameter Coverage" {
		$assertParams = @{ CommandName = "Invoke-RestMethod"; Times = 1; Exactly = [switch]$true; Scope = "It" }

		It "Processes the Name parameter" {
			$testName = "SomeProjectName"
			$testResult = Test-Function -Name $testName @goodParams
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/name:$testName" }
		}

		It "Processes the ID parameter" {
			$testId = "SomeProjectId"
			$testResult = Test-Function -ID $testId @goodParams
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/id:$testId" }
		}
	}
}