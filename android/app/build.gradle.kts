plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "co.aipex.hrms"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Kotlin DSL uses `isCoreLibraryDesugaringEnabled`
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "co.aipex.hrms"
        minSdk = 23 //flutter.minSdkVersion
        targetSdk = 36//flutter.targetSdkVersion
        versionCode = 23 //flutter.versionCode
        versionName = "1.8.3"  //flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
     add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.1.5")
}
