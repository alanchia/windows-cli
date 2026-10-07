# Windows powershell commands 

## MSI related commands
How do you list the GUID of a packaged that was installed through MSI
```
Get-CimInstance Win32_Product |
  Select-Object Name, IdentifyingNumber
```

Parametrized search criteria
```
$PROG = "adobe"

Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall,
              HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
  Get-ItemProperty |
  Where-Object { $_.DisplayName -like "*$PROG*" } |
  Select-Object DisplayName, PSChildName, UninstallString
```
