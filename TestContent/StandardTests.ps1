$serverVal = "http://not.a.real.server.url"
$credentialVal = New-Object pscredential("user", ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ))

$goodParams = @{ Server = $serverVal; Credential = $credentialVal }

Mock -Command Invoke-RestMethod -MockWith { return $true }

function Invoke-StandardParamTests {
    Param (
        [string]$FunctionName
    )

    $paramSet = @(
        @{ paramName = "Server" ; paramType = [string] ; paramFilter = { $Uri -like "$serverVal*" } }
        ,@{ paramName = "Credential"; paramType = [PSCredential] ; paramFilter = { $Credential -eq $credentialVal } }
    )

    Context "Standard Parameter Coverage" {
        $cmdObj = Get-Command -Name $FunctionName
        $testResult = Test-Function @goodParams

        It "Has a mandatory parameter named <paramName>" -TestCases $paramSet {
            Param($paramName)
            $cmdObj.Parameters."$paramName".ParameterSets.__AllParameterSets.IsMandatory | Should Be $true
        }

        It "The <paramName> parameter is of type <paramType>" -TestCases $paramSet {
            Param($paramName,$paramType)
            $cmdObj.Parameters."$paramName".ParameterType.Name | Should Be $paramType.Name
        }

		It "Processes <paramName> Parameter" -TestCases $paramSet {
            Param($paramName,$paramFilter)
            Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter $paramFilter -Scope Context -Times 1 -Exactly
		}
    }
}