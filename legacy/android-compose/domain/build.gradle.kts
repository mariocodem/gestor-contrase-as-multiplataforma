import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// Pure Kotlin: no Android framework, so business rules stay testable on the JVM and the
// dependency rule (domain depends on nothing) is enforced by the build, not by convention.
plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.ksp)
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
        optIn.add("kotlinx.coroutines.ExperimentalCoroutinesApi")
    }
}

dependencies {
    api(libs.kotlinx.coroutines.core)
    // Only the JSR-330 annotations and Dagger's runtime; the generated factories let Hilt build
    // use cases without a module listing each one.
    implementation(libs.dagger)
    ksp(libs.dagger.compiler)

    testImplementation(libs.junit)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.turbine)
}
