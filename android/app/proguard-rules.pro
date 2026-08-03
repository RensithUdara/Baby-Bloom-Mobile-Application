# flutter_local_notifications stores scheduled notifications through Gson TypeToken.
# Release shrinking must keep generic signatures or Gson cannot deserialize them.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.** { *; }