import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Assinatura de release: android/key.properties (local) ou variáveis de
// ambiente (CI). Sem nenhum dos dois, o release usa a chave de debug.
val keyProperties = Properties().apply {
    val arquivo = rootProject.file("key.properties")
    if (arquivo.exists()) arquivo.inputStream().use { load(it) }
}
fun assinatura(chave: String, env: String): String? =
    keyProperties.getProperty(chave) ?: System.getenv(env)

val keystorePath = assinatura("storeFile", "ANDROID_KEYSTORE_PATH")

android {
    namespace = "io.github.bigmiranda.manejador_leitores"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.bigmiranda.manejador_leitores"
        // flutter_local_notifications e o Flutter atual exigem API 24 (Android 7.0).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePath != null) {
            create("release") {
                storeFile = file(keystorePath)
                storePassword = assinatura("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = assinatura("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = assinatura("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePath != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
