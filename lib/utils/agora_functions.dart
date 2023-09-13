import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> initAgoraRtcEngine({
  required RtcEngine agoraEngine,
  required String? appId,
  bool isVideoEnabled = false,
  bool isMicEnabled = false,
}) async {
  // retrieve permissions
  await [Permission.microphone, Permission.camera].request();

  //create the engine
  agoraEngine = createAgoraRtcEngine();
  await agoraEngine.initialize(
    RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ),
  );

  // VideoEncoderConfiguration configuration = const VideoEncoderConfiguration();
  // configuration.orientationMode = VideoOrientation.videoOrientation0;

  await agoraEngine.setClientRole(
    role: ClientRoleType.clientRoleBroadcaster,
  );
  isVideoEnabled ? await agoraEngine.enableVideo() : await agoraEngine.disableVideo();
  isMicEnabled ? await agoraEngine.enableAudio() : await agoraEngine.disableAudio();
  await agoraEngine.startPreview();
  await agoraEngine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
  await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
  await agoraEngine.muteLocalAudioStream(isMicEnabled);
  await agoraEngine.muteLocalVideoStream(isVideoEnabled);
}

addAgoraEventHandlers({
  required RtcEngine agoraEngine,
  void Function(RtcConnection, int)? onJoinChannelSuccess,
  void Function(RtcConnection, int, int)? onUserJoined,
  void Function(RtcConnection, int, UserOfflineReasonType)? onUserOffline,
  void Function(RtcConnection, String)? onTokenPrivilegeWillExpire,
}) {
  agoraEngine.registerEventHandler(
    RtcEngineEventHandler(
      onJoinChannelSuccess: onJoinChannelSuccess,
      onUserJoined: onUserJoined,
      onUserOffline: onUserOffline,
      onTokenPrivilegeWillExpire: onTokenPrivilegeWillExpire,
    ),
  );
}
