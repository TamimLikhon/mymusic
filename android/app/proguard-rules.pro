# ── Flutter InAppWebView ──────────────────────────────────────────────────────
# Keep the JavaScript bridge handler so the WebView can still call
# window.flutter_inappwebview.callHandler(...) in release builds.
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class * extends com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── just_audio / audio_service ────────────────────────────────────────────────
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# ── General Flutter plugin safety ────────────────────────────────────────────
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugins.** { *; }

# ── Prevent stripping of anonymous classes (used by callbacks) ────────────────
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
