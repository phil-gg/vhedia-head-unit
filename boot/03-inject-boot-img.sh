#!/bin/bash

# Inject magisk_patched.img back into 8667.bin
# WARNING: Work in progress, didn't get this to work

# Set variables
filename="03-inject-boot-img.sh"
normal=$(printf '\033[0m')
redbold=$(printf '\033[91;1m')
greenbold=$(printf '\033[92;1m')
cyanbold=$(printf '\033[96;1m')
bluebold=$(printf '\033[94;1m')
FIRMWARE="8667.bin"
ORIGINAL_MD5SUM="17d69a4b5498bf3f6730a26b810d90f5"
PATCHED_IMG="magisk_patched.img"

# Now running `${filename}`
echo -e "\n${bluebold}Now running ‘${filename}’${normal}"

# Need zip
if ! command -v zip &> /dev/null; then
  echo -e "${redbold}> zip: Missing! Please install 'zip' to complete the packaging.${normal}\n"
  exit 101
fi

# Check if firmware exists
if [ ! -s "${FIRMWARE}" ]; then
  echo -e "\n${redbold}> Error: ${FIRMWARE} not found in the current directory!${normal}\n"
  exit 102
fi

# Check if patched boot image exists
if [ ! -s "${PATCHED_IMG}" ]; then
  echo -e "\n${redbold}> Error: ${PATCHED_IMG} not found in the current directory!${normal}\n"
  exit 103
fi

# Check original md5sum
echo -e "\n$ md5sum ${FIRMWARE}"
EXTRACT_MD5SUM="$(md5sum "${FIRMWARE}" 2> /dev/null | awk '{print $1}')"
if [[ "${ORIGINAL_MD5SUM}" == "${EXTRACT_MD5SUM}" ]]; then
  echo -e "${greenbold} ✅ The md5sum matches${normal}"
else
  echo -e "${redbold} ⛔ ${EXTRACT_MD5SUM}\n ⚠️ WARNING: unexpected md5sum${normal}\n"
  exit 104
fi

# Find the absolute starting byte of the binary partition table
# We use "super.img" as the anchor because it is the very first partition
TABLE_OFFSET="$(LC_ALL=C grep -abom 1 "super.img" "${FIRMWARE}" | head -n 1 | cut -d: -f1)"

PARTITION_NAMES=()
PARTITION_SIZES=()

# Loop through the table blocks (Assuming a max of 30 partitions for safety)
for ((i=0; i<30; i++)); do
  # Calculate the exact start of the current 72-byte entry block
  ENTRY_OFFSET=$((TABLE_OFFSET + i * 72))

  # Extract the Partition Name (starts 48 bytes into the block, max 16 bytes)
  PART_NAME=$(dd if="$FIRMWARE" bs=1 skip=$((ENTRY_OFFSET + 48)) count=16 2>/dev/null | tr -d '\0')

  # If the partition name is completely empty, we have hit the end of the table!
  if [ -z "$PART_NAME" ]; then
    break
  fi

  # Extract the Partition Size (starts 64 bytes into the block, max 8 bytes)
  PART_SIZE=$(dd if="$FIRMWARE" bs=1 skip=$((ENTRY_OFFSET + 64)) count=8 2>/dev/null | od -A n -t u8 | tr -d ' ')

  PARTITION_NAMES+=("$PART_NAME")
  PARTITION_SIZES+=("$PART_SIZE")
done

BOOT_IMG_SIZE=0
DISTANCE=0
START_SUMMING=false

# Loop through our parsed arrays to find the boot size and calculate the distance
for ((i=0; i<${#PARTITION_NAMES[@]}; i++)); do
  PART_NAME="${PARTITION_NAMES[i]}"
  PART_SIZE="${PARTITION_SIZES[i]}"

  # If we hit boot, capture the size and break the loop (stop summing)
  if [[ "$PART_NAME" == "boot" ]]; then
    BOOT_IMG_SIZE="$PART_SIZE"
    break
  fi

  # Start accumulating the distance the moment we hit recovery
  if [[ "$PART_NAME" == "recovery" ]]; then
    START_SUMMING=true
  fi

  # Add the current partition's size to our total distance
  if [[ "$START_SUMMING" == true ]]; then
    DISTANCE=$((DISTANCE + PART_SIZE))
  fi
done

# Find the anchor offset (the absolute start of recovery.img in the file)
# The 'ANDROID!' magic string marks the exact beginning of the recovery partition
RECOVERY_OFFSET="$(LC_ALL=C grep -abom 1 'ANDROID!' "${FIRMWARE}" | head -n 1 | cut -d: -f1)"

# Calculate the absolute BOOT_IMG_OFFSET
BOOT_IMG_OFFSET=$((RECOVERY_OFFSET + DISTANCE))

echo -e "> Target BOOT_IMG_OFFSET : ${bluebold}${BOOT_IMG_OFFSET}${normal}"
echo -e "> Target BOOT_IMG_SIZE   : ${bluebold}${BOOT_IMG_SIZE}${normal}"

#Safety check
PATCHED_SIZE=$(stat -c %s "${PATCHED_IMG}")

if [ "${PATCHED_SIZE}" -ne "${BOOT_IMG_SIZE}" ]; then
  echo -e "\n${redbold} ⛔ CRITICAL ERROR: Size mismatch!${normal}"
  echo -e "The ${PATCHED_IMG} (${PATCHED_SIZE} bytes) does not match the target partition size (${BOOT_IMG_SIZE} bytes)."
  echo -e "Please run the padding script before attempting injection.\n"
  exit 105
fi

# Rebuild 8667.bin
echo -e "\n${cyanbold}Building ${PATCHED_IMG} into ${FIRMWARE}${normal}"

# conv=notrunc only overwrites specifed bytes without truncating the rest of the firmware
dd if="${PATCHED_IMG}" of="${FIRMWARE}" bs=1 seek="${BOOT_IMG_OFFSET}" count="${BOOT_IMG_SIZE}" conv=notrunc

echo -e "\n${greenbold} ✅ Rebuild complete${normal}\n"

# Correct 8667.upd
echo -e "\n$ md5sum ${FIRMWARE}"
PATCHED_MD5SUM="$(md5sum "${FIRMWARE}" 2> /dev/null | awk '{print $1}')"
echo -e "> ${PATCHED_MD5SUM}"
echo "${PATCHED_MD5SUM}" > 8667.upd
