import org.gradle.kotlin.dsl.kotlin

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.6.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Fixed: use file() to avoid type mismatch
rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${name}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
