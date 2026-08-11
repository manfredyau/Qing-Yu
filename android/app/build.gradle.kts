plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.qingyu.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.qingyu.app"
        minSdk = 28
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        // 后端地址：默认指向模拟器宿主机（Android 模拟器中 10.0.2.2 = 开发机 localhost）
        // 真机调试时用开发机局域网 IP 覆盖，如：-PQINGYU_BASE_URL=http://192.168.1.100:3000
        val baseUrl = (project.findProperty("QINGYU_BASE_URL") as String?) ?: "http://10.0.2.2:3000"
        buildConfigField("String", "BASE_URL", "\"$baseUrl\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.2.0")
    implementation("androidx.fragment:fragment-ktx:1.8.5")

    // Hotwire Native（Maven Central）
    implementation("dev.hotwire:core:1.2.0")
    implementation("dev.hotwire:navigation-fragments:1.2.0")
}
