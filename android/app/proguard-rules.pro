# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Sqflite SQLite Plugin
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Preserve annotations and type signatures for reflection/platform channels
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# Abaikan peringatan missing classes dari Google Play Core bawaan Flutter engine
-dontwarn com.google.android.play.core.**
