#!/bin/bash

# Pad magisk_patched.img to match original boot.img size

# Set variables
filename="02-extract-boot-img.sh"
normal=$(printf '\033[0m')
redbold=$(printf '\033[91;1m')
greenbold=$(printf '\033[92;1m')
cyanbold=$(printf '\033[96;1m')
bluebold=$(printf '\033[94;1m')
ORIGINAL_IMG="boot.img"
PATCHED_IMG="magisk_patched.img"

# Now running `${filename}`
echo -e "\n${bluebold}Now running ‘${filename}’${normal}"

# Need truncate
if ! command -v truncate &> /dev/null; then
  echo -e "$\n{redbold}> truncate: Missing! Install coreutils then re-run this script${normal}\n"
  exit 101
fi

# Check if original boot image exists
if [ ! -s "${ORIGINAL_IMG}" ]; then
  echo -e "$\n{redbold}> Error: ${ORIGINAL_IMG} not found in the current directory!${normal}\n"
  exit 102
fi

# Check if patched boot image exists
if [ ! -s "${PATCHED_IMG}" ]; then
  echo -e "\n${redbold}> Error: ${PATCHED_IMG} not found in the current directory!${normal}\n"
  exit 103
fi

# Extract sizes using stat (Standard GNU Linux method)
ORIGINAL_SIZE=$(stat -c %s "${ORIGINAL_IMG}")
PATCHED_SIZE=$(stat -c %s "${PATCHED_IMG}")

echo -e "\n> ${ORIGINAL_IMG} size: ${ORIGINAL_SIZE} bytes"
echo -e "> ${PATCHED_IMG} size: ${PATCHED_SIZE} bytes\n"

# Compare sizes and pad if necessary
if [ "${PATCHED_SIZE}" -lt "${ORIGINAL_SIZE}" ]; then
  echo -e "${cyanbold}Patched image is smaller. Padding with null bytes...${normal}"
  
  # The truncate command will extend the file to match the exact byte size
  truncate -s "${ORIGINAL_SIZE}" "${PATCHED_IMG}"
  
  # Verify the new size
  NEW_PATCHED_SIZE=$(stat -c %s "${PATCHED_IMG}")
  if [ "${NEW_PATCHED_SIZE}" -eq "${ORIGINAL_SIZE}" ]; then
    echo -e "${greenbold} ✅ Success! ${PATCHED_IMG} is now exactly ${NEW_PATCHED_SIZE} bytes.${normal}\n"
  else
    echo -e "${redbold} ⛔ Error: Padding failed. Size is ${NEW_PATCHED_SIZE} bytes.${normal}\n"
    exit 104
  fi

elif [ "${PATCHED_SIZE}" -eq "${ORIGINAL_SIZE}" ]; then
  echo -e "${greenbold} ✅ Sizes match.  No padding required!${normal}\n"

else
  echo -e "${redbold} ⚠️ WARNING: ${PATCHED_IMG} is LARGER than the original!${normal}"
  echo -e "This is highly unusual for Magisk and may cause a bootloop if flashed.\n"
  exit 105
fi