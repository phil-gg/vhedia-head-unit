#!/bin/bash

# Extract boot.img from 8667.bin

# Set variables
filename="alt-firmware-analysis.sh"
normal=$(printf '\033[0m')
redbold=$(printf '\033[91;1m')
greenbold=$(printf '\033[92;1m')
cyanbold=$(printf '\033[96;1m')
bluebold=$(printf '\033[94;1m')
FIRMWARE="8667.bin"
ORIGINAL_MD5SUM="17d69a4b5498bf3f6730a26b810d90f5"

# Now running `${filename}`
echo -e "\n${bluebold}Now running ‘${filename}’${normal}"

# Need curl
if ! command -v curl &> /dev/null; then
  echo -e "${redbold}> curl: Missing! Install then re-run this script${normal}"
  exit 101
fi

# Need tar
if ! command -v tar &> /dev/null; then
  echo -e "${redbold}> tar: Missing! Install then re-run this script${normal}"
  exit 102
fi

# Get firmware with curl
if [ ! -s M-series-20240924.tar.xz ]; then
  echo -e "\n$ curl -fLO https://github.com/phil-gg/vhedia-head-unit/releases/download/M-series-firmware/M-series-20240924.tar.xz\n"
  curl -fLO https://github.com/phil-gg/vhedia-head-unit/releases/download/M-series-firmware/M-series-20240924.tar.xz || {
    echo -e "${redbold}> curl: Download failed${normal}\n"
    exit 103
  }
fi

# Unpack firmware
if [ ! -s "${FIRMWARE}" ]; then
  echo -e "\n$ tar -xf M-series-20240924.tar.xz"
  tar -xf M-series-20240924.tar.xz || {
    echo -e "${redbold}> tar: Unpack failed${normal}\n"
    exit 104
  }
fi

# Check original md5sum
echo -e "\n$ md5sum ${FIRMWARE}"
EXTRACT_MD5SUM="$(md5sum "${FIRMWARE}" 2> /dev/null | awk '{print $1}')"
if [[ "${ORIGINAL_MD5SUM}" == "${EXTRACT_MD5SUM}" ]]; then
  echo -e "${greenbold} ✅ The md5sum matches${normal}"
else
  echo -e " ⛔ ${EXTRACT_MD5SUM}
${redbold} ⚠️ WARNING: unexpected md5sum${normal}\n"
  exit 105
fi

# Analysing header only first
echo -e "\n${cyanbold}Validating header${normal}"

# First 4 bytes must be exactly "xj66"
HEADER_MAGIC=$(head -c 4 "$FIRMWARE")
if [[ "$HEADER_MAGIC" == "xj66" ]]; then
    echo -e "${greenbold} ✅ Found 'xj66' magic number${normal}"
else
    echo -e "${redbold} ⛔ Error: Expected 'xj66' at the start of the file; got: ${normal}${HEADER_MAGIC}"
    exit 106
fi

# Bytes 5-8 must be strictly null padding (\0\0\0\0)
# -An (no addresses), -j4 (skip first 4 bytes), -N4 (read 4 bytes), -tx1 (hex output)
HEADER_PAD=$(od -An -j4 -N4 -tx1 "$FIRMWARE" | tr -d ' \n')
if [[ "$HEADER_PAD" == "00000000" ]]; then
    echo -e "${greenbold} ✅ Found null padding at bytes 5-8${normal}"
else
    echo -e "${redbold} ⛔ Error: Expected null padding; got hex: ${normal}${HEADER_PAD}"
    exit 107
fi

# Android sparse image magic number should sit straight after xj66 header
# -a (treat as text)
# -b (print byte offset)
# -o (print only matching parts)
# -F (treat pattern as a fixed string, not a regex)
# -m 1 (stop immediately after the first match)
MAGIC=$'\x3a\xff\x26\xed'
OFFSET=$(LC_ALL=C grep -aboFm 1 "$MAGIC" "$FIRMWARE" | cut -d: -f1)

# Ensure we actually found an offset
if [ -z "$OFFSET" ]; then
    echo -e "${redbold} ⛔ Error: Could not find Android sparse image magic number.${normal}"
    exit 108
fi

# Add 4 bytes to include the magic number itself
INCLUSIVE_OFFSET=$((OFFSET + 4))
echo -e "> ${INCLUSIVE_OFFSET} ${greenbold}bytes from top of file to first Android sparse image magic number (inclusive)${normal}"

