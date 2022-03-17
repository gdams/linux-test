Get-ChildItem -Path .\ -Filter *.zip -File -Name| ForEach-Object {
  
  $filename = [System.IO.Path]::GetFileName($_)
  Write-Output "Processing filename : $filename"

  # validate that the zip file is OpenJDK with an optional major version number
  $openjdk_filename_regex = "^microsoft-(jdk|jre)-(?<major>\d*)"
  $openjdk_found = $filename -match $openjdk_filename_regex
  if (!$openjdk_found) {
    Write-Output "filename : $filename doesn't match regex $openjdk_filename_regex"
    exit 2
  }

  $openjdk_basedir="OpenJDK"
  if ([string]::IsNullOrEmpty($matches.major)) {
    # put unnumbered OpenJDK filename into OpenJDK-Latest directory
    # see Build.OpenJDK_generic.cmd who's going to look at it
    $major=$openjdk_basedir + "-Latest"
  } else {
    $major=$openjdk_basedir + $Matches.major
  }

  $jvm = "hotspot"

  # Windows Architecture supported
  $platform_regex = "(?<platform>x86-32|x64|aarch64)"
  $platform_found = $filename -match $platform_regex
  if (!$platform_found) {
    Write-Output "filename : $filename doesn't match regex $platform_regex"
    exit 2
  }
  $platform = $Matches.platform

  # Wix toolset expects this to be called arm64
  if ($platform -eq "aarch64") {
    $platform="arm64"
  }

  # extract now
  $unzip_dest = ".\$major\$jvm\$platform"
  Write-Output "Extracting $filename to $unzip_dest"
  Expand-Archive -Force -Path $filename -DestinationPath $unzip_dest

  # do some cleanup in path
  Get-ChildItem -Directory $unzip_dest | Where-Object {$_ -match ".*_.*"} | ForEach-Object {
    $SourcePath = [System.IO.Path]::GetDirectoryName($_.FullName)

    if ( $_.Name -Match "(.*)_(.*)-jre$" ) {
        $NewName = $_.Name -replace "(.*)_(.*)$",'$1-jre'
    } elseif ( $_.Name -Match "(.*)_(.*)$" ) {
        $NewName = $_.Name -replace "(.*)_(.*)$",'$1'
    }
    $Destination = Join-Path -Path $SourcePath -ChildPath $NewName
    echo Moving $_.FullName to $Destination
    if (Test-Path $Destination) { Remove-Item $Destination -Recurse; }
    Move-Item -Path $_.FullName -Destination $Destination -Force
  }
}
