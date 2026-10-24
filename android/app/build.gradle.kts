plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.boveda"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // A new id, so this app installs next to the old Compose one instead of replacing it.
        // Change "com.example" to a domain of yours before publishing to a store.
        applicationId = "com.example.boveda"
        // 26+, as the Android app had; the biometric key storage needs 23+.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        debug {
            // Opt-in, debug only: flutter run -P boveda.allowScreenshots=true drops FLAG_SECURE so
            // screens can be captured while developing. Never set it for builds you keep real passwords in.
            val allowScreenshots = providers.gradleProperty("boveda.allowScreenshots").orNull == "true"
            buildConfigField("boolean", "ALLOW_SCREENSHOTS", allowScreenshots.toString())
        }
        getByName("profile") {
            buildConfigField("boolean", "ALLOW_SCREENSHOTS", "false")
        }
        release {
            buildConfigField("boolean", "ALLOW_SCREENSHOTS", "false")
            // Signed with the debug key until you add your own (see SETUP.md), so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
