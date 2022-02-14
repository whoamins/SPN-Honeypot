# SPN-Honeypot
Detect Kerberoasting. *Not finished yet, don't need to use yet*

There is an effective way to detect Kerberoasting, which is to create an account and an SPN that will not be used (the created SPN is not associated with any real application). 

Kerberos clients will never request a TGS ticket for a false SPN, so if the corresponding event 4769 appears in the DC security log, then the use of Kerberoasting can be noticed.
