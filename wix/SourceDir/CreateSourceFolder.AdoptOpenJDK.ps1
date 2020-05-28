Get-ChildItem -Path .\ -Filter *.zip -File -Name| ForEach-Object {
  $filename = [System.IO.Path]::GetFileName($_)
  $jdk_version_found = $filename -match "(?<jdk>^(?:OpenJDK\d+|OpenJDK))"
  if (!$jdk_version_found) {
    echo "filename : $filename don't match regex ^OpenJDK\d+"
    exit 2
  }
  $jdk_version = $matches.jdk
  $package_type_found = $filename -match "(?<package_type>hotspot|openj9)"
  if (!$package_type_found) {
    echo "filename : $filename don't match regex hotspot|openj9"
    exit 2
  }
  $package_type = $Matches.package_type
  $platform_found = $filename -match "(?<platform>x86-32|x64)"
  if (!$platform_found) {
    echo "filename : $filename don't match regex x86-32|x64"
    exit 2
  }
  $platform = $Matches.platform

  Expand-Archive -Force -Path $filename -DestinationPath ".\$jdk_version\$package_type\$platform"
  Get-ChildItem -Directory ".\$jdk_version\$package_type\$platform" | where {$_ -match ".*_.*"} | ForEach {
    $SourcePath = [System.IO.Path]::GetDirectoryName($_.FullName)
    #echo "SourcePath: " $SourcePath
    #echo "fullname: "$_.FullName
    #echo "Name: " $_.Name
    if ( $_.Name -Match "(.*)_(.*)-jre$" ) {
        $NewName = $_.Name -replace "(.*)_(.*)$",'$1-jre'
    } elseif ( $_.Name -Match "(.*)_(.*)$" ) {
        $NewName = $_.Name -replace "(.*)_(.*)$",'$1'
    }
    
    #echo "NewName: " $NewName
    $Destination = Join-Path -Path $SourcePath -ChildPath $NewName
    #echo "Destination: "$Destination
    
    echo Moving $_.FullName to $Destination
    if (Test-Path $Destination) { Remove-Item $Destination -Recurse; }
    Move-Item -Path $_.FullName -Destination $Destination -Force
    }
}
