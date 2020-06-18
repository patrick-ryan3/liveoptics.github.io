param(
    [Parameter(Position=1, Mandatory=0)]
    [ValidateNotNullOrEmpty()]
    [string]$name,
    [Parameter(Position=2, Mandatory=0)]
    [ValidateSet('platforms','language-and-frameworks','techniques', 'tools')]
    [string]$quadrant,
    [Parameter(Position=3, Mandatory=0)]
    [ValidateSet('adopt','assess','trial', 'hold')]
    [string]$ring,
    [Parameter(Position=4, Mandatory=0)]
    [ValidateNotNullOrEmpty()]
    [string]$description,
    [Parameter(Position=5, Mandatory=0)]
    [string]$link
)

function Get-FullDescription
{
    param (
        [parameter(Mandatory = $true)][string] $desc,
        [parameter()][string] $lnk
    )

    if($lnk -ne $null -and $lnk -ne '')
    {
        return $desc + ' See <strong><a href=' + $lnk + '>here</a></strong> for details.'
    }
    else
    {
        return $desc
    }
}

$filepath = '.\LiveOptics Tech Radar.csv'
$existingEntries = Import-CSV $filepath

$fulldescription = Get-FullDescription $description $link
$entries = {$existingEntries}.Invoke()
$addNew = $true

foreach($entry in $entries)
{
    if($entry.name -eq $name)
    {
        Write-Host 'Entry' $name 'already exists. Updating.'
        $entry.ring = $ring
        $entry.quadrant = $quadrant
        $entry.isNew = 'FALSE'
        $entry.description = $fulldescription;

        $addNew = $false
        continue
    }
}

if($addNew -eq $true)
{
    Write-Host 'Adding new entry for' $name
    $newEntry = @{
            name = $name;
            ring = $ring;
            quadrant = $quadrant;
            isNew = 'TRUE';
            description = $fulldescription;
            };

    $ServiceObject = New-Object -TypeName PSObject -Property $newEntry
    $entries.Add($ServiceObject)
}

$entries | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File $filepath
