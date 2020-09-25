#!/usr/bin/env bash

################################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

set -eu

IDENTIFIER=
VENDOR="adoptopenjdk"
PACKAGE_NAME="AdoptOpenJDK"
LOGO="Resources/adoptopenjdk.png"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "options:"
      echo "-h, --help               show brief help"
      echo "--major_version          <8,9,10,11>"
      echo "--full_version           1.8.0_192>"
      echo "-i, --input_directory    path to extracted jdk>"
      echo "-o, --output_directory   name of the pkg file>"
      echo "--jvm                    hotspot or openj9"
      echo "--type                   jdk or jre"
      echo "--vendor                 adoptopenjdk, dragonwell etc"
      echo "--package-name           full name of the package (shown in the title)"
      echo "--logo                   Relative path to a custom logo (bottom left)"
      echo "--identifier             override the identifier e.g net.adoptopenjdk.11.jdk"
      exit 0
      ;;
    --major_version)
      shift
      MAJOR_VERSION=$1
      shift
      ;;
    --full_version)
      shift
      FULL_VERSION=$1
      shift
      ;;
    -i|--input_directory)
      shift
      INPUT_DIRECTORY=$1
      shift
      ;;
    -o|--output_directory)
      shift
      OUTPUT_DIRECTORY=$1
      shift
      ;;
    --jvm)
      shift
      JVM=$1
      shift
      ;;
    --type)
      shift
      TYPE=$1
      shift
      ;;
    --vendor)
      shift
      VENDOR="$1"
      shift
      ;;
    --package-name)
      shift
      PACKAGE_NAME="$1"
      shift
      ;;
    --logo)
      shift
      LOGO="$1"
      shift
      ;;
    --identifier)
      shift
      IDENTIFIER="$1"
      shift
      ;;
    *)
      break
      ;;
  esac
done

mkdir -p "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries"
if [ -f "${INPUT_DIRECTORY}/Contents/Home/lib/server/libjvm.dylib" ]; then
  cp "${INPUT_DIRECTORY}/Contents/Home/lib/server/libjvm.dylib" "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries/libserver.dylib"
else
  cp "${INPUT_DIRECTORY}/Contents/Home/jre/lib/server/libjvm.dylib" "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries/libserver.dylib"
fi

if [ $TYPE == "jre" ]; then
    /usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities array" "${INPUT_DIRECTORY}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:0 string CommandLine" "${INPUT_DIRECTORY}/Contents/Info.plist"
fi

if [ -z "$IDENTIFIER" ]; then
  IDENTIFIER="net.${VENDOR}.${MAJOR_VERSION}.${TYPE}"
fi
DIRECTORY="${VENDOR}-${MAJOR_VERSION}.${TYPE}"
cp Licenses/license-GPLv2+CE.en-us.rtf Resources/license.rtf
case $TYPE in
  jre) BUNDLE="${PACKAGE_NAME} (JRE)" ;;
  jdk) BUNDLE="${PACKAGE_NAME}" ;;
esac

/usr/libexec/PlistBuddy -c "Set :CFBundleGetInfoString ${BUNDLE} ${FULL_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${BUNDLE} ${MAJOR_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${IDENTIFIER}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMPlatformVersion ${FULL_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMVendor ${PACKAGE_NAME}" "${INPUT_DIRECTORY}/Contents/Info.plist"

# Fix comes from https://apple.stackexchange.com/a/211033 to associate JAR files
/usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:1 string JNI" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:2 string BundledApp" "${INPUT_DIRECTORY}/Contents/Info.plist"

OUTPUT_FILE=$(basename "$OUTPUT_DIRECTORY" | cut -f 1 -d '.')

rm -rf *.pkg build/*.pkg distribution.xml Resources/en.lproj/welcome.html Resources/en.lproj/conclusion.html OpenJDKPKG.pkgproj "${DIRECTORY}"

cp -R "${INPUT_DIRECTORY}" "${DIRECTORY}"

cat OpenJDKPKG.pkgproj.template  \
  | sed -E "s~\\{path\\}~$DIRECTORY~g" \
  | sed -E "s~\\{output\\}~$OUTPUT_FILE~g" \
  | sed -E "s~\\{identifier\\}~$IDENTIFIER~g" \
  | sed -E "s~\\{package-name\\}~$PACKAGE_NAME~g" \
  | sed -E "s~\\{directory\\}~$DIRECTORY~g" \
  | sed -E "s~\\{logo\\}~$LOGO~g" \
  >OpenJDKPKG.pkgproj ; \
  
  cat Resources/en.lproj/welcome.html.tmpl  \
  | sed -E "s/\\{full_version\\}/$FULL_VERSION/g" \
  | sed -E "s/\\{directory\\}/$DIRECTORY/g" \
  | sed -E "s~\\{package-name\\}~$PACKAGE_NAME~g" \
  >Resources/introduction.html ; \

  cat Resources/en.lproj/conclusion.html.tmpl  \
  | sed -E "s/\\{full_version\\}/$FULL_VERSION/g" \
  | sed -E "s/\\{directory\\}/$DIRECTORY/g" \
  | sed -E "s~\\{package-name\\}~$PACKAGE_NAME~g" \
  >Resources/summary.html ; \

/usr/local/bin/packagesbuild -v OpenJDKPKG.pkgproj

mv build/"$OUTPUT_FILE.pkg" "$OUTPUT_DIRECTORY"
