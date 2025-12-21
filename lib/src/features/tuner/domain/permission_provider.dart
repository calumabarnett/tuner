import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final microphonePermissionProvider =
    AsyncNotifierProvider<MicrophonePermissionNotifier, PermissionStatus>(
  MicrophonePermissionNotifier.new,
);

class MicrophonePermissionNotifier extends AsyncNotifier<PermissionStatus> {
  @override
  Future<PermissionStatus> build() async {
    return Permission.microphone.status;
  }

  Future<void> request() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => Permission.microphone.request());
  }
}
