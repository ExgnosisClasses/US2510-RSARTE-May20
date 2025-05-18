#!/bin/bash

version=1.8
: ' CHANGE LOG
1.8
Support product version 12.1 based on Eclipse 2024-06

1.7
Added support for arm64 MacOS architecture

1.6
Updated for the new product name model-realtime
Added new replacement @COMPANY@ for the install folder name

1.5
Added support for MacOS platform

1.4
Added support for version 12.0 based on Eclipse 2023-06
'

######################## Install settings (TO BE UPDATED) #############################################
# Full path to folder with downloads for eclipse and product zips
DOWNLOADS=$RT_DOWNLOADS

# Full path to top folder with installation
INSTALL_BASE=$RT_INSTALL_BASE

# Full path pattern to installation location
INSTALL=$RT_INSTALL

# Full path to Java 8 binary (optional, if Java 8 is not needed)
# for example,
# /c/_Install/OpenJDK/jdk-8.0.272.10-hotspot/jre/bin
# /usr/lib/jvm/jre-1.8.0-openjdk/bin
JAVA8_BIN=$RT_JAVA8_BIN

# Full path to Java 11 binary (optional, if Java 11 is not needed)
# for example,
# /c/_Install/OpenJDK/jdk-11.0.9.1-hotspot/bin
# /usr/lib/jvm/jre-11-openjdk/bin
JAVA11_BIN=$RT_JAVA11_BIN

JAVA17_BIN=$RT_JAVA17_BIN

JAVA21_BIN=$RT_JAVA21_BIN

# Set START_AFTER_INSTALL to some value if the product should be started immediately after installation
START_AFTER_INSTALL=$RT_START_AFTER_INSTALL

# Java version to be used for running the 11.1 version of the tool
# 'Java 8' or 'Java 11'
# Used only for starting the tool from this script immediately after installation
# If START_AFTER_INSTALL is not set, JAVA_FOR_11_1 is not used and can be ignored
JAVA_FOR_11_1=$RT_JAVA_FOR_11_1

# Full path to the folder where workspace for running the tool after installation will be created
# If START_AFTER_INSTALL is not set, RT_TEST is not used and can be ignored
TESTS=$RT_TEST
#######################################################################################################

declare -A eclipseZipFiles
declare -A javaDownloads
openJdkDownload="https://builds.openlogic.com/downloadJDK/openlogic-openjdk"
eclipseAdoptiumTemurin17="https://github.com/adoptium/temurin17-binaries/releases/download"
DEFAULT_INSTALL=@PRODUCT@_@VERSION@_@RELEASE@
if [[ $OS =~ Windows ]]
then
  isWindows=yes
  eclipseZipFiles["10.2"]="eclipse-cpp-oxygen-3a-win32-x86_64.zip"
  eclipseZipFiles["10.3"]="eclipse-cpp-photon-R-win32-x86_64.zip"
  eclipseZipFiles["11.0"]="eclipse-cpp-2019-06-R-win32-x86_64.zip"
  eclipseZipFiles["11.1"]="eclipse-cpp-2020-06-R-win32-x86_64.zip"
  eclipseZipFiles["11.2"]="eclipse-cpp-2021-06-R-win32-x86_64.zip"
  eclipseZipFiles["11.3"]="eclipse-cpp-2022-06-R-win32-x86_64.zip"
  eclipseZipFiles["12.0"]="eclipse-cpp-2023-06-R-win32-x86_64.zip"
  eclipseZipFiles["12.1"]="eclipse-cpp-2024-06-R-win32-x86_64.zip"
  javaDownloads["8"]="$openJdkDownload/8u282-b08/openlogic-openjdk-8u282-b08-windows-x64.zip"
  javaDownloads["11"]="$openJdkDownload/11.0.11%2B9/openlogic-openjdk-11.0.11%2B9-windows-x64.zip"  # 11.0.11+9 JDK
  javaDownloads["17"]="$eclipseAdoptiumTemurin17/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_x64_windows_hotspot_17.0.4.1_1.zip"  # jdk-17.0.4.1+1
  javaDownloads["21"]="$openJdkDownload/21.0.3+9/openlogic-openjdk-21.0.3+9-windows-x64.zip"  # 21.0.3+9 JDK
  javaExe="java.exe"
  eclipseExe="eclipse.exe"
