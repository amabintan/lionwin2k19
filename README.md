# Lionwin2k19 Project
The objective is to ensure the security of Microsoft Windows 2019 Operating Systems, i.e. prevent unauthorized access to the systems. this checklist based on custom hardening of CIS benchmark.

## Getting Started

The Microsoft Windows 2019 Server Security Standards only addresses the operating system security of Microsoft Windows 2019 production/dr systems.  It does not address applications security, non-production servers. These are following security checklist for Windows Server 2019 scope:

**Scope**
| Point | Task | Description
| --- | --- | --- |
| 1.1 | General Information | Included on Script |
| 1.2 | Account Policies | Included on Script |
| 1.3 | Advanced Audit Policy | Included on Script |
| 1.4 | User Rights Assignment | Included on Script |
| 1.5 | Security Options | Included on Script |
| 1.6 | Event Log Settings | Included on Script |
| 1.7 | Default Installed Services  | Included on Script |
| 1.8 | Optional Services (Optional)| Manual , If required|
| 1.9 | Account and Password Settings | Included on Script |
| 1.10 | Registry Key Entries | Included on Script |

### Prerequisites

1. Download the source code from this url https://github.com/amabintan/lionwin2k19/archive/master.zip

2. Copy the source code to C:\, extract the file

3. Open Powershell, go to root directory of source code

## Running the hardening script

```
C:\> cd lionwin2k19-master
C:\lionwin2k19-master> .\hardeningw2k19.ps1
```

**Note**
> On Windows Server 2019, we need to  perform manual task to disable Windows Defender Service.
>1. Run Command Prompt as Administrator.
>2. Type msc and press Enter.
>3. Go to Computer Configuration > Administrative Templates > Windows Components > Windows Defender.
>4. Double click Turn Off Windows Defender.
>5. Check Enabled.
>6. Click Apply.
> Then run this command on Powershell
>```
>Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" -Name "Start" -Value "4" -Type DWORD -ErrorAction SilentlyContinue
>Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name "Start" -Value "4" -Type DWORD -ErrorAction SilentlyContinue
>```

## Authors

* **Barli D** - *Initial work* - [https://github.com/amabintan/lionwin2k19](https://github.com/amabintan/lionwin2k19)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details