# Python header analysis
echo -e "\n${cyanbold}Extracting header info${normal}"

# We wrap the Python call in $() to capture its stdout into a Bash variable
PYTHON_VARS=$(
head -c "$INCLUSIVE_OFFSET" "$FIRMWARE" | python3 -c "
import sys
import struct

data = sys.stdin.buffer.read()

# Must be at least 1 entry so 8 + 72 + 4 minimum total bytes
if len(data) < 84:
    print('${redbold} ⛔ Error: The extracted header is too small to be valid.${normal}', file=sys.stderr)
    sys.exit(109)

# The gap is the total size of our piped data, minus the 8-byte xj66 signature, 
# AND minus the 4-byte sparse magic number we included at the end
gap = len(data) - 8 - 4

# Check that the remaining space is a perfect multiple of 72 bytes
if gap % 72 == 0:
    entries = gap // 72
    print('${greenbold} ✅ Found that the header gap is a clean multiple of 72${normal}', file=sys.stderr)
    # Note: Removed the \n here so the next message prints directly underneath
    print(' 📋 Found exactly ${bluebold}' + str(entries) + '${normal} entries implied by the gap size', file=sys.stderr)
else:
    print('${redbold} > ⛔ Error: Expected a clean multiple of 72; actual gap is: ${normal}' + str(gap), file=sys.stderr)
    sys.exit(110)

# ---------------------------------------------------------
# Parse the table entries and filter out null padding
# ---------------------------------------------------------
FILENAME = []
PARTNAME = []
PARTSIZE = []

# The payload sits exactly between the 8-byte start and 4-byte end
payload = data[8:-4]

for i in range(entries):
    # Slice out the specific 72-byte chunk for this iteration
    chunk = payload[i*72 : (i+1)*72]
    
    # Extract the strings. We split at the first null byte (b'\x00') to discard the padding
    fname = chunk[0:48].split(b'\x00')[0].decode('ascii', errors='replace')
    pname = chunk[48:64].split(b'\x00')[0].decode('ascii', errors='replace')
    
    # Extract the 64-bit little-endian unsigned integer ('<Q') for the size
    size = struct.unpack('<Q', chunk[64:72])[0]
    
    # (1 & 3) Skip the entry if it is a completely empty padding block
    if fname == '' and pname == '' and size == 0:
        continue
    
    FILENAME.append(fname)
    PARTNAME.append(pname)
    PARTSIZE.append(size)

# (2) Print the populated entries count directly underneath the total entries count
filled_entries = len(FILENAME)
print(' 📋 Found ${bluebold}' + str(filled_entries) + '${normal} populated entries in the xj66 header\n', file=sys.stderr)

# ---------------------------------------------------------
# Print the clean three-column table to STDERR (Terminal UI)
# ---------------------------------------------------------
# Calculate column widths dynamically using only the populated arrays
w_file = max(len('FILENAME'), max((len(f) for f in FILENAME), default=0))
w_part = max(len('PARTNAME'), max((len(p) for p in PARTNAME), default=0))
w_size = max(len('PARTSIZE'), max((len(str(s)) for s in PARTSIZE), default=0))

print(f\"{'FILENAME':<{w_file}} | {'PARTNAME':<{w_part}} | {'PARTSIZE':<{w_size}}\", file=sys.stderr)
print('-' * (w_file + w_part + w_size + 6), file=sys.stderr)

for f, p, s in zip(FILENAME, PARTNAME, PARTSIZE):
    print(f\"{f:<{w_file}} | {p:<{w_part}} | {s:<{w_size}}\", file=sys.stderr)

# ---------------------------------------------------------
# Print the Bash arrays to STDOUT (Captured by Bash)
# ---------------------------------------------------------
f_str = ' '.join(f'\"{f}\"' for f in FILENAME)
p_str = ' '.join(f'\"{p}\"' for p in PARTNAME)
s_str = ' '.join(str(s) for s in PARTSIZE)

print(f'FILENAME=({f_str})')
print(f'PARTNAME=({p_str})')
print(f'PARTSIZE=({s_str})')
")

# Catch the exit code of the Python process in case it failed
PY_EXIT=$?
if [ $PY_EXIT -ne 0 ]; then
    exit $PY_EXIT
fi

# Evaluate the hidden Python output to create the Bash arrays
eval "$PYTHON_VARS"

# Quick proof that Bash now owns the truncated data!
echo -e "\n${greenbold}Bash Array Test:${normal} The last populated partition is:
${bluebold}${FILENAME[-1]} | ${PARTNAME[-1]} | ${PARTSIZE[-1]}${normal}"

# Analyse whole firmware file
echo -e "\n${cyanbold}Analysing whole ${FIRMWARE} file${normal}"

# Export the Bash variables so the Python environment can read them safely
export FIRMWARE
export OFFSET
export BASH_FILENAME="${FILENAME[*]}"
export BASH_PARTNAME="${PARTNAME[*]}"
export BASH_PARTSIZE="${PARTSIZE[*]}"

PYTHON_MAP=$(python3 -c "
import os
import sys
import struct

# Retrieve the arrays from Bash
filenames = os.environ['BASH_FILENAME'].split()
partnames = os.environ['BASH_PARTNAME'].split()
partsizes = [int(x) for x in os.environ['BASH_PARTSIZE'].split()]
firmware = os.environ['FIRMWARE']
start_offset = int(os.environ['OFFSET'])

SPARSE = []
PACKEDSIZE = []
STARTOFFSET = []  # We track the true start offset for Bash extraction

current_offset = start_offset

try:
    with open(firmware, 'rb') as f:
        for i in range(len(filenames)):
            STARTOFFSET.append(current_offset)
            
            # Read the first 4 bytes of the partition to check for Sparse Magic
            f.seek(current_offset)
            magic = f.read(4)
            
            if magic == b'\x3a\xff\x26\xed':
                SPARSE.append(1)
                
                # Parse the 28-byte Sparse Image Header
                f.seek(current_offset)
                header_data = f.read(28)
                # <I4H4I unpacks: magic(4), major(2), minor(2), file_hdr_sz(2), 
                # chunk_hdr_sz(2), blk_sz(4), total_blks(4), total_chunks(4), checksum(4)
                _, _, _, file_hdr_sz, _, _, _, total_chunks, _ = struct.unpack('<I4H4I', header_data)
                
                # The physical size starts with the length of the file header
                physical_size = file_hdr_sz
                f.seek(current_offset + file_hdr_sz)
                
                # Loop through every chunk to calculate exact physical size
                for _ in range(total_chunks):
                    chunk_hdr = f.read(12)
                    if len(chunk_hdr) < 12: 
                        break
                    # <2H2I unpacks: type(2), reserved(2), chunk_sz_blocks(4), total_sz_bytes(4)
                    _, _, _, c_total_sz = struct.unpack('<2H2I', chunk_hdr)
                    
                    physical_size += c_total_sz
                    
                    # Jump forward over the payload to the next chunk header
                    f.seek(c_total_sz - 12, os.SEEK_CUR)
                
                PACKEDSIZE.append(physical_size)
                current_offset += physical_size
                
            else:
                # It is a raw image. Physical size equals the partition size.
                SPARSE.append(0)
                PACKEDSIZE.append(partsizes[i])
                current_offset += partsizes[i]

except Exception as e:
    print(f'${redbold} ⛔ Error parsing physical boundaries: {e}${normal}', file=sys.stderr)
    sys.exit(111)

# ---------------------------------------------------------
# Print the 6-Column Table to STDERR
# ---------------------------------------------------------
w_f = max(len('FILENAME'), max((len(x) for x in filenames), default=0))
w_p = max(len('PARTNAME'), max((len(x) for x in partnames), default=0))
w_sz = max(len('PARTSIZE'), max((len(str(x)) for x in partsizes), default=0))
w_sp = max(len('SPARSE'), max((len(str(x)) for x in SPARSE), default=0))
w_pk = max(len('PACKEDSIZE'), max((len(str(x)) for x in PACKEDSIZE), default=0))
w_so = max(len('STARTOFFSET'), max((len(str(x)) for x in STARTOFFSET), default=0))

print(f\"{'FILENAME':<{w_f}} | {'PARTNAME':<{w_p}} | {'PARTSIZE':<{w_sz}} | {'SPARSE':<{w_sp}} | {'PACKEDSIZE':<{w_pk}} | {'STARTOFFSET':<{w_so}}\", file=sys.stderr)
print('-' * (w_f + w_p + w_sz + w_sp + w_pk + w_so + 15), file=sys.stderr)

for f, p, sz, sp, pk, so in zip(filenames, partnames, partsizes, SPARSE, PACKEDSIZE, STARTOFFSET):
    print(f\"{f:<{w_f}} | {p:<{w_p}} | {sz:<{w_sz}} | {sp:<{w_sp}} | {pk:<{w_pk}} | {so:<{w_so}}\", file=sys.stderr)

# ---------------------------------------------------------
# Export new arrays to Bash STDOUT
# ---------------------------------------------------------
print(f\"SPARSE=({' '.join(str(x) for x in SPARSE)})\")
print(f\"PACKEDSIZE=({' '.join(str(x) for x in PACKEDSIZE)})\")
print(f\"STARTOFFSET=({' '.join(str(x) for x in STARTOFFSET)})\")
")

# Catch Python exit codes
PY_MAP_EXIT=$?
if [ $PY_MAP_EXIT -ne 0 ]; then
    exit $PY_MAP_EXIT
fi

# Ingest the new arrays
eval "$PYTHON_MAP"

# Quick proof that Bash now owns the full 6-column physical data!
echo -e "\n${greenbold}Bash Array Test:${normal} The last physical partition is:"
echo -e "${bluebold}${FILENAME[-1]} | ${PARTNAME[-1]} | ${PARTSIZE[-1]} | ${SPARSE[-1]} | ${PACKEDSIZE[-1]} | ${STARTOFFSET[-1]}${normal}"

# Validate physical bounds against actual file size
echo -e "\n${cyanbold}Validating physical file bounds${normal}"

# Use GNU stat to get the exact file size in bytes
ACTUAL_SIZE=$(stat -c%s "$FIRMWARE")
CALCULATED_END=$(( STARTOFFSET[-1] + PACKEDSIZE[-1] ))

echo -e " 📋 Actual file size: ${bluebold}${ACTUAL_SIZE}${normal} bytes"
echo -e " 📋 Calculated end:   ${bluebold}${CALCULATED_END}${normal} bytes"

if [ "$CALCULATED_END" -eq "$ACTUAL_SIZE" ]; then
    echo -e "${greenbold} ✅ Validation passed! The partitions perfectly span to the end of the file.${normal}\n"
elif [ "$CALCULATED_END" -lt "$ACTUAL_SIZE" ]; then
    TRAILING_BYTES=$(( ACTUAL_SIZE - CALCULATED_END ))
    echo -e "${greenbold} ✅ Validation passed! The partitions safely fit inside the file.${normal}"
    echo -e " 💡 Note: There are ${bluebold}${TRAILING_BYTES}${normal} bytes of unmapped trailing data (likely cryptographic signatures or padding).\n"
else
    echo -e "${redbold} ⛔ Error: The calculated partitions extend beyond the actual file size!${normal}\n"
    exit 112
fi

# Locate boot.img Offset and Size
echo -e "\n${cyanbold}Locating boot.img payload${normal}"
FOUND_BOOT=false

for i in "${!FILENAME[@]}"; do
    if [[ "${FILENAME[$i]}" == "boot.img" && "${PARTNAME[$i]}" == "boot" ]]; then
        BOOT_IMG_OFFSET="${STARTOFFSET[$i]}"
        BOOT_IMG_SIZE="${PARTSIZE[$i]}"
        FOUND_BOOT=true
        break
    fi
done

if [ "$FOUND_BOOT" = true ]; then
    echo -e "${greenbold} ✅ Found boot.img${normal}"
    echo -e " 📋 Offset: ${bluebold}${BOOT_IMG_OFFSET}${normal} bytes"
    echo -e " 📋 Size:   ${bluebold}${BOOT_IMG_SIZE}${normal} bytes"
else
    echo -e "${redbold} ⛔ Error: Could not find boot.img in the partition table.${normal}"
    exit 113
fi

# Extract boot.img
echo -e "\n${cyanbold}Writing boot.img${normal}\n"
dd if="${FIRMWARE}" of="boot.img" bs=1 skip="${BOOT_IMG_OFFSET}" count="${BOOT_IMG_SIZE}" status=progress

# Verify the file was actually created and is greater than 0 bytes
if [ -s "boot.img" ]; then
    echo -e "\n${greenbold} ✅ Extraction complete. boot.img is ready for Magisk.${normal}\n"
else
    echo -e "\n${redbold} ⛔ Error: Extraction failed. boot.img is missing or empty.${normal}\n"
    exit 114
fi
