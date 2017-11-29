$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$serverVal = "http://not.a.real.server.url"
	$credentialVal = New-Object pscredential( "user" , ( ConvertTo-SecureString -String "Password" -AsPlainText -Force ) )
	$goodParams = @{ Server = $serverVal; Credential = $credentialVal }
	
	$uriRoot = "$serverVal/httpAuth/app/rest/buildTypes/"
	
	$goodId = "some_id"
	$goodName = "Some Build Configuration"
	
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }

	It "the Mandatory attribute for the Server parameter is $true" {
		( Get-Command -Name $functionName ).Parameters.Server.Attributes.Mandatory | Should Be $true
	}
	
	It "processes the Server Parameter" {
		Test-Function @goodParams
		Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Uri -like "$serverVal*" } -Scope It
	}
	
	It "the Mandatory attribute for the Credential parameter is $false" {
		( Get-Command -Name $functionName ).Parameters.Credential.Attributes.Mandatory | Should Be $false
	}
	
	It "processes the Credential Parameter" {
		Test-Function @goodParams
		Assert-MockCalled -Command Invoke-RestMethod -ParameterFilter { $Credential -eq $credentialVal	} -Scope It
	}
	
	It "does not have the Name and Id parameters in the same ParameterSetNames" {
		$funcObj = Get-Command -Name $functionName
		Compare-Object -DifferenceObject $funcObj.Parameters.Name.ParameterSets.Keys -ReferenceObject $funcObj.Parameters.Id.ParameterSets.Keys -IncludeEqual -ExcludeDifferent | Should BeNullOrEmpty
	}
	
	It "does not have the All and Id parameters in the same ParameterSetNames" {
		$funcObj = Get-Command -Name $functionName
		Compare-Object -DifferenceObject $funcObj.Parameters.All.ParameterSets.Keys -ReferenceObject $funcObj.Parameters.Id.ParameterSets.Keys -IncludeEqual -ExcludeDifferent | Should BeNullOrEmpty
	}
	
	It "does not have the Name and All parameters in the same ParameterSetNames" {
		$funcObj = Get-Command -Name $functionName
		Compare-Object -DifferenceObject $funcObj.Parameters.Name.ParameterSets.Keys -ReferenceObject $funcObj.Parameters.All.ParameterSets.Keys -IncludeEqual -ExcludeDifferent | Should BeNullOrEmpty
	}
	
	It "Has the All ParameterSetName as the default ParameterSet" {
		( Get-Command -Name $functionName ).ParameterSets.Where({ $_.Name -eq "All" }).IsDefault | Should Be $true
	}
	
	It "has the Mandatory attribute for the Name parameter in it's ParameterSet set to $true" {
		( Get-Command -Name $functionName ).Parameters.Name.Attributes.Mandatory | Should Be $true
	}
	
	It "processes the value of the Name parameter" {
		$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$uriRoot$goodName" } }
		Mock @mockParams -MockWith { return $true }
		Test-Function @goodParams -Name $goodName
		Assert-MockCalled @mockParams -Scope It -Times 1
	}
	
	It "has the Mandatory attribute for the Id parameter in it's ParameterSet set to $true" {
		( Get-Command -Name $functionName ).Parameters.Id.Attributes.Mandatory | Should Be $true
	}
	
	It "processes the value of the Id parameter" {
		$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$uriRoot$goodId" } }
		Mock @mockParams -MockWith { return $true }
		Test-Function @goodParams -Id $goodId
		Assert-MockCalled @mockParams -Scope It -Times 1
	}
	
	It "does not filter buildTypes if the All parameter is specified" {
		$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq $uriRoot } }
		Mock @mockParams -MockWith { return $true }
		Test-Function @goodParams
		Assert-MockCalled @mockParams -Scope It -Times 1
	}
}