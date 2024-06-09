
FYAML_VER=$1
PATCH_DIR="${PWD}/Sources/CfyamlPatches/v${FYAML_VER}"

echo "Applying patches for version '${FYAML_VER}'"

if [ -d "${PATCH_DIR}" ]; then

  for PATCH_FILE in "${PATCH_DIR}"/*.patch; do
    patch -V none -d "${PWD}/Sources/Cfyaml" -i "${PATCH_FILE}"
  done

else
  echo "No patch directory for version ${FYYAML_VER}"
  exit 1
fi
