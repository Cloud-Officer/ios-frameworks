#!/usr/bin/env bash
set -e
shopt -s nullglob globstar

# shellcheck source=/dev/null
. "${BASE_DIR}/scripts/environment.sh"

# parse command line

#[ argument,variable_name,default_value,required,append,help_text
# --bundle-identifier,bundle_identifier,,1,0,CFBundleIdentifier
# --bundle-name,bundle_name,,1,0,CFBundleName
# --bundle-version,bundle_version,,1,0,CFBundleVersion
# --input-dir,input_dir,,1,0,input directory
# --output-dir,output_dir,,1,0,output directory
#]

. <(parse_command_line)

# generate xcframework

pushd "${input_dir}"

bundle_version="${bundle_version/v/}"

for library in ./**/*.so; do
  library_name="$(basename "${library%.cpython*}")"
  directory="$(dirname "${library/.\//}")"

  if [ "${directory}" = "." ]; then
    folder_name="${bundle_name}-${library_name}.framework"
    prefix_package="${bundle_name}"
  else
    folder_name="${bundle_name}-$(echo "${directory}" | tr '/' '-')-${library_name}.framework"
    prefix_package="${bundle_name}.$(echo "${directory}" | tr -d '/')"
  fi

  rm -rf "${output_dir:?}/${folder_name}"
  mkdir -p "${output_dir}/${folder_name}"
  cp "${library}" "${output_dir}/${folder_name}/$(basename "${library/darwin/iphoneos}")"

  {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
    echo "<plist version=\"1.0\">"
    echo "<dict>"
    echo "    <key>CFBundlePackageType</key>"
    echo "    <string>FMWK</string>"
    echo "    <key>CFBundleInfoDictionaryVersion</key>"
    echo "    <string>6.0</string>"
    echo "    <key>CFBundleDevelopmentRegion</key>"
    echo "    <string>en</string>"
    echo "    <key>CFBundleSupportedPlatforms</key>"
    echo "    <array>"
    echo "        <string>iPhoneOS</string>"
    echo "    </array>"
    echo "    <key>MinimumOSVersion</key>"
    echo "    <string>12.0</string>"
    echo "    <key>CFBundleIdentifier</key>"
    echo "    <string>${bundle_identifier//_/}.${prefix_package//_/}${library_name//_/}</string>"
    echo "    <key>CFBundleName</key>"
    echo "    <string>${prefix_package/./}${library_name}</string>"
    echo "    <key>CFBundleVersion</key>"
    echo "    <string>${bundle_version}</string>"
    echo "    <key>CFBundleShortVersionString</key>"
    echo "    <string>${bundle_version%.*}</string>"
    echo "    <key>CFBundleExecutable</key>"
    echo "    <string>$(basename "${library/darwin/iphoneos}")</string>"
    echo "</dict>"
    echo "</plist>"
  } >"${output_dir}/${folder_name}/Info.plist"
done

popd

echo "${0##*/} completed successfully."
