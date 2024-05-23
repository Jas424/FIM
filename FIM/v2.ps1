Import-Module "C:\Users\jas\Desktop\FIM\MailModule.ps1"

# $Creds=Get-Credential
# $creds | Export-Clixml -Path "C:\Scripts\SendEmail\outlook.xml"
$EmailCredentialsPath = "C:\Users\jas\Desktop\FIM\outlook.xml"
$EmailCredentials = Import-Clixml -Path $EmailCredentialsPath
$EmailServer = "smtp-mail.outlook.com"
$EmailPort = "587"

Add-Type -AssemblyName System.Windows.Forms
$LogFilePath = "C:\Users\jas\Desktop\FIM\log.txt"

function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)] [string] $Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFilePath -Append
}

function ContinuousVerify {
    Param(
        [Parameter()] $baselineFilePath,
        [Parameter()] $emailTo,
        [Parameter()] $delayInSeconds
    )
    try {
        Write-Host "Starting continuous verification. Press 'Ctrl+C' to stop." -ForegroundColor Green

        while ($true) {
            Write-Host "Running verification..."
            Verify-Baseline -baselineFilePath $baselineFilePath -emailTo $emailTo
            Write-Host "Waiting for $delayInSeconds seconds before next check..." -ForegroundColor Yellow
            Start-Sleep -Seconds $delayInSeconds
        }
    }
    catch {
        Write-Host "Stopping continuous verification." -ForegroundColor Red
    }
}

function Add-FileToBaseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$targetFilePath
    )
    Write-Log "Called function Add-FileToBaseline"
    Write-Log "Target File = $targetFilePath"
    Write-Log "Baseline File = $baselineFilePath"
    try {
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
           
        }
        if ((Test-Path -Path $targetFilePath) -eq $false) {
            Write-Error -Message "$targetFilePath does not exist" -ErrorAction Stop
        }
        
        Write-Log "Importing csv $baselineFilePath"
        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","

        Write-Log "Checking target path in csv"

        if ($targetFilePath -in $currentBaseline.path) {
            Write-Output "File Path detected already in baseline file"
            do {

                $overwrite = Read-Host -Prompt "Path exists already in the baseline file, would you like to overwrite it [Y/N]:"
                if ($overwrite -in @('y', 'yes')) {
                    Write-Output "Path will be overwritten"

                    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation

                    $hash = Get-Filehash -Path $targetFilePath
                   
                    "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append -Encoding UTF8
          
                    Write-Output "Entry sucessfully added into baseline"

                }
                elseif ($overwrite -in @('n', 'no')) {
                    Write-Output "File path will not be overwritten"
                }
                else {
                    Write-Output "Invalid entry, please enter y to overwrite or n to not overwrite"
                }
            }while ($overwrite -notin @('y', 'yes', 'n', 'no'))
        }
        else {
            $hash = Get-Filehash -Path $targetFilePath
            # Write-Output $hash
            "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append -Encoding UTF8
    
            Write-Output "Entry sucessfully added into baseline"

        }

        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","
        $currentBaseline | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation
   
    
    }
    catch {
        Write-Log "Error occurred: $($_.Exception.Message)"
        return $_.Exception.Message
    }

}

function Verify-Baseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)] $baselineFilePath,
        [Parameter()] $emailTo
    )

    try {
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }
        # Write-Host "Checking file type of $baselineFilePath"
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be a csv file"  -ErrorAction Stop
        }
        
        # Write-Host "Importing data from $baselineFilePath"
        $baselineFiles = Import-Csv -Path $baselineFilePath -Delimiter ","
        
        foreach ($file in $baselineFiles) {
            # Write-Host "Processing file: $($file.path)"
            if (Test-Path -Path $file.path) {
                # Write-Host "File $($file.path) found. Calculating hash."
                $currenthash = Get-FileHash -Path $file.path 
                if ($currenthash.Hash -eq $file.hash) {
                    Write-Output "$($file.path) is still the same!"
                }
                else {
                    Write-Host "$($file.path) is different something has changed!" -ForegroundColor Red
                    if ($emailTo) {
                        # Write-Host "Sending alert email for file change."
                        Send-MailKitMessage -To $emailTo -From $EmailCredentials.UserName -Subject "File Monitor, file has changed" -Body "$($file.path) is different something has changed!" -SMTPServer $EmailServer -Port $EmailPort -Credential $EmailCredentials
                    }
                }
            }
            else {
                Write-Host "$($file.path) is not found!" -ForegroundColor Red
                if ($emailTo) {
                    # Write-Host "Sending alert email for file change."
                    Send-MailKitMessage -To $emailTo -From $EmailCredentials.UserName -Subject "File Monitor, file has been deleted" -Body "$($file.path) does not exist!" -SMTPServer $EmailServer -Port $EmailPort -Credential $EmailCredentials
                }




            }
        }        
    }
    catch {
        return $_.Exception.Message
    }

}

function Create-Baseline {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory)]$baselineFilePath
    )

    try {

        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be a .csv file"  -ErrorAction Stop
        }

        if ((Test-Path -Path $baselineFilePath)) {
            Write-Error -Message "$baselineFilePath already exists with this name" -ErrorAction Stop
        }

       

        "path,hash" | Out-File -FilePath $baselineFilePath -Force 

    }
    catch {
        return $_.Exception.Message
    }

}



$destinationFolderBackup = "C:\Users\jas\Desktop\FIM\Backup"
$sourceFolder = "C:\Users\jas\Desktop\FIM\Files"

