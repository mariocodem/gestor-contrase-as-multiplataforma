pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "My Application"

// Clean Architecture layers. Dependencies only point inwards:
// app -> presentation, data, designsystem, domain; presentation -> domain, designsystem;
// data -> domain; domain and designsystem depend on no other module.
include(":app")
include(":domain")
include(":data")
include(":designsystem")
include(":presentation")
