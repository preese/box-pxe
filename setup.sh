#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(pwd)"
OUT_DIR="$SRC_DIR/pxe-box"

ISO="OS.iso"
KS="OS.ks"

echo "======================================"
echo "      PXE COMPILER v2 (GENERIC)"
echo "======================================"

# -------------------------------------------------
# 1. Validate inputs
# -------------------------------------------------
echo "[1/6] Validating inputs..."

for f in "$ISO" "$KS" "ipxe.efi" "autoexec.ipxe" "logic.ipxe"; do
    if [[ ! -f "$SRC_DIR/$f" ]]; then
        echo "ERROR: Missing required file: $f"
        exit 1
    fi
done

echo "✔ Inputs validated"

# -------------------------------------------------
# 2. Reset build directory
# -------------------------------------------------
echo "[2/6] Creating PXE box layout..."

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/tftp"
mkdir -p "$OUT_DIR/www"

echo "✔ Clean directory created"

# -------------------------------------------------
# 3. Copy bootloader components (TFTP)
# -------------------------------------------------
echo "[3/6] Staging TFTP components..."

cp "$SRC_DIR/ipxe.efi" "$OUT_DIR/tftp/"

# autoexec is static (no generation)
cp "$SRC_DIR/autoexec.ipxe" "$OUT_DIR/tftp/"

echo "✔ TFTP layer ready"

# -------------------------------------------------
# 4. Copy OS KS
# -------------------------------------------------
echo "[4/6] Copying Kickstart..."

cp "$SRC_DIR/$KS" "$OUT_DIR/www/"

cp "$SRC_DIR/logic.ipxe" "$OUT_DIR/www/"

echo "✔ Kickstart staged"

# -------------------------------------------------
# 5. Mount ISO and mirror FULL contents
# -------------------------------------------------
echo "[5/6] Mirroring ISO into HTTP root..."

MNT=$(mktemp -d)

mount -o loop "$SRC_DIR/$ISO" "$MNT"

mkdir -p "$OUT_DIR/www/os"

rsync -aH  "$MNT/." "$OUT_DIR/www/os/"

umount "$MNT"
rmdir "$MNT"

echo "✔ Full ISO mirrored into /www/os"

# -------------------------------------------------
# 6. Fix permissions + SELinux safety
# -------------------------------------------------
echo "[6/6] Fixing permissions..."

chmod -R a+rX "$OUT_DIR/www"
chmod -R a+rX "$OUT_DIR/tftp"

if command -v restorecon >/dev/null 2>&1; then
    echo "Applying SELinux context (if enabled)..."
    restorecon -Rv "$OUT_DIR/www" "$OUT_DIR/tftp" || true
fi

echo "✔ Permissions normalized"

# -------------------------------------------------
# DONE
# -------------------------------------------------
echo ""
echo "======================================"
echo " PXE COMPILER v2 COMPLETE"
echo "======================================"
echo "Output:"
echo "  $OUT_DIR"
echo ""
echo "HTTP layout:"
echo "  /os        → full ISO mirror"
echo "  /OS.ks     → kickstart"
echo ""
echo "TFTP:"
echo "  ipxe.efi"
echo "  autoexec.ipxe"
echo "  logic.ipxe"
echo "======================================"