elif [[ "$(uname)" =~ Linux ]]
then
  isLinux=yes
  eclipseZipFiles["10.2"]="eclipse-cpp-oxygen-3a-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["10.3"]="eclipse-cpp-photon-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["11.0"]="eclipse-cpp-2019-06-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["11.1"]="eclipse-cpp-2020-06-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["11.2"]="eclipse-cpp-2021-06-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["11.3"]="eclipse-cpp-2022-06-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["12.0"]="eclipse-cpp-2023-06-R-linux-gtk-x86_64.tar.gz"
  eclipseZipFiles["12.1"]="eclipse-cpp-2024-06-R-linux-gtk-x86_64.tar.gz"
  javaDownloads["8"]="$openJdkDownload/8u282-b08/openlogic-openjdk-8u282-b08-linux-x64.tar.gz"
  javaDownloads["11"]="$openJdkDownload/11.0.11%2B9/openlogic-openjdk-11.0.11%2B9-linux-x64.tar.gz"  # 11.0.11+9 JDK
  javaDownloads["17"]="$eclipseAdoptiumTemurin17/jdk-17.0.4.1%2B1/OpenJDK17U-jdk_x64_linux_hotspot_17.0.4.1_1.tar.gz"  # jdk-17.0.4.1+1
  javaDownloads["21"]="$openJdkDownload/21.0.3+9/openlogic-openjdk-21.0.3+9-linux-x64.tar.gz"  # 21.0.3+9 JDK
  javaExe="java"
  eclipseExe="eclipse"
elif [[ "$(uname)" =~ Darwin ]] # MacOS
then
  isMacOS=yes
  [[ "$(uname -a)" =~ _ARM64_ ]] && arch=aarch64 || arch=x86_64
  eclipseZipFiles["11.3"]="eclipse-cpp-2022-06-R-macosx-cocoa-$arch.dmg"
  eclipseZipFiles["12.0"]="eclipse-cpp-2023-06-R-macosx-cocoa-$arch.dmg"
  eclipseZipFiles["12.1"]="eclipse-cpp-2024-06-R-macosx-cocoa-$arch.dmg"
  javaExe="java"
  eclipseExe=Contents/MacOS/eclipse
  DEFAULT_INSTALL=$DEFAULT_INSTALL.app
fi

declare -A javas4Installing
javas4Installing["10.2"]="Java 8"
javas4Installing["10.3"]="Java 8"
javas4Installing["11.0"]="Java 8"
javas4Installing["11.1"]="Java 11"
javas4Installing["11.2"]="Java 11"
javas4Installing["11.3"]="Java 17"
javas4Installing["12.0"]="Java 17"
javas4Installing["12.1"]="Java 21"

[ -z "$JAVA_FOR_11_1" ] && JAVA_FOR_11_1="Java 8"
declare -A javas4Running
javas4Running["10.2"]="Java 8"
javas4Running["10.3"]="Java 8"
javas4Running["11.0"]="Java 8"
javas4Running["11.1"]="$JAVA_FOR_11_1"
javas4Running["11.2"]="Java 11"
javas4Running["11.3"]="Java 17"
javas4Running["12.0"]="Java 17"
javas4Running["12.1"]="Java 21"

declare -A javaBins
javaBins["Java 8"]=$JAVA8_BIN
javaBins["Java 11"]=$JAVA11_BIN
javaBins["Java 17"]=$JAVA17_BIN
javaBins["Java 21"]=$JAVA21_BIN


# Utils

  ERROR='\e[1;31m' # Red
  GREEN='\e[0;32m' # Light Green
