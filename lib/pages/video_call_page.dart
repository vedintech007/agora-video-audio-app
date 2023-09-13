import 'dart:io';
import 'dart:math';

import 'package:agora_calling/utils/agora_functions.dart';
import 'package:agora_calling/widgets/call_actions_row.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agora_calling/utils/agora_user.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.isMicEnabled,
    required this.isVideoEnabled,
  });

  final String appId;
  final String token;
  final String channelName;
  final bool isMicEnabled;
  final bool isVideoEnabled;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late final RtcEngine _agoraEngine;
  late final _users = <AgoraUser>{};
  late double _viewAspectRatio;

  int? _currentUid;
  bool _isMicEnabled = false;
  bool _isVideoEnabled = false;

  int? _remoteUid;
  final bool _localUserJoined = false;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _users.clear();
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _agoraEngine.leaveChannel();
    // await _agoraEngine.destroy();
  }

  Future<void> _initialize() async {
    // Set aspect ratio for video according to platform
    if (kIsWeb) {
      _viewAspectRatio = 3 / 2;
    } else if (Platform.isAndroid || Platform.isIOS) {
      _viewAspectRatio = 2 / 3;
    } else {
      _viewAspectRatio = 3 / 2;
    }

    setState(() {
      _isMicEnabled = widget.isMicEnabled;
      _isVideoEnabled = widget.isVideoEnabled;
    });

    await initAgoraRtcEngine(
      agoraEngine: _agoraEngine,
      appId: widget.appId,
      isVideoEnabled: _isVideoEnabled,
      isMicEnabled: _isMicEnabled,
    );
    _addAgoraEventHandlers();

    await _agoraEngine.joinChannel(
      token: widget.token,
      channelId: widget.appId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  _addAgoraEventHandlers() => _agoraEngine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, _) {
            final info = 'LOG::onError: $code';
            debugPrint(info);
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            debugPrint("LOG::userJoined: $uid");
            setState(() {
              _remoteUid = uid;
              _users.add(
                AgoraUser(
                  uid: uid,
                  // view: SurfaceView(
                  //   channelId: widget.channelName,
                  //   uid: uid,
                  // ),
                ),
              );
            });
          },
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("LOG::onJoinChannel: joined uid ${connection.localUid} elapse $elapsed");
            // setState(() => _localUserJoined = true);
            setState(() {
              _users.add(
                AgoraUser(
                  uid: connection.localUid!,
                  isAudioEnabled: _isMicEnabled,
                  isVideoEnabled: _isVideoEnabled,
                  // view: SurfaceView(),
                ),
              );
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");
            setState(() {
              _remoteUid = null;
            });
          },
          onLeaveChannel: (connection, stats) {
            debugPrint('LOG::onLeaveChannel');
            setState(() => _users.clear());
          },
          onFirstRemoteAudioFrame: (connection, userId, elapsed) {},
          onFirstLocalAudioFramePublished: (connection, elapsed) {},
          onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {},
          onFirstLocalVideoFrame: (source, width, height, elapsed) {},
          onVideoDeviceStateChanged: (deviceId, deviceType, deviceState) {},
          onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {},
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
        ),
      );

  Future<void> _onCallEnd(BuildContext context) async {
    await _agoraEngine.leaveChannel();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onToggleAudio() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
      for (AgoraUser user in _users) {
        if (user.uid == _currentUid) {
          user.isAudioEnabled = _isMicEnabled;
        }
      }
    });
    _agoraEngine.muteLocalAudioStream(!_isMicEnabled);
  }

  void _onToggleCamera() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      for (AgoraUser user in _users) {
        if (user.uid == _currentUid) {
          setState(() => user.isVideoEnabled = _isVideoEnabled);
        }
      }
    });
    _agoraEngine.muteLocalVideoStream(!_isVideoEnabled);
  }

  void _onSwitchCamera() => _agoraEngine.switchCamera();

  List<int> _createLayout(int n) {
    int rows = (sqrt(n).ceil());
    int columns = (n / rows).ceil();

    List<int> layout = List<int>.filled(rows, columns);
    int remainingScreens = rows * columns - n;

    for (int i = 0; i < remainingScreens; i++) {
      layout[layout.length - 1 - i] -= 1;
    }

    return layout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white54,
            ),
            const SizedBox(width: 6.0),
            const Text(
              'Channel name: ',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16.0,
              ),
            ),
            Text(
              widget.channelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white54,
                ),
                const SizedBox(width: 6.0),
                Text(
                  _users.length.toString(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final isPortrait = orientation == Orientation.portrait;
                    if (_users.isEmpty) {
                      return const SizedBox();
                    }
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => setState(() => _viewAspectRatio = isPortrait ? 2 / 3 : 3 / 2),
                    );
                    final layoutViews = _createLayout(_users.length);
                    return AgoraVideoLayout(
                      users: _users,
                      views: layoutViews,
                      viewAspectRatio: _viewAspectRatio,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CallActionsRow(
                isMicEnabled: _isMicEnabled,
                isVideoEnabled: _isVideoEnabled,
                onCallEnd: () => _onCallEnd(context),
                onToggleAudio: _onToggleAudio,
                onToggleCamera: _onToggleCamera,
                onSwitchCamera: _onSwitchCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgoraVideoLayout extends StatelessWidget {
  const AgoraVideoLayout({
    super.key,
    required Set<AgoraUser> users,
    required List<int> views,
    required double viewAspectRatio,
  })  : _users = users,
        _views = views,
        _viewAspectRatio = viewAspectRatio;

  final Set<AgoraUser> _users;
  final List<int> _views;
  final double _viewAspectRatio;

  @override
  Widget build(BuildContext context) {
    int totalCount = _views.reduce((value, element) => value + element);
    int rows = _views.length;
    int columns = _views.reduce(max);

    List<Widget> rowsList = [];
    for (int i = 0; i < rows; i++) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < columns; j++) {
        int index = i * columns + j;
        if (index < totalCount) {
          rowChildren.add(
            AgoraVideoView(
              user: _users.elementAt(index),
              viewAspectRatio: _viewAspectRatio,
            ),
          );
        } else {
          rowChildren.add(
            const SizedBox.shrink(),
          );
        }
      }
      rowsList.add(
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowsList,
    );
  }
}

class AgoraVideoView extends StatelessWidget {
  const AgoraVideoView({
    super.key,
    required double viewAspectRatio,
    required AgoraUser user,
  })  : _viewAspectRatio = viewAspectRatio,
        _user = user;

  final double _viewAspectRatio;
  final AgoraUser _user;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: AspectRatio(
          aspectRatio: _viewAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _user.isAudioEnabled ?? false ? Colors.blue : Colors.red,
                width: 2.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    maxRadius: 18,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 24.0,
                    ),
                  ),
                ),
                if (_user.isVideoEnabled ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8 - 2),
                    child: _user.view,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
