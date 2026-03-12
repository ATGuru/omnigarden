-dontwarn android.attr.lStar

# Supabase
-keep class io.supabase.** { *; }
-keep class com.sun.ktor.** { *; }
-dontwarn io.supabase.**

# Riverpod / Flutter
-keep class ** extends androidx.lifecycle.ViewModel { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keep class kotlinx.serialization.** { *; }
-keepclassmembers class ** {
    @kotlinx.serialization.SerialName <fields>;
}

# OkHttp / Ktor (used by Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Flutter Secure Storage (used by Supabase to persist sessions)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }
