import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.chicademy.mitoosa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(21))
        }
    }

    defaultConfig {
        applicationId = "com.chicademy.mitoosa"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystoreProperties = Properties().apply {
        val keyPropsFile = rootProject.file("android/key.properties")
        if (keyPropsFile.exists()) {
            keyPropsFile.inputStream().use { load(it) }
        }
    }

    signingConfigs {
        create("release") {
            storeFile = keystoreProperties.getProperty("storeFile")
                ?.takeIf { it.isNotBlank() }
                ?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            val missingFields = buildList<String> {
                if (releaseConfig.storeFile == null) add("storeFile")
                if (releaseConfig.storePassword.isNullOrBlank()) add("storePassword")
                if (releaseConfig.keyAlias.isNullOrBlank()) add("keyAlias")
                if (releaseConfig.keyPassword.isNullOrBlank()) add("keyPassword")
            }
            if (missingFields.isNotEmpty()) {
                throw GradleException(
                    "Release build requires android/key.properties with valid signing configuration. " +
                    "Missing: ${missingFields.joinToString(", ")}. See Docs/RELEASE-SIGNING.md."
                )
            }
            signingConfig = releaseConfig
        }
    }
}

flutter {
    source = "../.."
}
