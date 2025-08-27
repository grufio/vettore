pluginManagement {
    // Use local.properties if present; otherwise do not require Flutter SDK.
    val localPropertiesFile = file("local.properties")
    val flutterSdkPath: String? = if (localPropertiesFile.exists()) {
        val properties = java.util.Properties()
        localPropertiesFile.inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk")
    } else {
        null
    }

    if (flutterSdkPath != null) {
        includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
