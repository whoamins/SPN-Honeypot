# SPN-Honeypot
Detect Kerberoasting.

There is an effective way to detect Kerberoasting, which is to create an account and an SPN that will not be used (the created SPN is not associated with any real application). 

Kerberos clients will never request a TGS ticket for a false SPN, so if the corresponding event 4769 appears in the DC security log, then the use of Kerberoasting can be noticed.

# Installation
## Step 1
Download the archive with scripts and extract it to some place

## Step 2
Run the *create.ps1* script. It will create fake account and SPN.

```
PS > ./create.ps1
```

If you can't start script because you have Restricted execution policy - Try this command and again try to run *create.ps1*

```
PS > powershell -ep bypass
```

## Step 3
Open the file named *sheduler.ps1* and change path to *script.ps1* on the first line

```
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File C:\Users\Administrator\Desktop\script.ps1'
```

## Step 4
Run the *sheduler.ps1*. It will create task in the TaskSheduler and will run it every 5 minutes.

```
PS > ./sheduler.ps1
```

# change the script start time

If you want to run the script every 2 minutes for instance. You should change this on the third line in *sheduler.ps1* and on the second line in *script.ps1*.

**Attention**: In the *script.ps1* you should change the time in seconds. (300 = 5 min, 120 = 2 min).
