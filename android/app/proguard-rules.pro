# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep annotation default values (e.g., retrofit/gson style reflection used by some plugins)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Flutter's embedding references Google Play Core "deferred components" classes
# (used only by apps that implement Play Feature Delivery / dynamic feature
# modules). This app doesn't use that feature, so these classes are never
# present at runtime — silence R8's "missing classes" errors about them
# instead of pulling in the whole play-core library just to satisfy the
# shrinker. This is Flutter's officially documented fix:
# https://docs.flutter.dev/deployment/android#note-regarding-google-play-and-shrinking-with-r8
-dontwarn com.google.android.play.core.**

