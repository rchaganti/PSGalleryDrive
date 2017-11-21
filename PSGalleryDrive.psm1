using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider()]
class PSGRoot : SHiPSDirectory
{
    # static member to keep track of CIM sessions
    static [System.Collections.Generic.List``1[Microsoft.Management.Infrastructure.CimSession]] $sessions
    
    # Default constructor
    PSGRoot([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()

        $obj += [DSCResources]::new('DSCResources')
        $obj += [Modules]::new('Modules')
        $obj += [Scripts]::new('Scripts')
        return $obj
    }
}

#region DSC Resources
[SHiPSProvider()]
class DSCResources : SHiPSDirectory
{
    DSCResources([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        
        # Find all DSC Resources - Use Find-DscResource cmdlet
        $dscResources = (Find-DscResource).Name | Sort-Object
        foreach ($resource in $dscResources) {
            $obj += [PSDSCResource]::new($resource)
        }
        return $obj
    }
}

[SHiPSProvider()]
class PSDSCResource : SHiPSDirectory
{
    PSDSCResource([string]$name):base($name)
    {
    }
     
    [object[]] GetChildItem()
    {
        try
        {
            return Find-DscResource -Name $this.name -ErrorAction Stop
        }

        catch
        {
            throw $_
        } 
    }    
}
#endregion

#region modules
[SHiPSProvider()]
class Modules : SHiPSDirectory
{    
    Modules([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        
        # Find all DSC Resources - Use Find-Module cmdlet
        $modules = (Find-Module).Name | Sort-Object
        foreach ($module in $modules) {
            $obj += [PSModule]::new($module)
        }
        return $obj
    }
}

[SHiPSProvider()]
class PSModule : SHiPSDirectory
{
    PSModule([string]$name):base($name)
    {
    }
     
    [object[]] GetChildItem()
    {
        try
        {
            return Find-Module -Name $this.name -ErrorAction Stop
        }

        catch
        {
            throw $_
        } 
    }    
}
#endregion

#region scripts
[SHiPSProvider()]
class Scripts : SHiPSDirectory
{    
    Scripts([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        
        # Find all scripts - Use Find-Script cmdlet
        $scripts = (Find-Script).Name | Sort-Object
        foreach ($script in $scripts) {
            $obj += [PSScript]::new($script)
        }
        return $obj
    }
}

[SHiPSProvider()]
class PSScript : SHiPSDirectory
{
    PSScript([string]$name):base($name)
    {
    }
     
    [object[]] GetChildItem()
    {
        try
        {
            return Find-Script -Name $this.name -ErrorAction Stop
        }

        catch
        {
            throw $_
        } 
    }    
}
#endregion