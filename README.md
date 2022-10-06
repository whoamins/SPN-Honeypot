# SPN-Honeypot
Detect Kerberoasting.

There is an effective way to detect Kerberoasting, which is to create an account and an SPN that will not be used (the created SPN is not associated with any real application). 

Kerberos clients will never request a TGS ticket for a false SPN, so if the corresponding event 4769 appears in the DC security log, then the use of Kerberoasting can be noticed.

# Installation
## Step 1
Download the archive with scripts and extract it to some place

## Step 2
Run the *script.ps1* script. It will create fake account and SPN.

```
PS > ./script.ps1
```

If you can't start script because you have Restricted execution policy - Try this command and again try to run *script.ps1*

```
PS > powershell -ep bypass
```

## Step 3
After installation - delete plain text password from the script, because it already unnecessary

For example, set the value to 1.

![изображение](https://user-images.githubusercontent.com/66217512/194409894-2e45def3-c870-4046-a47b-61615cea4589.png)


# How it will notify me?
If honeypot has been triggered, you will see Windows 10 notification on the right bottom corner (default windows 10 notification)

![image](https://user-images.githubusercontent.com/66217512/157062031-3f52bc72-411f-48f2-b110-04657388b9f3.png)

![изображение](https://user-images.githubusercontent.com/66217512/194408763-58e04bf6-65d6-4a7a-b701-95f0158b19b4.png)


# Change the script start time

If you want to run the script every 2 minutes for instance. You should change this on the third line in *sheduler.ps1* and on the second line in *script.ps1*.

**Attention**: In the *script.ps1* you should change the time in seconds. (300 = 5 min, 120 = 2 min).

# TODO


1. GUI with alert history
2. Connection with some SIEM systems
3. Update guide
4. More secure password storage...
5. Add the ability to choose service exe file6
6. Check results code - [info](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4769)
