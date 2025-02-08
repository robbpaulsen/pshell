# Install/update rustup and cargo.
# The first argument should be the toolchain to install.

$Toolchain = 'stable-x86_64-pc-windows-msvc'
$Target = 'x86_64-pc-windows-msvc'

# Function to check and install Chocolatey
function Install-Choco {
    if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully."
    } else {
        Write-Host "Chocolatey is already installed."
    } catch {
        Write-Warning $_
    }
}

# Call the function to check/install Chocolatey
Install-Choco

# Ensure rustup is installed
if (-not (Get-Command "rustup" -ErrorAction SilentlyContinue)) {
    Write-Host "Rustup not found. Installing..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://sh.rustup.rs')
}

# Set rustup profile to minimal
rustup set profile default

# Remove rust-docs if exists
try {
    rustup component remove --toolchain=$Toolchain rust-docs
} catch {
    Write-Host "rust-docs already removed or not present."
}

# Update the specified toolchain
rustup update $Toolchain

# Check if target argument is provided
if ($Target) {
    $Host = rustc -Vv | Select-String "^host:" | ForEach-Object { $_ -replace "host: ", "" }
    if ($Host -ne $Target) {
        rustup component add llvm-tools-preview --toolchain=$Toolchain
        rustup component add rust-std-$Target --toolchain=$Toolchain
    }

    if ($Target -eq "x86_64-pc-windows-msvc") {
        Write-Host "Setting environment variables for x86_64-pc-windows-msvc ..."
        [System.Environment]::SetEnvironmentVariable('CARGO_TARGET_X86_64_PC_WINDOWS-MSVC_LINKER', 'rust-lld', [System.EnvironmentVariableTarget]::Process)
        choco install --verbose --accept-license --yes gcc-aarch64-linux-gnu
        [System.Environment]::SetEnvironmentVariable('CC', 'x86_64-pc-windows-msvc', [System.EnvironmentVariableTarget]::Process)
    }
}

# Set default toolchain
rustup default $Toolchain

# Display versions
rustup -V
rustc -Vv
cargo -V