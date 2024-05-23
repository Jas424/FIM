# File Integrity Monitor

## Overview

The File Integrity Monitor is a host-based system designed to ensure the integrity of files on a user's personal computer. This tool, built using PowerShell, allows users to monitor changes in file hash values, ensuring any unauthorized modifications are detected promptly.

## Features

- **Set Baseline:** Allows users to select a CSV file to set as the baseline for monitoring.
- **Add Files to Baseline:** Users can add files to the baseline, registering their file paths and hash values for future checks.
- **Check Files Against Baseline:** Compares current file hashes with the baseline to detect modifications or deletions.
- **Check Files with Email Notifications:** Similar to the previous feature but includes email notifications for any detected changes.
- **Create New Baseline:** Enables users to create a new, empty baseline file in the correct CSV format.
- **Restore Backup Files:** Allows users to restore files from a backup directory to preserve system integrity in case of malware attacks.
- **Continuous Monitoring:** Provides near real-time alerts by continuously verifying files against the baseline at user-specified intervals.
- **Email Monitoring:** Sends immediate alerts to a specified email address if any changes are detected.

## Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/jas424/FIM.git
    cd v2.ps1
    ```

2. **Prerequisites:**
    - Ensure you have PowerShell installed on your system.
    - Install the required Mime Kit libraries for email operations.

## Usage and Demo

1. **Set Baseline:**
    ```powershell
    .\v2.ps1 -Option 1
    ```

2. **Add Files to Baseline:**
    ```powershell
    .\v2.ps1 -Option 2
    ```

3. **Check Files Against Baseline:**
    ```powershell
    .\v2.ps1 -Option 3
    ```

4. **Check Files with Email Notifications:**
    ```powershell
    .\v2.ps1 -Option 4 -Email your-email@example.com
    ```

5. **Create New Baseline:**
    ```powershell
    .\v2.ps1 -Option 5
    ```

6. **Restore Backup Files:**
    ```powershell
    .\v2.ps1 -Option 6
    ```

7. **Continuous Monitoring:**
    ```powershell
    .\v2.ps1 -Option 7 -Interval 300
    ```

## How It Works

1. **Set Baseline:**
    - The user selects a CSV file, which is set as the baseline for the system. This file contains the initial hash values of the monitored files. 

https://github.com/Jas424/FIM/assets/88213779/0b74b5bc-afb2-4dca-91e1-9a0e0b0bff58


2. **Add Files to Baseline:**
    - The function calculates the hash value of the selected file and adds it to the baseline CSV file.
   
https://github.com/Jas424/FIM/assets/88213779/aa3bb634-6063-4bfc-bbc7-dc55217b13a4

3. **Check Files Against Baseline:**
    - The script compares the current hash values of the files against the baseline. Any modifications or deletions trigger an alert.
   
https://github.com/Jas424/FIM/assets/88213779/9de17c87-91fe-46fd-b846-a72d28985f18

4. **Check Files with Email Notifications:**
    - Similar to the regular check, but also sends an email alert if any changes are detected.

5. **Create New Baseline:**
    - This option creates a new, empty baseline CSV file, ensuring proper format and structure.

6. **Restore Backup Files:**
    - The script restores files from a backup directory, preserving the integrity of the system in case of an attack.

7. **Continuous Monitoring:**
    - The script continuously monitors the files at specified intervals, providing close to real-time alerts for any detected changes.
<img width="585" alt="Screenshot 2024-05-23 at 1 22 51 PM" src="https://github.com/Jas424/FIM/assets/88213779/30541c43-cb3e-4c9b-9a2c-7e71e5f48f3b">



## Backup and Restore

- The tool includes a "Back Up and Restore" feature that stores a copy of the baseline file and monitored directory in a separate backup directory.
- The script generates timestamped subfolders within the backup directory to ensure distinct backups.
- Users can restore files from the backup directory if malware compromises the system.

## Email Notifications

- The tool integrates an email feature to send immediate alerts to a specified email address.
- This is achieved using the Mime Kit libraries for secure email operations.


## DEMO 

-  In this scenario, the user downloads a malware disguised as a shortcut. Upon clicking the malware, the files are deleted! Since the user has the continous monitoring function (option 7) turned on, the user is  notified in red text on the console. 

https://github.com/Jas424/FIM/assets/88213779/2c1fa170-0a48-428b-b063-5dcf6038b5d0

- User is notfied vis email as well!

![image](https://github.com/Jas424/FIM/assets/88213779/80908f54-f09d-4a33-9b89-4b44cea43c02)

-Luckily, the user is able to restore the file as the tool stored backups of the baselines and the files in the directory.

https://github.com/Jas424/FIM/assets/88213779/9f0cd763-130c-461b-b9bf-8b3a001ecb59











