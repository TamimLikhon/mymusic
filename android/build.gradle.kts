allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // Fix namespace issue for older plugins that don't specify it
    val libExts = extensions
    pluginManager.withPlugin("com.android.library") {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            if (namespace == null || namespace!!.isEmpty()) {
                namespace = "com.${project.name.replace("-", "_").replace(".", "_")}"
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
