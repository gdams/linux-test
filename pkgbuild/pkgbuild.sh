#!/bin/bash

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

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "options:"
      echo "-h, --help               show brief help"
      echo "--major_version          <8,9,10,11>"
      echo "--full_version           1.8.0_192>"
      echo "-i, --input_directory    path to extracted jdk>"
      echo "-o, --output_directory   name of the pkg file>"
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
    *)
      break
      ;;
  esac
done

rm -rf *.pkg distribution.xml Resources/en.lproj/welcome.html Resources/en.lproj/conclusion.html
mkdir -p "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries"
if [ -f "${INPUT_DIRECTORY}/Contents/Home/lib/server/libjvm.dylib" ]; then
  cp "${INPUT_DIRECTORY}/Contents/Home/lib/server/libjvm.dylib" "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries/libserver.dylib"
else
  cp "${INPUT_DIRECTORY}/Contents/Home/jre/lib/server/libjvm.dylib" "${INPUT_DIRECTORY}/Contents/Home/bundle/Libraries/libserver.dylib"
fi
# Detect if JRE or JDK
case $INPUT_DIRECTORY in
  *-jre)
    TYPE="jre"
    /usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities array" "${INPUT_DIRECTORY}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:0 string CommandLine" "${INPUT_DIRECTORY}/Contents/Info.plist"
    ;;
  *)
    TYPE="jdk"
    ;;
esac

IDENTIFIER="net.adoptopenjdk.${MAJOR_VERSION}.${TYPE}"
DIRECTORY="adoptopenjdk-${MAJOR_VERSION}.${TYPE}"
case $TYPE in
  jre) BUNDLE="AdoptOpenJDK (JRE)" ;;
  jdk) BUNDLE="AdoptOpenJDK" ;;
esac

/usr/libexec/PlistBuddy -c "Set :CFBundleGetInfoString ${BUNDLE} ${FULL_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${BUNDLE} ${MAJOR_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${IDENTIFIER}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMPlatformVersion ${FULL_VERSION}" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMVendor AdoptOpenJDK" "${INPUT_DIRECTORY}/Contents/Info.plist"

# Fix comes from https://apple.stackexchange.com/a/211033 to associate JAR files
/usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:1 string JNI" "${INPUT_DIRECTORY}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :JavaVM:JVMCapabilities:2 string BundledApp" "${INPUT_DIRECTORY}/Contents/Info.plist"

cat distribution.xml.tmpl  \
  | sed -E "s/\\{identifier\\}/$IDENTIFIER/g" \
  | sed -E "s/\\{full_version\\}/$FULL_VERSION/g" \
  | sed -E "s/\\{file\\}/OpenJDK.pkg/g" \
  >distribution.xml ; \

  cat Resources/en.lproj/welcome.html.tmpl  \
  | sed -E "s/\\{full_version\\}/$FULL_VERSION/g" \
  | sed -E "s/\\{directory\\}/$DIRECTORY/g" \
  >Resources/en.lproj/welcome.html ; \

  cat Resources/en.lproj/conclusion.html.tmpl  \
  | sed -E "s/\\{full_version\\}/$FULL_VERSION/g" \
  | sed -E "s/\\{directory\\}/$DIRECTORY/g" \
  >Resources/en.lproj/conclusion.html ; \

  xattr -cr .

/usr/bin/pkgbuild --root ${INPUT_DIRECTORY} --install-location /Library/Java/JavaVirtualMachines/${DIRECTORY} --identifier ${IDENTIFIER} --version ${FULL_VERSION} OpenJDK.pkg
/usr/bin/productbuild --distribution distribution.xml --resources Resources --package-path OpenJDK.pkg ${OUTPUT_DIRECTORY}

rm -rf OpenJDK.pkg
