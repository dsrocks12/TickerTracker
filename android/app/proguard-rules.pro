# Suppress warnings
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.ParametersAreNonnullByDefault
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry

# Keep required classes
-keep class java.beans.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.ParametersAreNonnullByDefault
-keep class com.fasterxml.jackson.** { *; }
-keep class org.conscrypt.** { *; }
-keep class org.w3c.dom.bootstrap.** { *; }
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class be.tramckrijte.workmanager.** { *; }
-keep class com.hiennv.flutter_callkit_incoming.** { *; }


# Keep Jackson annotations
-keepclassmembers class * {
    @com.fasterxml.jackson.annotation.* <fields>;
    @com.fasterxml.jackson.annotation.* <methods>;
}
