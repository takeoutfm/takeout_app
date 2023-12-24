The wear plugin is outdated. The 1.1.0 version needs the following fix:

https://github.com/fluttercommunity/flutter_wear_plugin/issues/25

While this issue persists, you can fix it by opening the flutter plugin code and changing
ext.kotlin_version = '1.5.10'
to
ext.kotlin_version = '1.5.20'
in file build.gradle
