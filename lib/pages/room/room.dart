import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../state/auth_state.dart';
import '../../state/room_state.dart';

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class Room extends StatefulWidget {
  final AuthState authController;
  final RoomState roomController;
  const Room({
    super.key,
    required this.authController,
    required this.roomController,
  });

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  late RoomState roomController;
  StreamSocket streamSocket = StreamSocket();
  late io.Socket _socket;

  MediaStream? _localStream;

  final RTCVideoRenderer _localRTCVideoRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRTCVideoRenderer = RTCVideoRenderer();
  RTCPeerConnection? _rtcPeerConnection;
  final List<RTCIceCandidate> _rtcIceCandidates = [];

  List<MediaDeviceInfo> _deviceList = [];
  MediaDeviceInfo? _selectedAudio;
  MediaDeviceInfo? _selectedVideo;

  bool _isAudioOn = true;
  bool _isVideoOn = true;
  final bool _isFrontCameraSelected = true;

  @override
  void initState() {
    super.initState();
    roomController = widget.roomController;
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    // Socket
    // ============================================================
    if (kIsWeb) {
      _socket = io.io(
        'http://localhost:3000',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );
    } else {
      if (Platform.isAndroid) {
        _socket = io.io(
          'http://10.0.2.2:3000',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build(),
        );
      } else if (Platform.isIOS) {
        _socket = io.io(
          'http://127.0.0.1:3000',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build(),
        );
      }
    }

    // Initial socket connection when entering the room
    _socket.connect();

    _socket.onConnect((_) {
      var message = {
        'rid': 'roomId',
        'uid': 'userId',
      };

      _socket.emit('JOIN_ROOM', jsonEncode(message));
    });

    _socket.on('CONNECTED', (data) {
      debugPrint('CONNECTED: $data');
    });

    _socket.onDisconnect((_) => debugPrint('disconnect'));

    // ============================================================

    onPageLoad();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void onPageLoad() async {
    // Initialize peer connection
    var iceConfig = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };

    _rtcPeerConnection = await createPeerConnection(iceConfig);

    // Listen for ice candidates and add to list
    _rtcPeerConnection!.onIceCandidate =
        (candidate) => _rtcIceCandidates.add(candidate);

    _rtcPeerConnection!.onTrack = (event) {
      debugPrint('event: ${event.streams}');
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // Setup user video and audio
    var constraints = {
      'audio': true,
      'video': true,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    // Add user video and audio to peer connection stream
    _localStream!
        .getTracks()
        .forEach((track) => _rtcPeerConnection?.addTrack(track, _localStream!));

    // Create sdp offer
    var offer = await _rtcPeerConnection!.createOffer();
    await _rtcPeerConnection!.setLocalDescription(offer);

    // Send the sdp information to peer
    var offerMap = {'offer': offer, 'rid': 'roomId'};
    _socket.emit('OFFER_FROM_CLIENT', offerMap);

    // Listen for peer offers
    _socket.on('OFFER_FROM_SERVER', (data) async {
      // streamSocket.addResponse(data.toString());
      var offer = jsonDecode(data) as Map<String, dynamic>;
      await _rtcPeerConnection!.setRemoteDescription(offer['offer']);
      var answer = await _rtcPeerConnection!.createAnswer();
      await _rtcPeerConnection!.setLocalDescription(answer);
      var answerMap = {'answer': answer, 'rid': 'roomId'};
      _socket.emit('ANSWER_FROM_CLIENT', answerMap);
    });

    // Listen for peer answers
    _socket.on('ANSWER_FROM_SERVER', (data) async {
      var answer = jsonDecode(data) as Map<String, dynamic>;
      await _rtcPeerConnection!.setRemoteDescription(answer['answer']);

      // Send ice candidates
      for (RTCIceCandidate candidate in _rtcIceCandidates) {
        var ice = {'ice': candidate, 'rid': 'roomId'};
        _socket.emit('ICE_FROM_CLIENT', ice);
      }
    });

    // Listen for ice candidates
    _socket.on('ICE_FROM_SERVER', (data) async {
      var ice = jsonDecode(data) as Map<String, dynamic>;
      await _rtcPeerConnection!.addCandidate(ice['ice']);
    });

    // Get list of video and audio devices
    _deviceList = await navigator.mediaDevices.enumerateDevices();
    _deviceList.removeWhere((device) => device.deviceId.contains('default'));

    _selectedAudio = _deviceList
        .where((device) =>
            device.kind!.contains('audioinput') &&
            device.label.contains('Built-in'))
        .first;

    _selectedVideo = _deviceList
        .where((device) =>
            device.kind!.contains('videoinput') &&
            device.label.contains('Built-in'))
        .first;
  }

  void toggleMic() {
    _isAudioOn = !_isAudioOn;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isAudioOn;
    });

    setState(() {});
  }

  void toggleCamera() {
    _isVideoOn = !_isVideoOn;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isVideoOn;
    });
    setState(() {});
  }

  void changeInputDevice(MediaDeviceInfo? device, {bool isVideo = true}) async {
    if (device == null) return;
    switch (isVideo) {
      case false:
        {
          _localStream?.getAudioTracks().forEach((track) {
            if (track.label!.contains(device.label)) {
              return;
            }
          });
          break;
        }
      default:
        {
          _localStream?.getVideoTracks().forEach((track) {
            if (track.label!.contains(device.label)) {
              return;
            }
          });
          break;
        }
    }

    var constraints = {
      'audio': {
        'deviceId': (!isVideo) ? device.deviceId : _selectedAudio?.deviceId,
      },
      'video': {
        'deviceId': (isVideo) ? device.deviceId : _selectedVideo?.deviceId,
        'facingMode': _isFrontCameraSelected ? 'user' : 'environment',
      },
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRTCVideoRenderer.srcObject = _localStream;

    setState(() {
      switch (isVideo) {
        case false:
          _selectedAudio = device;
          break;
        default:
          _selectedVideo = device;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                setState(() {});
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.settings),
            );
          },
        ),
        centerTitle: true,
        title: Text(widget.roomController.curr.id),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            const Text('Audio Setting'),
            Visibility(
              visible: _deviceList.isNotEmpty,
              child: DropdownButton<MediaDeviceInfo>(
                value: _selectedAudio,
                onChanged: (MediaDeviceInfo? device) {
                  changeInputDevice(device, isVideo: false);
                },
                items: _deviceList
                    .where((device) => device.kind!.contains('audioinput'))
                    .map<DropdownMenuItem<MediaDeviceInfo>>(
                        (MediaDeviceInfo device) {
                  return DropdownMenuItem<MediaDeviceInfo>(
                    value: device,
                    child: Text(device.label),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Video Setting'),
            Visibility(
              visible: _deviceList.isNotEmpty,
              child: DropdownButton<MediaDeviceInfo>(
                value: _selectedVideo,
                isExpanded: true,
                onChanged: (MediaDeviceInfo? device) {
                  changeInputDevice(device);
                },
                items: _deviceList
                    .where((device) => device.kind!.contains('videoinput'))
                    .map<DropdownMenuItem<MediaDeviceInfo>>(
                        (MediaDeviceInfo device) {
                  return DropdownMenuItem<MediaDeviceInfo>(
                    value: device,
                    child: Text(device.label),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(
              _localRTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              mirror: true,
            ),
          ),
          Expanded(
            child: RTCVideoView(
              _remoteRTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              mirror: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socket.disconnect();
    _socket.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    super.dispose();
  }
}
