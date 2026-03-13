import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'satusehat_isdk_method_channel.dart';

abstract class SatusehatIsdkPlatform extends PlatformInterface {
  /// Constructs a SatusehatIsdkPlatform.
  SatusehatIsdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SatusehatIsdkPlatform _instance = MethodChannelSatusehatIsdk();

  /// The default instance of [SatusehatIsdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSatusehatIsdk].
  static SatusehatIsdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SatusehatIsdkPlatform] when
  /// they register themselves.
  static set instance(SatusehatIsdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
