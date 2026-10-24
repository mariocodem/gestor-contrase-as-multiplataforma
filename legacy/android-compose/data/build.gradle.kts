plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
}

android {
    namespace = "com.example.myapplication.data"
    compileSdk {
        version = release(37)
    }

    defaultConfig {
        // 26+: PBKDF2WithHmacSHA256 and java.util.Base64 are needed for the vault crypto.
        minSdk = 26
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        debug {
            // Opt-in, debug only: ./gradlew installDebug -Pboveda.useFirebaseEmulator=true talks to the
            // local Firebase Emulator Suite (firebase emulators:start) instead of the real project.
            val useEmulator = providers.gradleProperty("boveda.useFirebaseEmulator").orNull == "true"
            buildConfigField("boolean", "USE_FIREBASE_EMULATOR", useEmulator.toString())
        }
        release {
            buildConfigField("boolean", "USE_FIREBASE_EMULATOR", "false")
        }
    }

    testOptions {
        // android.util.Log is only called on failure paths; let unit tests run through them.
        unitTests.isReturnDefaultValues = true
    }
}

kotlin {
    compilerOptions {
        optIn.add("kotlinx.coroutines.ExperimentalCoroutinesApi")
    }
}

dependencies {
    implementation(project(":domain"))

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.biometric)
    implementation(libs.androidx.datastore.preferences)
    implementation(platform(libs.firebase.bom))
    implementation(libs.firebase.auth)
    implementation(libs.firebase.firestore)
    implementation(libs.kotlinx.coroutines.play.services)
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)

    testImplementation(libs.junit)
    testImplementation(libs.kotlinx.coroutines.test)
}
