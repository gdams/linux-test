package net.adoptopenjdk.installer;

import org.gradle.api.tasks.OutputFile;
import java.io.File;

public class BuildVendorDebianPackage extends BuildDebianPackage {
    @Override
    @OutputFile
    public File getOutputFile() {
        // Result looks like openjdk-11-hotspot-11.0.8+2_vendor1_amd64.deb
        String outputFileName = String.format(
                "%s-%s_%s_%s.deb",
                getPackageName(),
                getPackageVersion(),
                getVendor(),
                getArchitecture().debQualifier()
        );
        return new File(getOutputDirectory(), outputFileName);
    }

}
