-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

-keep class javax.annotation.concurrent.** { *; }
-dontwarn javax.annotation.concurrent.**

-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

-keep class * extends java.lang.annotation.Annotation { *; }
