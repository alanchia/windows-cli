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

## Interactive uninstall script

Use `uninstall-by-search.ps1` to search installed applications by display name,
publisher, or registry key/GUID. It prints the matching entries and their GUIDs,
then asks whether to continue. Before each uninstall it shows the command and
asks for a separate confirmation.

Open PowerShell in this directory and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\uninstall-by-search.ps1 -SearchCriteria "adobe"
```

You can also search by publisher or part of a GUID:

```powershell
.\uninstall-by-search.ps1 -SearchCriteria "Microsoft"
.\uninstall-by-search.ps1 -SearchCriteria "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}"
```

Answer `y` at the first prompt to review the matches, and answer `y` again
for each application you actually want to uninstall. Press Enter or answer
anything other than `y` to make no change or skip that application. Run
PowerShell as Administrator when uninstalling a machine-wide application.
