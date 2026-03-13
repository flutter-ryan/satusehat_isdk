import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'satusehat_isdk_platform_interface.dart';

/// An implementation of [SatusehatIsdkPlatform] that uses method channels.
class MethodChannelSatusehatIsdk extends SatusehatIsdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('satusehat_isdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
