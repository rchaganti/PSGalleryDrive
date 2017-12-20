using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider()]
class HVRoot : SHiPSDirectory
{
    # static member to keep track of connected Hyper-V hosts
    static [System.Collections.Generic.List``1[Microsoft.HyperV.PowerShell.VMHost]] $connectedHosts
    
    # Default constructor
    HVRoot([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()

        if([HVRoot]::connectedHosts){
            [HVRoot]::connectedHosts | ForEach-Object {
                $obj += [HVMachine]::new($_.ComputerName, $_)
            }
        }
        # Else default to localhost
        else{
            $obj += [HVMachine]::new($env:COMPUTERNAME)
        }
        return $obj
    }
}

[SHiPSProvider()]
class HVMachine : SHiPSDirectory
{
    [Microsoft.HyperV.PowerShell.VMHost]$connectedHost = $null

    HVMachine([string]$name):base($name)
    {
        $this.connectedHost = Get-VMhost -ComputerName $name
        [HVRoot]::connectedHosts += $this.connectedHost
    }

    HVMachine([string]$name, [Microsoft.HyperV.PowerShell.VMHost]$connectedHost):base($name)
    {
        $this.connectedHost = $connectedHost
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        
        $vms = (Get-VM -ComputerName $this.connectedHost.ComputerName).VMName | Sort-Object
        foreach ($vm in $vms)
        {
            $obj += [HVVirtualMachine]::new($vm, $this.connectedHost)
        }
        
        return $obj
    }
}

[SHiPSProvider()]
class HVVirtualMachine : SHiPSDirectory
{
    [string] $vmname

    [string] $hostname

    HVVirtualMachine([string]$name, [Microsoft.HyperV.PowerShell.VMHost]$connectedHost):base($name)
    {
        $this.vmname = $name
        $this.hostname = $connectedHost.ComputerName
    }

    [object[]] GetChildItem()
    {
        return (Get-VM -ComputerName $this.hostname -Name $this.vmname)
    }    
}

function Connect-HVHost
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName
    )
    
    ([HVRoot]::connectedHosts).Add((Get-VMHost -ComputerName $ComputerName))
}

Export-ModuleMember -Function *