import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satusehat_isdk/satusehat_isdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSatusehatIsdk platform = MethodChannelSatusehatIsdk();
  const MethodChannel channel = MethodChannel('satusehat_isdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
