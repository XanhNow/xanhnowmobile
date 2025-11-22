import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProps = Properties()
val keystorePropsFile = rootProject.file("key.properties")
if (keystorePropsFile.exists()) {
    keystoreProps.load(FileInputStream(keystorePropsFile))
}

android {
    namespace = "com.xanhnow.xanhnow_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xanhnow.xanhnow_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(28, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Ưu tiên đọc từ key.properties
            if (keystoreProps.isNotEmpty()) {
                storeFile = keystoreProps["storeFile"]?.toString()?.let { file(it) }
                storePassword = keystoreProps["storePassword"]?.toString()
                keyAlias = keystoreProps["keyAlias"]?.toString()
                keyPassword = keystoreProps["keyPassword"]?.toString()
            }
            // Nếu thiếu, fallback hardcode (release-key.jks)
            if (storeFile == null || storePassword.isNullOrEmpty()) {
                storeFile = file("C:/Users/xanhn/release-key.jks")
                storePassword = "Hung@1077"
                keyAlias = "xanhnowandroidkey"
                keyPassword = "Hung@1077"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
