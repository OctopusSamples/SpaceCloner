$currentDate = Get-Date
$currentDateFormatted = $currentDate.ToString("yyyy_MM_dd_HH_mm")

$logFolder = "$PSScriptRoot\..\..\logs\clonerun_$currentDateFormatted" 

if ((Test-Path -Path $logFolder) -eq $false)
{
    New-Item -Path $logFolder -ItemType Directory
}

$logPath = "$logFolder\Log.txt"
$cleanupLogPath = "$logFolder\CleanUp.txt"

function Write-VerboseOutput
{
    param($message)
    
    Add-Content -Value $message -Path $logPath    
}

function Write-GreenOutput
{
    param($message)

    Write-Host $message -ForegroundColor Green
    Write-VerboseOutput $message    
}

function Write-YellowOutput
{
    param($message)

    Write-Host $message -ForegroundColor Yellow    
    Write-VerboseOutput $message
}

function Write-RedOutput
{
    param ($message)

    Write-Host $message -ForegroundColor Red
    Write-VerboseOutput $message
}

function Write-CleanUpOutput
{
    param($message)

    Write-YellowOutput $message
    Add-Content -Value $message -Path $cleanupLogPath
}