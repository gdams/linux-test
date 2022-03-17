IF NOT "%DEBUG%" == "true" @ECHO OFF

REM Set version numbers and build option here if being run manually:
REM PRODUCT_MAJOR_VERSION=11
REM PRODUCT_MINOR_VERSION=0
REM PRODUCT_MAINTENANCE_VERSION=0
REM PRODUCT_PATCH_VERSION=0
REM PRODUCT_BUILD_NUMBER=28
REM MSI_PRODUCT_VERSION=11.0.0.28
REM ARCH=x64|x86|arm64 or all "x64 x86 arm64"
REM JVM=hotspot|openj9|dragonwell or both JVM=hotspot openj9
REM PRODUCT_CATEGORY=jre|jdk (only one at a time)
REM SKIP_MSI_VALIDATION=true (Add -sval option to light.exe to skip MSI/MSM validation and skip smoke.exe )
REM UPGRADE_CODE_SEED=thisIsAPrivateSecretSeed ( optional ) for upgradable MSI (If none, new PRODUCT_UPGRADE_CODE is generate for each run)

SETLOCAL ENABLEEXTENSIONS
SET ERR=0
IF NOT DEFINED PRODUCT_MAJOR_VERSION SET ERR=1
IF NOT DEFINED PRODUCT_MINOR_VERSION SET ERR=2
IF NOT DEFINED PRODUCT_MAINTENANCE_VERSION SET ERR=3
IF NOT DEFINED PRODUCT_PATCH_VERSION SET ERR=4
IF NOT DEFINED PRODUCT_BUILD_NUMBER SET ERR=5
IF NOT DEFINED MSI_PRODUCT_VERSION SET ERR=6
IF NOT DEFINED ARCH SET ERR=7
IF NOT DEFINED JVM SET ERR=8
IF NOT DEFINED PRODUCT_CATEGORY SET ERR=9
IF NOT DEFINED OUTPUT_BASE_FILENAME SET ERR=10
IF NOT %ERR% == 0 ( ECHO Missing args/variable ERR:%ERR% && GOTO FAILED )
IF NOT "%ARCH%" == "x64" (
	IF NOT "%ARCH%" == "x86" (
        IF NOT "%ARCH%" == "arm64" (
            IF NOT "%ARCH%" == "x86 x64" (
                IF NOT "%ARCH%" == "x86 arm64" (
                    IF NOT "%ARCH%" == "arm64 x86" (
                        IF NOT "%ARCH%" == "x64 x86" (
                            IF NOT "%ARCH%" == "x64 arm64" (
                                IF NOT "%ARCH%" == "arm64 x64" (
                                    IF NOT "%ARCH%" == "x86 x64 arm64" (
                                        IF NOT "%ARCH%" == "x86 arm64 x64" (
                                            IF NOT "%ARCH%" == "arm64 x86 x64" (
                                                IF NOT "%ARCH%" == "arm64 x64 x86" (
                                                    IF NOT "%ARCH%" == "x86 x64 arm64" (
                                                        IF NOT "%ARCH%" == "x64 x86 arm64" (
                                                            ECHO ARCH %ARCH% not supported : valid values : x64, x86, arm64, x86 x64, x64 x86, x86 x64 arm64, x86 arm64 x64, arm64 x86 x64, arm64 x64 x86, x86 x64 arm64, x64 x86 arm64
                                                            GOTO FAILED
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
	)
)

REM Update to handle the change of build variant until implications
REM of setting this to Temurin can be evaluated
IF "%JVM%" == "temurin" SET JVM=hotspot

IF NOT "%JVM%" == "hotspot" (
	IF NOT "%JVM%" == "openj9" (
	    IF NOT "%JVM%" == "dragonwell" (
            IF NOT "%JVM%" == "openj9 hotspot" (
                IF NOT "%JVM%" == "hotspot openj9" (
                    ECHO JVM "%JVM%" not supported : valid values : hotspot, openj9, dragonwell, hotspot openj9, openj9 hotspot
                    GOTO FAILED
                )
            )
        )
	)
)

IF NOT "%PRODUCT_CATEGORY%" == "jre" (
	IF NOT "%PRODUCT_CATEGORY%" == "jdk" (
		ECHO PRODUCT_CATEGORY "%PRODUCT_CATEGORY%" not supported : valid values : jre, jdk
		GOTO FAILED
	)
)


IF "%SKIP_MSI_VALIDATION%" == "true" (
	SET "MSI_VALIDATION_OPTION= -sval "
)

REM Configure available SDK version:
REM See folder e.g. "C:\Program Files (x86)\Windows Kits\[10]\bin\[10.0.16299.0]\x64"
SET WIN_SDK_MAJOR_VERSION=10
SET WIN_SDK_FULL_VERSION=10.0.17763.0

REM
REM Nothing below this line need to be changed normally.
REM

REM Cultures: https://msdn.microsoft.com/de-de/library/ee825488(v=cs.20).aspx
SET PRODUCT_SKU=OpenJDK
SET PRODUCT_FULL_VERSION=%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%.%PRODUCT_PATCH_VERSION%.%PRODUCT_BUILD_NUMBER%

SETLOCAL ENABLEDELAYEDEXPANSION
SET PRODUCT_SHORT_VERSION=%PRODUCT_MAJOR_VERSION%u%PRODUCT_MAINTENANCE_VERSION%-b%PRODUCT_BUILD_NUMBER%
IF %PRODUCT_CATEGORY% EQU jre SET JRE=-jre
IF %PRODUCT_MAJOR_VERSION% GEQ 10 (
    IF DEFINED PRODUCT_BUILD_NUMBER (
        SET BUILD_NUM=+%PRODUCT_BUILD_NUMBER%
    )
    SET PRODUCT_SHORT_VERSION=%PRODUCT_MAJOR_VERSION%
    IF "%PRODUCT_MINOR_VERSION%" NEQ "0" SET PRODUCT_SHORT_VERSION=%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%
    IF "%PRODUCT_MAINTENANCE_VERSION%" NEQ "0" SET PRODUCT_SHORT_VERSION=%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%
    IF "%PRODUCT_PATCH_VERSION%" NEQ "0" SET PRODUCT_SHORT_VERSION=%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%.%PRODUCT_PATCH_VERSION%
    SET PRODUCT_SHORT_VERSION=!PRODUCT_SHORT_VERSION!!BUILD_NUM!
)

REM ECHO Basic      =%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%.%PRODUCT_PATCH_VERSION%.%PRODUCT_BUILD_NUMBER%
ECHO PRODUCT_FULL_VERSION=!PRODUCT_FULL_VERSION!
ECHO PRODUCT_SHORT_VERSION=!PRODUCT_SHORT_VERSION!


REM Generate platform specific builds (x86,x64, arm64)
FOR %%A IN (%ARCH%) DO (
  REM We could build both "hotspot,openj9" in one script, but it is not clear if release cycle is the same.
  FOR %%J IN (%JVM%) DO (
    SET PACKAGE_TYPE=%%J
    SET PLATFORM=%%A
    ECHO Generate OpenJDK setup "!PACKAGE_TYPE!" for "!PLATFORM!" platform "!PRODUCT_CATEGORY!"
    ECHO ****************************************************
    SET CULTURE=en-us
    SET LANGIDS=1033
    SET FOLDER_PLATFORM=!PLATFORM!

    SET SETUP_RESOURCES_DIR=.\Resources

    FOR %%P IN (
        !PRODUCT_SKU!!PRODUCT_MAJOR_VERSION!\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk-%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%
        !PRODUCT_SKU!!PRODUCT_MAJOR_VERSION!\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk%PRODUCT_MAJOR_VERSION%u%PRODUCT_MAINTENANCE_VERSION%-b%PRODUCT_BUILD_NUMBER%
        !PRODUCT_SKU!!PRODUCT_MAJOR_VERSION!\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk-%PRODUCT_MAJOR_VERSION%+%PRODUCT_BUILD_NUMBER%
        !PRODUCT_SKU!!PRODUCT_MAJOR_VERSION!\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk-%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%+%PRODUCT_BUILD_NUMBER%
        !PRODUCT_SKU!!PRODUCT_MAJOR_VERSION!\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk-%PRODUCT_MAJOR_VERSION%.%PRODUCT_MINOR_VERSION%.%PRODUCT_MAINTENANCE_VERSION%.%PRODUCT_PATCH_VERSION%+%PRODUCT_BUILD_NUMBER%
        !PRODUCT_SKU!-Latest\!PACKAGE_TYPE!\!FOLDER_PLATFORM!\jdk-!PRODUCT_SHORT_VERSION!
    ) DO (
        SET REPRO_DIR=.\SourceDir\%%P
        IF "!PRODUCT_CATEGORY!" == "jre" (
            SET REPRO_DIR=!REPRO_DIR!-!PRODUCT_CATEGORY!)
            ECHO looking for !REPRO_DIR!
        IF EXIST "!REPRO_DIR!" (
            goto CONTINUE
        )
    )
    
    ECHO SOURCE Dir not found / failed
    ECHO Listing directory :
    dir /a:d /s /b /o:n SourceDir
    GOTO FAILED

    :CONTINUE
    ECHO Source dir used : !REPRO_DIR!

    SET CACHE_BASE_FOLDER=Cache
    REM Each build his own cache for concurrent build
    SET CACHE_FOLDER=!CACHE_BASE_FOLDER!\!OUTPUT_BASE_FILENAME!

    REM Generate one ID per release. But do NOT use * as we need to keep the same number for all languages, but not platforms.
    FOR /F %%I IN ('POWERSHELL -COMMAND "$([guid]::NewGuid().ToString('b').ToUpper())"') DO (
      SET PRODUCT_ID=%%I
      ECHO PRODUCT_ID: !PRODUCT_ID!
    )

    IF NOT DEFINED UPGRADE_CODE_SEED (
        REM If no UPGRADE_CODE_SEED given .. we are not trying to build upgradable MSI and generate always a new PRODUCT_UPGRADE_CODE
        FOR /F %%F IN ('POWERSHELL -COMMAND "$([guid]::NewGuid().ToString('b').ToUpper())"') DO (
          SET PRODUCT_UPGRADE_CODE=%%F
          ECHO Uniq PRODUCT_UPGRADE_CODE: !PRODUCT_UPGRADE_CODE!
        )
    ) ELSE (
        REM It will be better if we can generate "Name-based UUID" as specified here https://tools.ietf.org/html/rfc4122#section-4.3
        REM but it's too difficult so fallback to random like guid based on md5 hash with getGuid.ps1
        REM We use md5 hash to always get the same PRODUCT_UPGRADE_CODE(GUID) for each MSI build with same GUID_SSED to allow upgrade from AdoptOpenJDK
        REM IF PRODUCT_UPGRADE_CODE change from build to build, upgrade is not proposed by Windows Installer
        REM Never change what compose SOURCE_TEXT_GUID and args0 for getGuid.ps1 or you will never get the same GUID as previous build and MSI upgradable feature wont work
        SET SOURCE_TEXT_GUID=!PRODUCT_CATEGORY!-!PRODUCT_MAJOR_VERSION!-!PLATFORM!-!PACKAGE_TYPE!
        ECHO SOURCE_TEXT_GUID ^(without displaying secret UPGRADE_CODE_SEED^) : !SOURCE_TEXT_GUID!
        FOR /F %%F IN ('powershell -File getGuid.ps1 !SOURCE_TEXT_GUID!-%UPGRADE_CODE_SEED%') DO (
          SET PRODUCT_UPGRADE_CODE=%%F
          ECHO Constant PRODUCT_UPGRADE_CODE: !PRODUCT_UPGRADE_CODE!
        )
    )

    REM Prevent concurrency issues if multiple builds are running in parallel.
	ECHO copy "Main.!PACKAGE_TYPE!.wxs"
    COPY /Y "Main.!PACKAGE_TYPE!.wxs" "Main-!OUTPUT_BASE_FILENAME!.wxs"

    REM Build with extra Source Code feature (needs work)
    REM "!WIX!bin\heat.exe" file "!REPRO_DIR!\lib\src.zip" -out Src-!OUTPUT_BASE_FILENAME!.wxs -gg -srd -cg "SrcFiles" -var var.ReproDir -dr INSTALLDIR -platform !PLATFORM!
    REM "!WIX!bin\heat.exe" dir "!REPRO_DIR!" -out Files-!OUTPUT_BASE_FILENAME!.wxs -t "!SETUP_RESOURCES_DIR!\heat.tools.xslt" -gg -sfrag -scom -sreg -srd -ke -cg "AppFiles" -var var.ProductMajorVersion -var var.ProductMinorVersion -var var.ProductVersionString -var var.MSIProductVersion -var var.ReproDir -dr INSTALLDIR -platform !PLATFORM!
    REM "!WIX!bin\candle.exe" -arch !PLATFORM! Main-!OUTPUT_BASE_FILENAME!.wxs Files-!OUTPUT_BASE_FILENAME!.wxs Src-!OUTPUT_BASE_FILENAME!.wxs -ext WixUIExtension -ext WixUtilExtension -dProductSku="!PRODUCT_SKU!" -dProductMajorVersion="!PRODUCT_MAJOR_VERSION!" -dProductMinorVersion="!PRODUCT_MINOR_VERSION!" -dProductVersionString="!PRODUCT_SHORT_VERSION!" -dMSIProductVersion="!MSI_PRODUCT_VERSION!" -dProductId="!PRODUCT_ID!" -dReproDir="!REPRO_DIR!" -dSetupResourcesDir="!SETUP_RESOURCES_DIR!" -dCulture="!CULTURE!"
    REM "!WIX!bin\light.exe" !MSI_VALIDATION_OPTION! Main-!OUTPUT_BASE_FILENAME!.wixobj Files-!OUTPUT_BASE_FILENAME!.wixobj Src-!OUTPUT_BASE_FILENAME!.wixobj -cc !CACHE_FOLDER! -ext WixUIExtension -ext WixUtilExtension -spdb -out "ReleaseDir\!OUTPUT_BASE_FILENAME!.msi" -loc "Lang\!PRODUCT_SKU!.Base.!CULTURE!.wxl" -loc "Lang\!PRODUCT_SKU!.!PACKAGE_TYPE!.!CULTURE!.wxl" -cultures:!CULTURE!

    REM Clean .cab cache for each run .. Cache is only used inside BuildSetupTranslationTransform.cmd to speed up MST generation
    IF EXIST !CACHE_FOLDER! rmdir /S /Q !CACHE_FOLDER!
    MKDIR !CACHE_FOLDER!
	IF ERRORLEVEL 1 (
		ECHO Unable to create cache folder : !CACHE_FOLDER!
	    GOTO FAILED
	)

	REM Build without extra Source Code feature

    ECHO HEAT
    @ECHO ON
    "!WIX!bin\heat.exe" dir "!REPRO_DIR!" -out Files-!OUTPUT_BASE_FILENAME!.wxs -gg -sfrag -scom -sreg -srd -ke -cg "AppFiles" -var var.ProductMajorVersion -var var.ProductMinorVersion -var var.ProductVersionString -var var.MSIProductVersion -var var.ReproDir -dr INSTALLDIR -platform !PLATFORM!
    IF ERRORLEVEL 1 (
        ECHO Failed to generating Windows Installer XML Source files ^(.wxs^)
        GOTO FAILED
    )
    @ECHO OFF

    ECHO CANDLE
    @ECHO ON
    "!WIX!bin\candle.exe" -arch !PLATFORM! Main-!OUTPUT_BASE_FILENAME!.wxs Files-!OUTPUT_BASE_FILENAME!.wxs !ITW_WXS! -ext WixUIExtension -ext WixUtilExtension -dProductSku="!PRODUCT_SKU!" -dProductMajorVersion="!PRODUCT_MAJOR_VERSION!" -dProductMinorVersion="!PRODUCT_MINOR_VERSION!" -dProductVersionString="!PRODUCT_SHORT_VERSION!" -dMSIProductVersion="!MSI_PRODUCT_VERSION!" -dProductId="!PRODUCT_ID!" -dProductUpgradeCode="!PRODUCT_UPGRADE_CODE!" -dReproDir="!REPRO_DIR!" -dSetupResourcesDir="!SETUP_RESOURCES_DIR!" -dCulture="!CULTURE!" -dJVM="!PACKAGE_TYPE!"
    IF ERRORLEVEL 1 (
        ECHO Failed to preprocesses and compiles WiX source files into object files ^(.wixobj^)
        GOTO FAILED
    )
    @ECHO OFF

    ECHO LIGHT
    @ECHO ON
    "!WIX!bin\light.exe" Main-!OUTPUT_BASE_FILENAME!.wixobj Files-!OUTPUT_BASE_FILENAME!.wixobj !ITW_WIXOBJ! !MSI_VALIDATION_OPTION! -cc !CACHE_FOLDER! -ext WixUIExtension -ext WixUtilExtension -spdb -out "ReleaseDir\!OUTPUT_BASE_FILENAME!.msi" -loc "Lang\!PRODUCT_SKU!.Base.!CULTURE!.wxl" -loc "Lang\!PRODUCT_SKU!.!PACKAGE_TYPE!.!CULTURE!.wxl" -cultures:!CULTURE!
    IF ERRORLEVEL 1 (
        ECHO Failed to links and binds one or more .wixobj files and creates a Windows Installer database ^(.msi or .msm^)
        GOTO FAILED
    )
    @ECHO OFF

    REM Generate setup translations
    FOR /F "tokens=1-2" %%L IN (Lang\LanguageList.config) do (
        CALL BuildSetupTranslationTransform.cmd %%L %%M
        IF ERRORLEVEL 1 (
            ECHO failed to build translation %%L %%M
            GOTO FAILED
        )
    )

    REM Add all supported languages to MSI Package attribute
    CSCRIPT "%ProgramFiles(x86)%\Windows Kits\%WIN_SDK_MAJOR_VERSION%\bin\%WIN_SDK_FULL_VERSION%\x64\WiLangId.vbs" //Nologo ReleaseDir\!OUTPUT_BASE_FILENAME!.msi Package !LANGIDS!
    IF ERRORLEVEL 1 (
		ECHO Failed to pack all languages into MSI : !LANGIDS!
	    GOTO FAILED
	)

	REM For temporarily disable the smoke test - use OPTION SKIP_MSI_VALIDATION=true
	REM To validate MSI only once at the end
	IF NOT "%SKIP_MSI_VALIDATION%" == "true" (
		ECHO SMOKE
		@ECHO ON
		"!WIX!bin\smoke.exe" "ReleaseDir\!OUTPUT_BASE_FILENAME!.msi"
		IF ERRORLEVEL 1 (
			ECHO Failed to validate MSI
		    GOTO FAILED
		)
		@ECHO OFF
	) ELSE (
        ECHO MSI validation was skipped by option SKIP_MSI_VALIDATION=true
    )

    REM SIGN the MSIs with digital signature.
    REM Dual-Signing with SHA-1/SHA-256 requires Win 8.1 SDK or later.
    IF DEFINED SIGNING_CERTIFICATE (
        set timestampErrors=0
        for /L %%a in (1,1,15) do (
            for /F %%s IN (serverTimestamp.config) do (
	        ECHO try !timestampErrors! / sha256 / timestamp server : %%s
		REM Always hide password here
		@ECHO OFF
                "%ProgramFiles(x86)%\Windows Kits\%WIN_SDK_MAJOR_VERSION%\bin\%WIN_SDK_FULL_VERSION%\x64\signtool.exe" sign -f "%SIGNING_CERTIFICATE%" -p "%SIGN_PASSWORD%" -fd sha256 -d "AdoptOpenJDK" -t %%s "ReleaseDir\!OUTPUT_BASE_FILENAME!.msi"
		@ECHO ON
		IF NOT "%DEBUG%" == "true" @ECHO OFF

                REM check the return value of the timestamping operation and retry a max of ten times...
                if ERRORLEVEL 0 if not ERRORLEVEL 1 GOTO succeeded

                echo Signing failed. Probably cannot find the timestamp server at %%s
                set /a timestampErrors+=1
            )
            REM always wait more than seconds after each retry
            choice /N /T:%%a /C:Y /D:Y >NUL
        )

        REM return an error code...
        echo sign.bat exit code is 1. There were %timestampErrors% timestamping errors.
        exit /b 1

    ) ELSE (
        ECHO Ignoring signing step : not certificate configured
    )

    :succeeded
    REM return a successful code...
    echo sign.bat exit code is 0. There were %timestampErrors% timestamping errors.

    REM Remove files we do not need any longer.
    DEL "Files-!OUTPUT_BASE_FILENAME!.wxs"
    DEL "Files-!OUTPUT_BASE_FILENAME!.wixobj"
    DEL "Main-!OUTPUT_BASE_FILENAME!.wxs"
    DEL "Main-!OUTPUT_BASE_FILENAME!.wixobj"
    IF DEFINED ITW_WXS (
        DEL !ITW_WXS!
        DEL !ITW_WIXOBJ!
    )
    RMDIR /S /Q !CACHE_FOLDER!
  )
  SET ITW_WXS=
  SET ITW_WIXOBJ=
)
ENDLOCAL

REM Cleanup variables
SET CULTURE=
SET LANGIDS=
SET PACKAGE_TYPE=
SET PRODUCT_CATEGORY=
SET PRODUCT_SKU=
SET PRODUCT_MAJOR_VERSION=
SET PRODUCT_MINOR_VERSION=
SET PRODUCT_MAINTENANCE_VERSION=
SET PRODUCT_PATCH_VERSION=
SET PRODUCT_BUILD_NUMBER=
SET MSI_PRODUCT_VERSION=
SET PRODUCT_ID=
SET PRODUCT_VERSION=
SET PLATFORM=
SET FOLDER_PLATFORM=
SET REPRO_DIR=
SET SETUP_RESOURCES_DIR=
SET WIN_SDK_FULL_VERSION=
SET WIN_SDK_MAJOR_VERSION=

EXIT /b 0

:FAILED
EXIT /b 2