Write-Host "File Monitor System Vers 1.00" -ForegroundColor Green
do {
    Write-Host "Please select one of the following options or enter q or quit to quit" -ForegroundColor Green
    Write-Host "1. Set baseline file;Current set baseline $($baselineFilePath)" -ForegroundColor Green
    Write-Host "2. Add to baseline" -ForegroundColor Green
    Write-Host "3. Check files against baseline" -ForegroundColor Green
    Write-Host "4. Check files against baseline with email" -ForegroundColor Green
    Write-Host "5. Create a new baseline" -ForegroundColor Green
    Write-Host "6. Restore the backup files" -ForegroundColor Green
    Write-Host "7. Turn on continuous monitoring" -ForegroundColor Green
    $entry = Read-Host -Prompt "Please enter a selection" 

    switch ($entry) {
        "1" {
            Write-Log "Baseline setup initiated"
            $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
            $inputFilePick.Filter = "CSV (*.csv) | *.csv"
            $inputFilePick.ShowDialog()
            $baselineFilePath = $inputFilePick.FileName
            Write-Log "Baseline path selected $($baselineFilePath)"
            if (Test-Path -Path $baselineFilePath) {
                if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -eq ".csv") {
                   
                }
                else {
                    $baselineFilePath = ""
                    Write-Host "Invalid file needs to be .csv file" -ForegroundColor Red
                    Write-Log "Baseline  is not a csv file"
                }
            }
            else {
                $baselineFilePath = ""
                Write-Host "Invalid file path for the baseline" -ForegroundColor Red
                Write-Log "Baseline path is invalid"
            }
            $destinationFolder = "C:\Users\jas\Desktop\FIM\Backup"
            Write-Log "Generating backup of all files and csv"
            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            $destinationFolder = "$destinationFolder\$timestamp"

            Write-Log "Checking destination folder $destinationFolder"
            if (-not (Test-Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder
            }

            Write-Log "Copying files from source to destination"
            Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse
            Copy-Item -Path $baselineFilePath -Destination $destinationFolder
            Write-Log "Backup Completed"
           
        }
        "2" {
            $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
            $inputFilePick.ShowDialog()
            $targetFilePath = $inputFilePick.FileName
            
            # Logging the selected file path
            Write-Log "Selected file path for monitoring: $targetFilePath"
            
            if (-not [string]::IsNullOrWhiteSpace($targetFilePath)) {
                # Logging the action of adding file to baseline
                Write-Log "Adding file to baseline: $targetFilePath"
                Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath $targetFilePath
                Write-Log "File added to baseline: $targetFilePath"
            }
            else {
                # Logging the case where no file was selected
                Write-Log "No file was selected for monitoring."
            }
            

        }
        "3" {
            Write-Log "Verifying baseline path"
            Verify-Baseline -baselineFilePath $baselineFilePath
        }
        "4" {
            Write-Log "Verifying baseline path and trigerring email"
            $email = Read-Host -Prompt "Enter your email"
            Verify-Baseline -baselineFilePath $baselineFilePath -emailTo $email
        }
        "5" {
            Write-Log "Creating a new baseline"
            $inputFilePick = New-Object System.Windows.Forms.SaveFileDialog
            $inputFilePick.Filter = "CSV (*.csv) | *.csv"
            $inputFilePick.ShowDialog()
            $newBaselineFilePath = $inputFilePick.FileName
            Create-Baseline -baselineFilePath $newBaselineFilePath 
        }
        "6" {
            $directories = Get-ChildItem -Path $destinationFolderBackup -Directory

            for ($i = 0; $i -lt $directories.Count; $i++) {
                Write-Host "${i}: $($directories[$i].Name)"
            }

            $selectedIndex = Read-Host "Please select a directory by entering the corresponding number"

            if ($selectedIndex -lt 0 -or $selectedIndex -ge $directories.Count) {
                Write-Host "Invalid selection. Please run the script again and select a valid number."
            }
            else {
                $selectedDirectory = $directories[$selectedIndex].FullName

                Write-Host "Selected Directory: $selectedDirectory"
                $csvFile = Get-ChildItem -Path $selectedDirectory -Filter *.csv | Select-Object -First 1

                if ($csvFile) {
                    Write-Host "CSV File Found: $($csvFile.FullName)"
                    $csvDestinationPath = "C:\Users\jas\Desktop\FIM\"

                    Copy-Item -Path $csvFile.FullName -Destination $csvDestinationPath -Force
                    Write-Host "CSV file copied successfully to $csvDestinationPath"
                }
                else {
                    Write-Host "No CSV file found in the selected directory."
                }

                $filesSubdirectory = Join-Path -Path $selectedDirectory -ChildPath "Files"
                Write-Host "Checking for 'Files' subdirectory in $selectedDirectory"

                if (Test-Path -Path $filesSubdirectory) {
                    Write-Host "'Files' subdirectory found."
                    Get-ChildItem -Path $filesSubdirectory -File | Copy-Item -Destination $sourceFolder -Force
                    Write-Host "Files from 'Files' subdirectory copied to $sourceFolder"
                }
                else {
                    Write-Host "'Files' subdirectory does not exist in the selected directory."
                }

            }


        }
        "7" {
            
            Write-Log "Starting continuous verification"
            $email = Read-Host -Prompt "Enter your email for alerts (Leave blank if not needed)"
            $delay = Read-Host -Prompt "Enter delay time in seconds between checks"
            ContinuousVerify -baselineFilePath $baselineFilePath -emailTo $email -delayInSeconds $delay
            
        }
        "q" {
            break
        }
        "quit" {
            break
        }
        default {
            Write-Host "Invalid Entry" -ForegroundColor Red
        }
    }


}while ($entry -notin @('q', 'quit'))