WARNING='\e[0;33m' # Yellow/Orange
HEADING='\e[1m'    # Bold text
   INFO='\e[1;35m' # Purple
     NC='\e[0m'    # No Color

function timestamp {
  date -u +'%Y.%m.%d %H:%M:%S'
}

function log {
  echo -e "[$(timestamp)] $1"
}

function err {
  log "${ERROR}ERROR: $1${NC}"
}

function warn {
  log "${WARNING}WARNING: $1${NC}"
}

function heading {
  log "${HEADING}$1${NC}"
}

function extract {
  archive=$1
  targetLocation=$2

  heading "Extracting $archive ..."
  log "into $targetLocation"
  if [[ $archive =~ (.*)\.zip ]]
  then
    tempFolder=$(mktemp -d)
    unzip -qo -d $tempFolder $archive
    [ $? -ne 0 ] && err "unzip -qo -d $tempFolder $archive  FAILED" && exit 1
	numTops=$(ls -Al $tempFolder | grep -c ^d)
	if [ $numTops -eq 1 ]
	then
	  topFolder=$(ls -A $tempFolder)
      mv $tempFolder/$topFolder $targetLocation
      [ $? -ne 0 ] && err "mv $tempFolder/$topFolder $targetLocation  FAILED" && exit 1
	else
      mv $tempFolder $targetLocation
      [ $? -ne 0 ] && err "mv $tempFolder $targetLocation  FAILED" && exit 1
	fi
    rm -rf $tempFolder
  elif [[ $archive =~ (.*)\.tar ]] || [[ $archive =~ (.*)\.tar\.gz ]]
  then
    mkdir $targetLocation
    [ $? -ne 0 ] && err "mkdir $targetLocation  FAILED" && exit 1
    tar -xf $archive -C $targetLocation --strip-components=1
  elif [[ $archive =~ (.*)\.dmg ]]
  then
    attachPath="${BASH_REMATCH[1]}"
    [ -d "$attachPath" ] || hdiutil attach "$archive" -mountpoint "$attachPath" -readonly
    if [ -d "$attachPath"/*.app/Contents/ ]
    then
      mkdir $targetLocation
      cp -r "$attachPath"/*.app/* $targetLocation
    else
      err ".app/Contents/ is not available under $attachPath"
      exit 1
    fi
    hdiutil detach "$attachPath"
  else
    err "Unsupported extension in $archive"
    exit 1
  fi
}

function toBashPath {
  echo "$1" | sed 's/\\/\//g' | sed 's/^\(.\):/\/\l\1/'
}


# Usage, check options and settings

echo -e "${HEADING}\nCommand line Product Installer version $version${NC}"
if [ $# == 0 ] || [ "$1" == --help ] || [ "$1" == "-h" ]
then
  printf "Usage: $(basename $0) <Path_to_zip_file_with_product_installation> [ <Installation_location> ]\n"
  exit 0  
fi

[ -z $DOWNLOADS ] && DOWNLOADS=$HOME/Downloads &&
  warn "Using default location for downloads: $DOWNLOADS"
[ -z $INSTALL_BASE ] && INSTALL_BASE=$HOME/Install &&
  warn "Using default location for installation base folder: $INSTALL_BASE"
if [ -z "$2" ]
then
  [ -z $INSTALL ] && INSTALL=$INSTALL_BASE/$DEFAULT_INSTALL &&
    warn "Using default location for installation: $INSTALL"
else
  INSTALL=$2
fi
[ -z $TESTS ] && [ ! -z $START_AFTER_INSTALL ] && TESTS=$HOME &&
  warn "Using default location for test workspaces: $TESTS"


installId=$(date +%y%m%d_%H%M%S)
installZip=$(basename $1)

# for example, ibm-model-realtime-12.0.0-v20231121_1310_product.zip
if [[ $installZip =~ (hcl|ibm)-model-realtime-([0-9]+)\.([0-9]+)\.([0-9]+)-v?([0-9_]+)(_product)?\.zip ]]
then
  product=modelrt
  company=${BASH_REMATCH[1]}
  major_middle=${BASH_REMATCH[2]}.${BASH_REMATCH[3]}
  minor=${BASH_REMATCH[4]}
  version=$major_middle
  release=$minor
  buildNumber=${BASH_REMATCH[5]}

# for example, rsart-11.0-2020.50_v20201201_1120_product.zip
# for ifixes:  rtist-11.1-2021.46-ifix1_v20211212_1251_product.zip
# for core:    rsart-core-11.2-eclipse-2022-06_v20220721_1130_product.zip
elif [[ $installZip =~ ((rsart|rtist)(-core)?)-([0-9.]+)-((eclipse-)?20[1-9][0-9][.-][0-9][0-9](-ifix0?.)?)_v([0-9_]+)(_product)?\.zip ]]
then
  product=${BASH_REMATCH[2]}
  if [ $product == rtist ]; then company=hcl; else company=ibm; fi
  version=${BASH_REMATCH[4]}
  release=${BASH_REMATCH[5]}
  buildNumber=${BASH_REMATCH[8]}

# for example, rsart-11.0-sprint_v20201206_2305_145.zip
# for 11.2:    rsart-11.2-custom_v20220218_1009_34.zip
elif [[ $installZip =~ (rsart|rtist)-(.+)-(sprint|custom)_v(.+)\.zip ]]
then
  product=${BASH_REMATCH[1]}
  if [ $product == rtist ]; then company=hcl; else company=ibm; fi
  version=${BASH_REMATCH[2]}
  release=custom
  buildNumber=${BASH_REMATCH[4]}

else
  err "The format of zip file name $installZip is not recognized"
  exit 1
fi

if [ -z "${eclipseZipFiles[$version]}" ]
then
  supportedVersions="${!eclipseZipFiles[@]}"
  err "This install script supports only versions $supportedVersions"
  exit 1
fi

productZip=$1
[ ! -f $productZip ] && productZip=$DOWNLOADS/$installZip
[ ! -f $productZip ] && err "Product zip file $productZip does not exist" && exit 1
productZip=$(readlink -f "$productZip")

updateSettings="Set corresponding RT_* environment variables or update settings on top of the script file $0"
[ ! -d $DOWNLOADS ] && warn "Downloads folder $DOWNLOADS does not exist, creating it ..." && mkdir -p $DOWNLOADS
INSTALL=${INSTALL%/}
[ -z $INSTALL ] && err "INSTALL folder is not specified" && log "$updateSettings" && exit 1
[ -z $INSTALL_BASE ] && err "INSTALL_BASE folder is not specified" && log "$updateSettings" && exit 1
[ ! -d $INSTALL_BASE ] && warn "Installations top folder $INSTALL_BASE does not exist, creating it ..." && mkdir -p $INSTALL_BASE
[ ! -z $isWindows ] && [[ ! $INSTALL =~ ^(/[a-zA-Z]|[a-zA-Z]:)/ ]] && err "Install location full path $INSTALL should start with drive letter, for example, /c/ or C:/" && log "$updateSettings" && exit 1


# Check Java

function findJava {
  path=$1
  
  [ -d "$path" ] && find $path -type f -name $javaExe | tail -1 | sed "s/\/$javaExe$//"
}

function checkJava {
  javaVersion="$1"
  javaVersionNumber="${1#Java }"
  javaDefaultPath=$INSTALL_BASE/JAVA_$javaVersionNumber

  JAVA_BIN=${javaBins[$javaVersion]}
  
  echo "."
  heading "Checking $javaVersion ..."

  # Check Java in default location
  if [ -z $JAVA_BIN ]
  then
    log "Checking Java in default location $javaDefaultPath ..."
    JAVA_BIN=$(findJava $javaDefaultPath)
	[ ! -z $JAVA_BIN ] && log "Found $javaVersion in default location $javaDefaultPath"
  fi

  # Search for jdk-8 or jdk-11 under top install folder  
  if [ -z $JAVA_BIN ]
  then
    log "Searching for jdk-$javaVersionNumber under top install folder $INSTALL_BASE ..."
    javaInstallPath=$(find $INSTALL_BASE -maxdepth 2 -type d -name *jdk-$javaVersionNumber*)
    [ ! -z $javaInstallPath ] && JAVA_BIN=$(findJava $javaInstallPath)
	[ ! -z $JAVA_BIN ] && log "Found $javaVersion executable under $javaInstallPath"
  fi

  if [ -z $JAVA_BIN ]
  then
    warn "Path to $javaVersion bin folder is not specified and can not be found under $INSTALL_BASE"
	rm -rf $javaDefaultPath
	downloadAddress=${javaDownloads[$javaVersionNumber]}
	javaZipFile=$(basename $downloadAddress)
	javaZip=$DOWNLOADS/$javaZipFile
	if [ ! -f $javaZip ]
	then
	  heading "Downloading $javaVersion from $downloadAddress ..."
	  filesToClean=$javaZip
	  curl -L -o $javaZip "$downloadAddress"
      if [ $? -ne 0 ] || [ ! -f $javaZip ]
      then
        err "Downloading FAILED"
        clean
        exit 1
      fi
	  filesToClean=
	fi
    log "$(ls -l $DOWNLOADS | grep $javaZipFile)"
	extract $javaZip $javaDefaultPath
	JAVA_BIN=$(findJava $javaDefaultPath)
  fi

  log "JAVA${javaVersionNumber}_BIN = $JAVA_BIN"

  ! $JAVA_BIN/java -version && err "Cannot find $javaVersion executable" && exit 1
  
  javaBins[$javaVersion]=$JAVA_BIN
}


java4Installing=${javas4Installing[$version]}
java4Running=${javas4Running[$version]}
checkJava "$java4Installing"
[ "$java4Installing" != "$java4Running" ] && checkJava "$java4Running"


# Check existing installation

productName=$(echo $product | sed "s/modelrt/MODELRT/;s/rsarte\?/RSARTE/;s/rtist/RTIST/")
COMPANY=${company/ibm/IBM} && COMPANY=${company/hcl/HCL}
INSTALL_DIR=$(echo $INSTALL | sed "s/@PRODUCT@/$productName/g;s/@product@/$product/g;s/@VERSION@/$version/g;s/@RELEASE@/$release/g;s/@BUILD@/$buildNumber/g;s/@COMPANY@/$COMPANY/g;s/@company@/$company/g")

if [ -d $INSTALL_DIR ] && [ ! -z "$(ls -A $INSTALL_DIR)" ]
then
  [ -n "$(find $INSTALL_DIR -type d -name *main.feature_*v$buildNumber)" ] &&
    log "${GREEN}$productName $version ${release}_v$buildNumber has already been installed into $INSTALL_DIR ${NC}" && exit 0
  if [ "$isWindows" ]
  then
    runningProcess="$(ps -af | grep $INSTALL_DIR/$eclipseExe)"
  else
    runningProcess="$(pgrep $INSTALL_DIR/$eclipseExe)"
  fi
  [ ! -z "$runningProcess" ] && err "The product is still running" && log "$runningProcess" && log "Close $productName $version before starting new installation" && exit 1
  
  if [ -z $RT_INSTALL_FORCE_OVERWRITE ]
  then
    echo "."
    warn "Installation folder $INSTALL_DIR exists and is not empty"
    read -p "Would you like to Overwrite old installation, Update it, or Cancel? (O/u/c)" ouc
    [[ "$ouc" =~ ^[Cc] ]] && exit 0
    [[ "$ouc" =~ ^[Uu] ]] && update=yes && log "Existing installaion $INSTALL_DIR will be updated"
  fi

  [ -z $update ] && log "Existing folder $INSTALL_DIR will be overwritten if new installation is successful"
else
  #mkdir -p $INSTALL_DIR
  newInstallation=yes
fi


# Check or download eclipse installation

eclipseZipFile=${eclipseZipFiles[$version]}
if [[ "$eclipseZipFile" =~ eclipse-cpp-(.+)-([^-]+)-(win32|linux|macosx) ]]
then
  eclipseReleaseName=${BASH_REMATCH[1]}
  eclipseReleaseId=${BASH_REMATCH[2]}
  if [[ "$release" == eclipse-* ]]
  then
    eclipseRelease=${release#eclipse-}
    eclipseZipFile=${eclipseZipFile/$eclipseReleaseName/$eclipseRelease}
    eclipseReleaseName=$eclipseRelease
  fi
else
  err "Eclipse zip file for version '$version' is not identified"
  exit 1
fi

ECLIPSE_REPO="https://download.eclipse.org/releases/$eclipseReleaseName"
ECLIPSE_ZIP="$DOWNLOADS/$eclipseZipFile"

if [ ! -f $ECLIPSE_ZIP ]
then
  echo "."
  heading "Downloading $eclipseZipFile from https://www.eclipse.org/downloads/ ..."
  downloadAddress="https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/$eclipseReleaseName/$eclipseReleaseId/$eclipseZipFile&mirror_id=1"
  log "$downloadAddress"
  curl -L -o $ECLIPSE_ZIP "$downloadAddress"
  if [ $? -ne 0 ] || [ ! -f $ECLIPSE_ZIP ]
  then
    err "Downloading FAILED"
    rm -f $ECLIPSE_ZIP
    exit 1
  fi
  log "$(ls -l $DOWNLOADS | grep $eclipseZipFile)"
fi




tmpInstall=${INSTALL_DIR}__tmp_$installId
tmpInstallWs=${INSTALL_DIR}__tmp_ws
eclipseInstallLog=./install.log

function clean {
  rm -rf $tmpInstall $tmpInstallWs $eclipseInstallLog RCL_API_Log_Sample*.xml
}

trap ctrl_c INT

function ctrl_c() {
  echo -e "\n*** Terminated with CTRL-C"
  
  clean
}

echo "."
if [ -z $update ]
then
  extract $ECLIPSE_ZIP $tmpInstall
  installFolder=$tmpInstall
else
  installFolder=$INSTALL_DIR
fi

[ "$isWindows" ] && productZip=$(echo $productZip | sed 's#^/\([a-zA-Z]\)/\(.*\)#/\u\1:/\2#')


### Get the list of components in product.zip and validate install components

echo "."
heading "Checking list of installation components in $installZip ..."
declare -A productComponents
productContents=$installFolder/rt_product.txt
$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -data $tmpInstallWs -r "jar:file:$productZip!/" -list > $productContents
rm -rf $tmpInstallWs
productComponents[core]=$(grep -E "(model-realtime|rsarte|rtist).core=" $productContents | cut -d= -f1)
productComponents[extra]=$(grep -E "(model-realtime|rsarte|rtist).extra=" $productContents | cut -d= -f1)
productComponents[integrations]=$(grep -E "(model-realtime|rsarte|rtist).integrations=" $productContents | cut -d= -f1)
[ -z "$RT_INSTALL_COMPONENTS" ] && RT_INSTALL_COMPONENTS="core,extra,integrations" #,NodePlus.tools
for iComp in ${RT_INSTALL_COMPONENTS//,/ }
do
	if [ $iComp == core ] || [ $iComp == extra ] || [ $iComp == integrations ]
	then
		if [ "${productComponents[$iComp]}" ]
		then
			installComponents=$installComponents,${productComponents[$iComp]}
		else
			warn "Component '$iComp' is not available in $productZip"
		fi
	else
		installComponents=$installComponents,$iComp
	fi
done
installComponents=${installComponents#,}


echo "."
log "Product zip        = $installZip"
log "Product            = $productName $version"
log "Version            = ${release}_v$buildNumber"
log "Install pattern    = $INSTALL"
log "Install folder     = $INSTALL_DIR"
log "Install components = $installComponents"
log "Eclipse zip        = $ECLIPSE_ZIP"
realPath=$(readlink -f "${javaBins[Java 8]}")
log "Java 8             = $realPath"
realPath=$(readlink -f "${javaBins[Java 11]}")
log "Java 11            = $realPath"
realPath=$(readlink -f "${javaBins[Java 17]}")
log "Java 17            = $realPath"
realPath=$(readlink -f "${javaBins[Java 21]}")
log "Java 21            = $realPath"


### Disable Latest Eclipse Release (for eclipse 2020.06 and eclipse 2021.06)

if [[ "$eclipseReleaseName" > "2019-06" ]]
then
  echo "."
  heading "Disabling Latest Eclipse Release ..."
  log "__download.eclipse.org_releases_latest/enabled=false"
  p2_engine=$(find $installFolder -type d -name org.eclipse.equinox.p2.engine | tail -1)
  [ "$p2_engine" ] || ( err "org.eclipse.equinox.p2.engine/ was not found under $installFolder" && clean && exit 1 )
  for ff in $(grep -l -r "releases_latest" $p2_engine | sort -u)
  do
    sed -i 's#__download.eclipse.org_releases_latest/enabled=true#__download.eclipse.org_releases_latest/enabled=false#g' $ff
  done
  if [[ "$eclipseReleaseName" > "2020-06" ]]
  then
    log "__download.eclipse.org_technology_epp_packages_latest/enabled=false"
    for ff in $(grep -l -r "technology_epp_packages_latest" $p2_engine | sort -u)
    do
      sed -i 's#__download.eclipse.org_technology_epp_packages_latest/enabled=true#__download.eclipse.org_technology_epp_packages_latest/enabled=false#g' $ff
    done
  fi
fi


### Replace default eGit in installation

egitFeature=org.eclipse.egit.feature.group
if [[ $installComponents =~ \.integrations ]]
then
  [ ! $installComponents == .*$egitFeature.* ] && [ $version != "10.2" ] && installComponents=$installComponents,$egitFeature
  if [ -z $update ]
  then
    echo "."
    heading "Uninstalling default eGit feature with $java4Installing ..."
    log "$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -uninstallIU $egitFeature"
    $installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -uninstallIU $egitFeature > $eclipseInstallLog 2>&1
    cat $eclipseInstallLog | grep ") is satisfiable" | sed 's/ is satisfiable//' | sed "s/\s*!MESSAGE Remove request for /- /"
    log "$egitFeature will be installed from $product-$version repo"
  fi
fi


### Uninstall current version of product

if [ ! -z $update ]
then
  echo "."
  heading "Uninstalling current version of product with $java4Installing ..."
  log "$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -uninstallIU $installComponents"
  $installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -uninstallIU $installComponents > $eclipseInstallLog 2>&1
  uninstallStatus=$?
  [ $uninstallStatus -ne 0 ] && cat $eclipseInstallLog && clean && err "Uninstalling FAILED" && exit 1
  cat $eclipseInstallLog | grep ") is satisfiable" | sed 's/ is satisfiable//' | sed "s/\s*!MESSAGE Remove request for /- /"
  log "${GREEN}Uninstalling OK${NC}"
fi


### Install product

echo "."
heading "Installing from $productZip with $java4Installing ..."
log "$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -r "jar:file:$productZip!/" -r $ECLIPSE_REPO -installIU $installComponents"
$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -consoleLog -application org.eclipse.equinox.p2.director -r "jar:file:$productZip!/" -r $ECLIPSE_REPO -installIU $installComponents > $eclipseInstallLog 2>&1
installStatus=$?

if [ "$installStatus" != "0" ]
then
  cat $eclipseInstallLog
  err "Installation FAILED"
  clean
  exit 1
fi

echo productZip="$productZip" > "$installFolder"/.rtproduct
cat $eclipseInstallLog | grep ") is satisfiable" | sed 's/ is satisfiable//' | sed "s/\s*!MESSAGE Add request for /+ /"
log "${GREEN}Installation OK${NC}"

echo "."
heading "Initializing installation with $java4Installing ..."
log "$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -initialize"
$installFolder/$eclipseExe -vm ${javaBins[$java4Installing]} -nosplash -initialize
initializeStatus=$?
[ $initializeStatus -ne 0 ] && clean && err "Initialization FAILED" && exit 1
log "${GREEN}Init OK${NC}"


if [ -z $update ]
then
  echo "."
  if [ -z $newInstallation ]
  then
    heading "Overwriting old installation $INSTALL_DIR ..."
	statusMessage="Overwritten"
  else
    heading "Moving new installation into $INSTALL_DIR ..."
	statusMessage="Moved"
  fi
  rm -rf $INSTALL_DIR
  status=$?
  [ $status -ne 0 ] && err "Failed to remove old installation" && clean && exit 1
  mv -f $tmpInstall $INSTALL_DIR
  log "${GREEN}$statusMessage OK${NC}"


  ### Configure installation

  echo "."
  heading "Configuring installation $INSTALL_DIR ..."
  log "+ org.eclipse.ui/showIntro=false"
  find $INSTALL_DIR -type f -name plugin_customization.ini -exec sed -i -e '$a\org.eclipse.ui/showIntro=false' {} \;
  log "+ org.eclipse.oomph.setup.ui/enable.preference.recorder=false"
  find $INSTALL_DIR -type f -name plugin_customization.ini -exec sed -i -e '$a\org.eclipse.oomph.setup.ui/enable.preference.recorder=false' {} \;
  log "Increasing maximum heap size for Eclipse JVM to 4Gb: -Xmx4096m"
  [ "$isMacOS" ] && eclipseBase=$INSTALL_DIR/Contents/Eclipse || eclipseBase=$INSTALL_DIR
  eclipseIni=$eclipseBase/eclipse.ini
  configIni=$eclipseBase/configuration/config.ini
  sed -i 's/-Xmx.*m/-Xmx4096m/' $eclipseIni
  if [[ "$eclipseReleaseName" > "2020-06" ]]
  then
    java4eclipseini="$(echo ${javaBins[$java4Running]} | sed 's#^\(/cygdrive\)\?/\(.\)/#\u\2:/#')"
    log "Updating java in eclipse.ini: $java4eclipseini"
    sed -i "s#plugins/.*\.x86_64_1[67].*/jre/bin#$java4eclipseini#" $eclipseIni
  fi
  log "Disabling donate window pop up in eclipse.ini: -Dorg.eclipse.oomph.setup.donate=false"
  echo "-Dorg.eclipse.oomph.setup.donate=false" >> $eclipseIni
  if [ "$isLinux" ]
  then
    [ -f "$INSTALL_DIR/rsa_rt/tools/linux/rtperl" ] && log "chmod a+x $INSTALL_DIR/rsa_rt/tools/linux/rtperl" && chmod a+x "$INSTALL_DIR/rsa_rt/tools/linux/rtperl"
  fi
fi


echo "."
log "${GREEN}$productName $version ${release}_v$buildNumber installed successfully${NC}"


### Check new installation with $java4Running

if [ ! -z $START_AFTER_INSTALL ]
then
  echo "."
  heading "Starting installed product with $java4Running ..."
  workspace=$TESTS/ws_${productName}_${version}_$release
  log "Workspace = $workspace"
  export RCL_LOG_CONFIG_NO_LOGS=1
  log "$INSTALL_DIR/$eclipseExe -vm ${javaBins[$java4Running]} -data $workspace &"
  $INSTALL_DIR/$eclipseExe -vm ${javaBins[$java4Running]} -data $workspace &
fi

echo "."

### Clean up

clean

