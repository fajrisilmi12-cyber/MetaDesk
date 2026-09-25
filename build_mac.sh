#!/usr/bin/env bash
set -e

APP_NAME="MetaDesk"
VERSION="${1:-1.0.0}"  # single source of truth: injected via -X main.appVersion below
BINARY_NAME="MetaDesk"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building universal binary for macOS (arm64 + x86_64)..."
rm -f "${BINARY_NAME}_mac" "${BINARY_NAME}_arm64" "${BINARY_NAME}_amd64"
LIPO="/usr/bin/lipo"
if [ -x "$LIPO" ] && \
   CGO_ENABLED=1 GOARCH=arm64 CGO_CFLAGS="-arch arm64" CGO_LDFLAGS="-arch arm64" GOTOOLCHAIN=local go build -ldflags="-s -w -buildid= -X main.appVersion=${VERSION}" -trimpath -o "${BINARY_NAME}_arm64" . 2>/dev/null && \
   CGO_ENABLED=1 GOARCH=amd64 CGO_CFLAGS="-arch x86_64" CGO_LDFLAGS="-arch x86_64" GOTOOLCHAIN=local go build -ldflags="-s -w -buildid= -X main.appVersion=${VERSION}" -trimpath -o "${BINARY_NAME}_amd64" . 2>/dev/null; then
    "$LIPO" -create -output "${BINARY_NAME}_mac" "${BINARY_NAME}_arm64" "${BINARY_NAME}_amd64"
    rm -f "${BINARY_NAME}_arm64" "${BINARY_NAME}_amd64"
    echo "Successfully built universal binary (Apple Silicon + Intel)"
else
    echo "Falling back to native host architecture build..."
    GOTOOLCHAIN=local go build -ldflags="-s -w -buildid= -X main.appVersion=${VERSION}" -trimpath -o "${BINARY_NAME}_mac" .
fi

echo "Packaging ${BUNDLE_DIR}..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
fi

cp "${BINARY_NAME}_mac" "${MACOS_DIR}/${BINARY_NAME}"
chmod +x "${MACOS_DIR}/${BINARY_NAME}"

cat << EOF > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MetaDesk</string>
    <key>CFBundleIdentifier</key>
    <string>com.metadesk</string>
    <key>CFBundleName</key>
    <string>MetaDesk</string>
    <key>CFBundleDisplayName</key>
    <string>MetaDesk</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>NSCameraUsageDescription</key>
    <string>MetaDesk requires camera access for video calls.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>MetaDesk requires microphone access for voice and video calls.</string>
</dict>
</plist>
EOF

echo "Code signing ${BUNDLE_DIR} (ad-hoc, hardened runtime)..."
xattr -cr "${BUNDLE_DIR}" 2>/dev/null || true
if command -v codesign >/dev/null 2>&1; then
    if [ -f "MetaDesk.entitlements" ]; then
        codesign --force --deep -s - --options runtime --entitlements MetaDesk.entitlements "${BUNDLE_DIR}"
    else
        codesign --force --deep -s - --options runtime "${BUNDLE_DIR}"
    fi
    echo "Bundle successfully signed."
fi

if command -v hdiutil >/dev/null 2>&1; then
    echo "Creating DMG installer (MetaDesk-macOS-Universal.dmg)..."
    DMG_DIR="dmg_temp"
    rm -rf "${DMG_DIR}" "MetaDesk-macOS-Universal.dmg"
    mkdir -p "${DMG_DIR}"
    cp -R "${BUNDLE_DIR}" "${DMG_DIR}/"
    ln -s /Applications "${DMG_DIR}/Applications"
    if [ -f "dmg_background.png" ]; then
        mkdir -p "${DMG_DIR}/.background"
        cp "dmg_background.png" "${DMG_DIR}/.background/background.png"
    fi
    if hdiutil create -volname "MetaDesk" -srcfolder "${DMG_DIR}" -ov -format UDZO "MetaDesk-macOS-Universal.dmg" 2>/dev/null; then
        true  # (legacy WhatsApp-macOS compat copy removed)
        echo "Successfully created DMG installer."
    else
        echo "Notice: DMG creation skipped in sandbox environment. ZIP bundle will be created."
    fi
    rm -rf "${DMG_DIR}"
fi

echo "Creating ZIP bundle (MetaDesk-macOS-Universal.zip)..."
rm -f "MetaDesk-macOS-Universal.zip"
zip -r -y -q "MetaDesk-macOS-Universal.zip" "${BUNDLE_DIR}"
true  # (legacy compat copy removed)

echo "Done! Built ${BUNDLE_DIR} and ZIP bundle."
