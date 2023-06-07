#created by jjf3
#06-07-2025 09:34 AM

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run the script as an administrator."
    Exit
}

# Set default browser registry keys
$defaultBrowserKeyPath = "HKLM:\SOFTWARE\Classes\http\shell\open\command"
$defaultBrowserValue = """C:\Program Files\Google\Chrome\Application\chrome.exe"" -- %1"

# Set default browser for current user
Set-ItemProperty -Path $defaultBrowserKeyPath -Name "(Default)" -Value $defaultBrowserValue

# Set default browser for all users
$users = Get-ChildItem "C:\Users" -Directory -Exclude "Public", "Default", "Default User"

foreach ($user in $users) {
    $userRegistryPath = Join-Path -Path $user.FullName -ChildPath "NTUSER.DAT"

    if (Test-Path $userRegistryPath) {
        $regHive = [Microsoft.Win32.RegistryHive]::Users
        $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software", $true)
        $regKey.CreateSubKey("Classes")

        $regUser = [Microsoft.Win32.Registry]::Users.Load($userRegistryPath)
        $regUserKey = $regUser.OpenSubKey("Software", $true)
        $regUserKey.CreateSubKey("Classes")

        $regUserKey.SetValue("http\shell\open\command", $defaultBrowserValue, [Microsoft.Win32.RegistryValueKind]::String)
        $regUserKey.Close()

        $regKey.Close()
        $regUser.Unload()
    }
}

Write-Host "Default browser set to Google Chrome for all users."
