import 'package:flutter_test/flutter_test.dart';
import 'package:satusehat_isdk/satusehat_isdk.dart';
import 'package:satusehat_isdk/satusehat_isdk_platform_interface.dart';
import 'package:satusehat_isdk/satusehat_isdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSatusehatIsdkPlatform
    with MockPlatformInterfaceMixin
    implements SatusehatIsdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SatusehatIsdkPlatform initialPlatform = SatusehatIsdkPlatform.instance;

  test('$MethodChannelSatusehatIsdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSatusehatIsdk>());
  });

  test('getPlatformVersion', () async {
    SatusehatIsdk satusehatIsdkPlugin = SatusehatIsdk();
    MockSatusehatIsdkPlatform fakePlatform = MockSatusehatIsdkPlatform();
    SatusehatIsdkPlatform.instance = fakePlatform;

    expect(await satusehatIsdkPlugin.getPlatformVersion(), '42');
  });
}
