workflow Start-DevVMs {
    param (
        [string]$SubscriptionId = '42dff4cd-ba03-4206-94c5-721389b64c1e',
        [string]$ResourceGroup = 'RG_Monitoring',
        [string]$TagName = 'Environment',
        [string]$TagValue = 'Dev'
    )

    Write-Output "Connecting to Azure..."
    Connect-AzAccount -Identity

    Write-Output "Setting subscription context..."
    Set-AzContext -SubscriptionId $SubscriptionId

    Write-Output "Getting VMs with tag $TagName=$TagValue..."
    $vms = Get-AzVM -ResourceGroupName $ResourceGroup | Where-Object {
        $_.Tags[$TagName] -eq $TagValue
    }

    foreach -parallel ($vm in $vms) {
        Write-Output "Starting VM: $($vm.Name)..."
        Start-AzVM -ResourceGroupName $ResourceGroup -Name $vm.Name
    }
}
