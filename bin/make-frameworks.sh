#!/usr/bin/env bash
set -e
shopt -s nullglob globstar

parse_command_line()
{
  local append argument default_value help_text line required variable_name
  printf "# default values\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<<"${line}"

    if [ "${default_value}" != "-1" ]; then
      printf "%s=\"%s\"\n" "${variable_name}" "${default_value}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "\n# parse command line\n\npositional=()\n\n"
  printf "while [[ \$# -gt 0 ]]; do\n"
  printf "  key=\"\${1}\"\n\n"
  printf "  case \"\${key}\" in\n"
  printf "  --help)\n"
  printf "  echo \"Usage: \${0##*/} options\n"
  printf "\n    options\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<<"${line}"
    printf "            %s %s\n" "${argument}" "${help_text}"
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "\"\n    exit 0\n    ;;\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<<"${line}"

    if [ "${append}" == "1" ]; then
      printf "  %s)\n    %s=\"\${%s} %s \${2}\"\n    shift\n    shift\n    ;;\n\n" "${argument}" "${variable_name}" "${variable_name}" "${argument}"
    else
      printf "  %s)\n    %s=\"\${2}\"\n    shift\n    shift\n    ;;\n\n" "${argument}" "${variable_name}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')

  printf "  *)\n    positional+=(\"\${1}\")\n    shift\n    ;;\n  esac\ndone\n\nset -- \"\${positional[@]}\"\n\n"

  while read -r line; do
    IFS=, read -r argument variable_name default_value required append help_text <<<"${line}"

    if [ "${required}" == "1" ]; then
      printf "if [ -z \"\${%s}\" ]; then\n  echo \"Error: %s required !\"\n  exit 1\nfi\n\n" "${variable_name}" "${argument}"
    fi
  done < <(awk '/^#\[/,/^#\]/ { print }' <"${0}" | grep -v '\[' | grep -v '\]' | tr -d '#')
}

# parse command line

#[ argument,variable_name,default_value,required,append,help_text
# --bundle-identifier,bundle_identifier,,1,0,CFBundleIdentifier
# --bundle-name,bundle_name,,1,0,CFBundleName
# --bundle-version,bundle_version,,1,0,CFBundleVersion
# --input-dir,input_dir,,1,0,input directory
# --output-dir,output_dir,,1,0,output directory
#]

# shellcheck source=/dev/null
. <(parse_command_line)

# generate xcframework

# shellcheck disable=SC2154
pushd "${input_dir}"

for library in ./**/*-iphoneos.so ./**/*-iphoneos.dylib; do
  echo "Processing ${library}..."
  library_name="$(basename "${library%.cpython*}")"
  directory="$(dirname "${library/.\//}")"

  if [ "${directory}" = "." ]; then
    # shellcheck disable=SC2154
    folder_name="${bundle_name}-${library_name}.xcframework"
  else
    # shellcheck disable=SC2154
    folder_name="${bundle_name}-$(echo "${directory}" | tr '/' '-')-${library_name}.xcframework"
  fi

  if [ "${bundle_name}" == "python" ]; then
    folder_name="${folder_name/python-/}"
  fi

  rm -rf "${output_dir:?}/${folder_name}"
  mkdir -p "${output_dir}/${folder_name}/ios-arm64"
  library_file="${library/darwin/iphoneos}"
  cp "${library}" "${output_dir}/${folder_name}/ios-arm64/$(basename "${library_file}")"

  {
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
    echo '<plist version="1.0">'
    echo "<dict>"
    echo "	<key>CFBundlePackageType</key>"
    echo "	<string>XFWK</string>"
    echo "	<key>XCFrameworkFormatVersion</key>"
    echo "	<string>1.0</string>"
    echo "	<key>AvailableLibraries</key>"
    echo "	<array>"
    echo "		<dict>"
    echo "			<key>LibraryIdentifier</key>"
    echo "			<string>ios-arm64</string>"
    echo "			<key>LibraryPath</key>"
    echo "			<string>$(basename "${library_file}")</string>"
    echo "			<key>SupportedArchitectures</key>"
    echo "			<array>"
    echo "				<string>arm64</string>"
    echo "			</array>"
    echo "			<key>SupportedPlatform</key>"
    echo "			<string>ios</string>"
    echo "		</dict>"
  } >"${output_dir}/${folder_name}/Info.plist"

  if [ -f "${library/iphoneos/iphonesimulator}" ]; then
    mkdir -p "${output_dir}/${folder_name}/ios-arm64_x86_64-simulator"
    cp "${library/iphoneos/iphonesimulator}" "${output_dir}/${folder_name}/ios-arm64_x86_64-simulator/$(basename "${library_file/iphoneos/iphonesimulator}")"

    {
      echo "		<dict>"
      echo "        <key>LibraryIdentifier</key>"
      echo "        <string>ios-arm64_x86_64-simulator</string>"
      echo "        <key>LibraryPath</key>"
      echo "        <string>$(basename "${library_file/iphoneos/iphonesimulator}")</string>"
      echo "        <key>SupportedArchitectures</key>"
      echo "        <array>"
      echo "          <string>arm64</string>"
      echo "          <string>x86_64</string>"
      echo "        </array>"
      echo "        <key>SupportedPlatform</key>"
      echo "        <string>ios</string>"
      echo "        <key>SupportedPlatformVariant</key>"
      echo "        <string>simulator</string>"
      echo "      </dict>"
    } >>"${output_dir}/${folder_name}/Info.plist"
  fi

  {
    echo "	</array>"
    echo "</dict>"
    echo "</plist>"
  } >>"${output_dir}/${folder_name}/Info.plist"
done

popd

echo "${0##*/} completed successfully."
