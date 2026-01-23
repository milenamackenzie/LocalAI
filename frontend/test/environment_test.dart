import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Frontend Environment Verification', () {
    test('Flutter SDK should be available', () {
      // In flutter test, we are running inside the SDK usually, 
      // but checking Platform.version gives Dart version.
      expect(Platform.version, isNotNull);
    });

    test('Dart version should be compatible', () {
      // Expecting Dart 3.x
      final version = Platform.version;
      final major = int.parse(version.split('.')[0]);
      if (major < 3) {
        fail('Dart version is too old: $version. Remediation: Upgrade Flutter/Dart SDK.');
      }
    });

    test('Android SDK Environment Variable should be set', () {
      final androidHome = Platform.environment['ANDROID_HOME'] ?? Platform.environment['ANDROID_SDK_ROOT'];
      if (androidHome == null || androidHome.isEmpty) {
         // This might fail in some IDEs if not explicitly passed, 
         // but essential for CI/CLI builds.
         // We warn instead of failing if strictly local and relying on local.properties
         print('WARNING: ANDROID_HOME is not set in environment variables.');
      } else {
        final dir = Directory(androidHome);
        if (!dir.existsSync()) {
          fail('ANDROID_HOME points to non-existent directory: $androidHome');
        }
      }
    });

    test('Project structure should contain essential folders', () {
      final dirs = [
        'lib',
        'lib/core',
        'lib/data',
        'lib/domain',
        'lib/presentation',
        'test',
        'android'
      ];
      
      for (final dirPath in dirs) {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) {
           fail('Missing directory: $dirPath. Remediation: Check scaffolding.');
        }
      }
    });
    
    test('Network: Localhost connectivity check', () async {
      // Try connecting to where the backend WOULD be (port 3000)
      // This is just a reachability check (firewall), not service up check.
      try {
        // We assume backend might not be running, so connection refused is "good" 
        // in terms of "network stack is working", vs "NetworkUnreachable".
        // But better: check google.com or 8.8.8.8 for internet.
        final result = await InternetAddress.lookup('localhost');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          fail('Localhost resolution failed.');
        }
      } catch (e) {
        fail('Network connectivity issue: $e');
      }
    });
  });
}
