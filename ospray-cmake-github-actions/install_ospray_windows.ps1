## -------------------
## Constants
## -------------------

# Dictionary of known ospray versions and thier download URLS, which do not follow a consistent pattern :(
$OSPRAY_KNOWN_URLS = @{
    "2.5.0" = "https://github.com/ospray/ospray/releases/download/v2.5.0/ospray-2.5.0.x86_64.windows.zip";
	"2.6.0" = "https://github.com/ospray/ospray/releases/download/v2.6.0/ospray-2.6.0.x86_64.windows.zip"
}

## -------------------
## Select OSPRay version
## -------------------

# Get the ospray version from the environment as env:ospray.
$OSPRAY_VERSION_FULL = $env:ospray
# Make sure OSPRAY_VERSION_FULL is set and valid, otherwise error.

# Validate OSPRay version, extracting components via regex
$ospray_ver_matched = $OSPRAY_VERSION_FULL -match "^(?<major>[1-9][0-9]*)\.(?<minor>[0-9]+)\.(?<patch>[0-9]+)$"
if(-not $ospray_ver_matched){
    Write-Output "Invalid OSPRay version specified, <major>.<minor>.<patch> required. '$OSPRAY_VERSION_FULL'."
    exit 1
}
$OSPRAY_MAJOR=$Matches.major
$OSPRAY_MINOR=$Matches.minor
$OSPRAY_PATCH=$Matches.patch

## ------------------------------------------------
## Select OSPRay packages to install from environment
## ------------------------------------------------

$RELEASE_URL = $OSPRAY_KNOWN_URLS[$OSPRAY_VERSION_FULL]
$RELEASE_FILE = "ospray-$OSPRAY_VERSION_FULL.x86_64.windows"
echo "RELEASE_URL $RELEASE_URL"
echo "RELEASE_FILE $RELEASE_FILE"

## ------------
## Install OSPRay
## ------------

(New-Object System.Net.WebClient).DownloadFile($RELEASE_URL, "$RELEASE_FILE.zip")
Expand-Archive -Path "$RELEASE_FILE.zip" -Destination $RELEASE_FILE

## ------------------------------------------------
## Select OSPRay packages to install from environment
## ------------------------------------------------

$OSPRAY_CMAKE_DIR="$RELEASE_FILE\lib\cmake\ospray-$OSPRAY_VERSION_MAJOR_MINOR"

# Set environmental variables in this session
$env:OSPRAY_CMAKE_DIR = "$($OSPRAY_CMAKE_DIR)"
Write-Output "OSPRAY_CMAKE_DIR $($OSPRAY_CMAKE_DIR)"

# If executing on github actions, emit the appropriate echo statements to update environment variables
if (Test-Path "env:GITHUB_ACTIONS") {
    # Set paths for subsequent steps, using ${OSPRAY_CMAKE_DIR}
    echo "Adding OSPRay to OSPRAY_CMAKE_DIR and LD_LIBRARY_PATH"
    echo "OSPRAY_CMAKE_DIR=$env:OSPRAY_CMAKE_DIR" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
