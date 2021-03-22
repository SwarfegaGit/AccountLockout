Log AD Account Lockout
======================

I frequently get asked which machine a user is logged into that is causing an account lockout.  The logs on the Primary Domain Controller (PDC) rotate quickly.  By the time the question has been asked the event will have been overwritten.  To combat this I wrote a script to export this information to a CSV file.

Installation
------------

*Note: This script required version 3 or higher of Windows PowerShell.  Whilst untested the script should also work fine in PowerShell Core.*

Download the AccountLockout.ps1 file. Copy the AccountLockout.ps1 file to any folder on your PDC.  For example 'C:\Scripts\AccountLockoutLog'.

1. On the PDC open Event Viewer. 
2. Open the Security log. 
3. Click 'Filter Current Log...'.   
4. In the Event IDs filter box type 4740 and click OK. 
5. Highlight any of the listed events.  
6. Click 'Attach Task To This Event...' (not 'Attach a Task To this Log')
7. Click Next three times.
8. In 'Program/script' type powershell.exe
9. In 'Add arguments (optional):' type the location of the PS1 file E.G C:\Scripts\AccountLockoutLog\AccountLockout.ps1
10. Click Next and finally Finish.

At this point there is nothing else to do.  The output file will get created in the same directory where you stored the PS1 file.  A new file is create each month in the format of 'AccountLockout(Month-Year).csv'. 

These logs are not huge (I have a 765KB file which contains 17000 items) so make sure there is some housekeep done to prevent the drive filling up given a long enough timeframe.  Again this is something that can be automated easily enough by modifing the PS1 file.

The CSV file can be opened in any editor but the most likly candidate is Excel.  Since this is a CSV file the data can be further using PowerShell such as searching for all lockouts for one user...

```powershell
Import-Csv 'AccountLockoutLog(July-2018).csv' | Where-Object -Property Username -EQ -Value ASample

Username CallerComputer TimeCreated        
-------- -------------- -----------        
ASample  DT002482       16/03/2017 18:23:33
ASample  DT002482       16/03/2017 18:32:38
ASample  DT002482       16/03/2017 18:35:09
```

Listing how many lockouts for each logged user...

```powershell
Import-Csv 'AccountLockoutLog(July-2018).csv' | Group-Object -Property Username -NoElement | Sort-Object -Property Count -Descending

Count Name                     
----- ----                     
 1123 JNever              
  506 AGonna              
  153 SGive            
  117 JYou                    
  116 JUp              
  115 GNever                  
  106 LLet                  
  100 CYou                
   98 PDown                
   92 JNever                 
   90 DGonna                  
   89 ERun               
   87 OAround                     
   83 KAnd                    
   82 SDesert  
   82 HYou                    
```

Search for lockouts for a single user across multiple CSV files...

```powershell
Get-ChildItem -Filter *.csv | ForEach { Import-Csv -Path $PSItem.FullName } | Where-Object -Property Username -EQ -Value ASample


Username CallerComputer TimeCreated        
-------- -------------- -----------        
ASample  DT002482       16/03/2017 18:23:33
ASample  DT002482       21/04/2017 08:26:44
ASample  DT002482       03/01/2018 13:34:46
```