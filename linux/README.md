# Packaging AdoptOpenJDK for Linux

## Prerequisites

Note: Linux packages can be created on any Linux distribution and macOS and on any CPU architecture. The package manager which the packages are going to be built for is not required to be present.

### Linux

* [fpm](https://fpm.readthedocs.io/en/latest/installing.html)
* JDK 11 or newer
* Ruby
* RubyGems
* rpmbuild

### macOS

* [fpm](https://fpm.readthedocs.io/en/latest/installing.html)
* JDK 11 or newer
* Ruby
* RubyGems
* gnutar
* rpmbuild

## Packaging

It is possible to simultaneously build Debian and RPM packages by using `./gradlew build` and specifying all properties (`-P`) that are required by the various package formats.

### Deb packages

Deb packages for Debian and Ubuntu (see section *Support Matrix* below for supported combinations) can be packaged with the help of Gradle and fpm:

```
./gradlew buildDebPackage \
    -PJDK_DISTRIBUTION_TYPE=<JDK|JRE> \
    -PJDK_DISTRIBUTION_DIR=/path/to/jdk \
    -PJDK_MAJOR_VERSION=<majorversion> \
    -PJDK_VERSION=<versionstring> \
    -PJDK_VM=<vm> \
    -PJDK_ARCHITECTURE=<architecture>
```

`JDK_DISTRIBUTION_DIR` must point to a directory with a binary distribution of AdoptOpenJDK (for example an expanded tarball downloaded from https://adoptopenjdk.net/). Use a JDK distribution to create a JDK package, use a JRE distribution to create a JRE package.

Example:

```
./gradlew buildDebPackage \
    -PJDK_DISTRIBUTION_TYPE=JDK \
    -PJDK_DISTRIBUTION_DIR=/path/to/jdk-11.0.2+9 \
    -PJDK_MAJOR_VERSION=11 \
    -PJDK_VERSION="11.0.2+9" \
    -PJDK_VM=hotspot \
    -PJDK_ARCHITECTURE=x64
```

#### Optional Arguments

* `-PPACKAGE_NAME=pkg_name` - Specify the name of the output package, defaults to `adoptopenjdk`
* `-PVENDOR=vendor_name` - Specify a custom vendor name, defaults to `AdoptOpenJDK`
* `-PVENDOR_HOMEPAGE="https://example.com/"` - specify a custom link to vendor homepage
* `-PVENDOR_SOURCE_URL="https://example.com/"` - specify a custom link to source code
* `-PDEBIAN_ITERATION=1` - specify the iteration

3rd party vendors can choose to populate the above optional arguments to customize package metadata. Please note that vendor name should be included in the JDK_VERSION.

Example:

```bash
./gradlew buildDebPackage \
    -PJDK_DISTRIBUTION_TYPE=JDK \
    -PPACKAGE_NAME=openjdk \
    -PVENDOR=Vendor \
    -PVENDOR_HOMEPAGE="https://homepage.com" \
    -PJDK_DISTRIBUTION_DIR=path-to/jdk-11.0.8+2 \
    -PJDK_MAJOR_VERSION=11 \
    -PJDK_VERSION=11.0.8+2~vendor \
    -PJDK_VM=hotspot \
    -PJDK_ARCHITECTURE=x64 \
    -PDEBIAN_ITERATION=5
```

will produce `openjdk-11-hotspot_11.0.8+2~vendor-5_amd64.deb` with the following metadata:

```
 new Debian package, version 2.0.
 Package: openjdk-11-hotspot
 Version: 11.0.8+2~vendor-5
 Vendor: Vendor
 Maintainer: Vendor
 Homepage: https://homepage.com
 Description: OpenJDK Development Kit 11 (JDK) with Hotspot by Vendor
 ...

```

Table with arguments:

|        | JDK\_MAJOR\_VERSION | JDK\_VERSION     | JDK\_VM                          | JDK\_ARCHITECTURE                           |
|--------|---------------------|------------------|----------------------------------|---------------------------------------------|
| JDK 8  | 8                   | e.g. `8u202`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 9  | 9                   | e.g. `9.0.4+11`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 10 | 10                  | e.g. `10.0.2+13` | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 11 | 11                  | e.g. `11.0.2+9`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 12 | 12                  | e.g. `12.0.1+12` | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 13 | 13                  | e.g. `13.0.1+9`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 14 | 14                  | e.g. `14+15`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 15 | 15                  | e.g. `15+10`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 16 | 16                  | e.g. `16+4`      | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |

### RPM packages

RPM packages for CentOS, Fedora, Red Hat Enterprise Linux (RHEL) as well as OpenSUSE and SUSE Enterprise Linux (SLES) (see section *Support Matrix* below for supported combinations) can be packaged with the help of Gradle and fpm:

```
./gradlew buildRpmPackage \
    -PJDK_DISTRIBUTION_TYPE=<JDK|JRE> \
    -PJDK_DISTRIBUTION_DIR=/path/to/jdk \
    -PJDK_MAJOR_VERSION=<majorversion> \
    -PJDK_VERSION=<versionstring> \
    -PJDK_VM=<vm> \
    -PJDK_ARCHITECTURE=<architecture> \
    -PSIGN_PACKAGE=<true|false>
```

`JDK_DISTRIBUTION_DIR` must point to a directory with a binary distribution of AdoptOpenJDK (for example an expanded tarball downloaded from https://adoptopenjdk.net/). Use a JDK distribution to create a JDK package, use a JRE distribution to create a JRE package.

Example:

```
./gradlew buildRpmPackage \
    -PJDK_DISTRIBUTION_TYPE=JRE \
    -PJDK_DISTRIBUTION_DIR=/path/to/jdk-11.0.2+9 \
    -PJDK_MAJOR_VERSION=11 \
    -PJDK_VERSION="11.0.2+9" \
    -PJDK_VM=hotspot \
    -PJDK_ARCHITECTURE=amd64
    -PSIGN_PACKAGE=true
```

|        | JDK\_MAJOR\_VERSION | JDK\_VERSION     | JDK\_VM                          | JDK\_ARCHITECTURE                           |
|--------|---------------------|------------------|----------------------------------|---------------------------------------------|
| JDK 8  | 8                   | e.g. `8u202`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 9  | 9                   | e.g. `9.0.4+11`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 10 | 10                  | e.g. `10.0.2+13` | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 11 | 11                  | e.g. `11.0.2+9`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 12 | 12                  | e.g. `12.0.1+12` | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 13 | 13                  | e.g. `13.0.1+9`  | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 14 | 14                  | e.g. `14+15`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 15 | 15                  | e.g. `15+10`     | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |
| JDK 16 | 16                  | e.g. `16+4`      | `hotspot`, `openj9`, `openj9_xl` | `x64`, `s390x`, `ppc64le`, `arm`, `aarch64` |

RPMs are automatically signed if `SIGN_PACKAGE` is set to `true`. Signing requires the file  `~/.rpmmacros` to be present with the following signing configuration (change values as necessary):

```
%_signature gpg
%_gpg_path /path/to/.gnupg
%_gpg_name KEY_ID
%__gpg /usr/bin/gpg
```

## Upload to Package Repositories

Gradle tasks are included to upload Debian and RPM packages to Artifactory. To upload all package formats, run:

```
./gradlew upload \
    -PJDK_MAJOR_VERSION=<majorversion> \
    -PJDK_VERSION=<versionstring> \
    -PJDK_ARCHITECTURE=<architecture> \
    -PARTIFACTORY_USER=<user> \
    -PARTIFACTORY_PASSWORD=<apikey> \
    -PARTIFACTORY_REPOSITORY_DEB=<name-of-debian-repository> \
    -PARTIFACTORY_REPOSITORY_RPM=<name-of-rpm-repository>
```

By specifying all build properties (see above) building and uploading can be done at once. The `upload` tasks depends on the respective `build` tasks. Run `./gradlew tasks` for a full list of tasks.

**Attention**: When setting up an Artifactory repository for RPM packages, the *YUM metadata folder depth* must be set to 3.

## Support Matrix

### Deb packages

All packages can be installed on Debian, Raspbian (armhf/arm64 only) and Ubuntu without further changes. They are available for amd64, s390x, ppc64el, armhf and arm64 unless otherwise noted. All major versions as well as JDKs and JREs can be installed side by side. JDKs and JREs have no dependencies on each other and are completely self-contained.

| OpenJDK                  | Debian                               | Ubuntu                                                                      |
|--------------------------|--------------------------------------|-----------------------------------------------------------------------------|
| JDK 8 (Hotspot, OpenJ9)  | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 9 (Hotspot, OpenJ9)  | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 10 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 11 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 12 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 13 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 14 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 15 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |
| JDK 16 (Hotspot, OpenJ9) | 8 (jessie), 9 (stretch), 10 (buster) | 16.04 (xenial), 18.04 (bionic), 19.10 (eoan), 20.04 (focal), 20.10 (groovy) |

* [Debian releases and support timeframe](https://wiki.debian.org/DebianReleases)
* [Ubuntu releases and support timeframe](https://wiki.ubuntu.com/Releases)

### RPM packages

All packages can be installed on Amazon Linux, CentOS, Fedora, Red Hat Enterprise Linux (RHEL) as well as OpenSUSE and SUSE Enterprise Linux (SLES) without further changes. All major versions as well as JDKs and JREs can be installed side by side. JDKs and JREs have no dependencies on each other and are completely self-contained. Packages for Amazon Linux 1, Fedora and OpenSUSE are only available for x86_64. Amazon Linux 2 supports aarch64, too. The packages for all other distributions are available for x86_64, s390x, ppc64le and aarch64.

| OpenJDK                  | Amazon  | CentOS  | Fedora     | RHEL    | OpenSUSE   | SLES   |
|--------------------------|---------|---------|------------|---------|------------|--------|
| JDK 8 (Hotspot, OpenJ9)  | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 9 (Hotspot, OpenJ9)  | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 10 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 11 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 12 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 13 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 14 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 15 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |
| JDK 16 (Hotspot, OpenJ9) | 1, 2    | 6, 7, 8 | 31, 32, 33 | 6, 7, 8 | 15.1, 15.2 | 12, 15 |

* Amazon Linux releases and support timeframe: [Amazon Linux 1](https://aws.amazon.com/de/amazon-linux-ami/faqs/#how_long), [Amazon Linux 2](https://aws.amazon.com/de/amazon-linux-2/faqs/#Long_Term_Support)
* [CentOS releases and support timeframe](https://wiki.centos.org/Download)
* [Fedora releases and support timeframe](https://fedoraproject.org/wiki/Releases)
* [Red Hat Enterprise Linux releases and support timeframe](https://access.redhat.com/support/policy/updates/errata/)
* [OpenSUSE releases and support timeframe](https://en.opensuse.org/Lifetime)
* [Suse Linux Enterprise releases and support timeframe](https://www.suse.com/lifecycle/)
