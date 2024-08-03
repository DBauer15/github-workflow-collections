## -------------------
## Constants
## -------------------

## -------------------
## Select Torch version
## -------------------
TORCH_VERSION_MAJOR_MINOR=${torch}
#
# Split the version.
# We (might/probably) don't know PATCH at this point - it depends which version gets installed.
TORCH_MAJOR=$(echo "${TORCH_VERSION_MAJOR_MINOR}" | cut -d. -f1)
TORCH_MINOR=$(echo "${TORCH_VERSION_MAJOR_MINOR}" | cut -d. -f2)
TORCH_PATCH=$(echo "${TORCH_VERSION_MAJOR_MINOR}" | cut -d. -f3)
# use lsb_release to find the OS.
UBUNTU_VERSION=$(lsb_release -sr)
UBUNTU_VERSION="${UBUNTU_VERSION//.}"

echo "TORCH_MAJOR: ${TORCH_MAJOR}"
echo "TORCH_MINOR: ${TORCH_MINOR}"
echo "TORCH_PATCH: ${TORCH_PATCH}"
echo "UBUNTU_VERSION: ${UBUNTU_VERSION}"

# If we don't know the TORCH_MAJOR or MINOR, error.
if [ -z "${TORCH_MAJOR}" ] ; then
    echo "Error: Unknown OSPRay Major version. Aborting."
    exit 1
fi
if [ -z "${TORCH_MINOR}" ] ; then
    echo "Error: Unknown OSPRay Minor version. Aborting."
    exit 1
fi
# If we don't know the Ubuntu version, error.
if [ -z ${UBUNTU_VERSION} ]; then
    echo "Error: Unknown Ubuntu version. Aborting."
    exit 1
fi

## -----------------
## Prepare to install
## -----------------
RELEASE_URL="https://download.pytorch.org/libtorch/cu121/libtorch-shared-with-deps-${TORCH_VERSION_MAJOR_MINOR}%2Bcu121.zip"
RELEASE_FILE="${PWD}/libtorch-shared-with-deps-${TORCH_VERSION_MAJOR_MINOR}+cu121"
RELEASE_DIR="${PWD}/libtorch"

echo "RELEASE_URL ${RELEASE_URL}"
echo "RELEASE_FILE ${RELEASE_FILE}"
echo "RELEASE_DIR ${RELEASE_DIR}"

## -----------------
## Download and install
## -----------------
wget -q ${RELEASE_URL}
unzip "${RELEASE_FILE}.zip"

if [[ $? -ne 0 ]]; then
    echo "Torch Installation Error."
    exit 1
fi

## -----------------
## Set environment vars / vars to be propagated
## -----------------
export TORCH_CMAKE_DIR="${RELEASE_DIR}/share/cmake/Torch"
export LD_LIBRARY_PATH="${RELEASE_DIR}/lib:${LD_LIBRARY_PATH}"

# If executed on github actions, make the appropriate echo statements to update the environment
if [[ $GITHUB_ACTIONS ]]; then
    # Set paths for subsequent steps, using ${TORCH_CMAKE_DIR}
    echo "Adding Torch to TORCH_CMAKE_DIR and LD_LIBRARY_PATH"
    echo "TORCH_CMAKE_DIR=${TORCH_CMAKE_DIR}" >> $GITHUB_ENV
    echo "LD_LIBRARY_PATH=${RELEASE_DIR}/lib:${LD_LIBRARY_PATH}" >> $GITHUB_ENV
fi
