import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Signaling extends ChangeNotifier {
  MediaStream? _localStream;
  MediaStream? get localStream => _localStream;

  final RTCVideoRenderer _localRTCVideoRenderer = RTCVideoRenderer();
  RTCVideoRenderer get localRTCVideoRenderer => _localRTCVideoRenderer;

  final RTCVideoRenderer _remoteRTCVideoRenderer = RTCVideoRenderer();
  RTCVideoRenderer get remoteRTCVideoRenderer => _remoteRTCVideoRenderer;

  RTCPeerConnection? _rtcPeerConnection;
  RTCPeerConnection? get rtcPeerConnection => _rtcPeerConnection;

  final List<RTCIceCandidate> _rtcIceCandidates = [];
  List<RTCIceCandidate> get rtcIceCandidates => _rtcIceCandidates.toList();

  List<MediaDeviceInfo> _deviceList = [];
  List<MediaDeviceInfo> get deviceList => _deviceList.toList();

  List<MediaDeviceInfo> get audioInputList => deviceList
      .where((device) => device.kind!.contains('audioinput'))
      .toList();

  List<MediaDeviceInfo> get videoInputList => deviceList
      .where((device) => device.kind!.contains('videoinput'))
      .toList();

  MediaDeviceInfo? _selectedAudio;
  MediaDeviceInfo? get selectedAudio => _selectedAudio;

  MediaDeviceInfo? _selectedVideo;
  MediaDeviceInfo? get selectedVideo => _selectedVideo;

  bool _isAudioOn = true;
  bool get isAudioOn => _isAudioOn;

  bool _isVideoOn = true;
  bool get isVideoOn => _isVideoOn;

  final bool _isFrontCameraSelected = true;
  bool get isFrontCameraSelected => _isFrontCameraSelected;

  void onInit() {
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();
    notifyListeners();
  }

  Future<void> getPeerConnection() async {
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
    if (_rtcPeerConnection != null) {
      debugPrint('Peer Connection Created');
    }

    // Listen for ice candidates and add to list
    _rtcPeerConnection!.onIceCandidate =
        (candidate) => _rtcIceCandidates.add(candidate);

    _rtcPeerConnection!.onTrack = (event) {
      debugPrint('event: ${event.streams}');
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
    };

    // Setup user video and audio
    var constraints = {
      'audio': true,
      'video': true,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRTCVideoRenderer.srcObject = _localStream;

    if (_localStream != null) {
      debugPrint('getUserMedia is called');
    }

    // Add user video and audio to peer connection stream
    _localStream!
        .getTracks()
        .forEach((track) => _rtcPeerConnection?.addTrack(track, _localStream!));

    notifyListeners();
  }

  Future<void> makeOffer(io.Socket socket) async {
    // Create sdp offer
    var offer = await _rtcPeerConnection!.createOffer();
    await _rtcPeerConnection!.setLocalDescription(offer);

    // Send the sdp information to peer
    var offerMap = {'offer': offer.toMap(), 'rid': 'roomId'};
    socket.emit('OFFER_FROM_CLIENT', offerMap);

    debugPrint('Offer created and sent to peer');
    notifyListeners();
  }

  void setOfferMakeAnswer(io.Socket socket, Map<String, dynamic> data) async {
    try {
      await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));
      var answer = await _rtcPeerConnection!.createAnswer();
      await _rtcPeerConnection!.setLocalDescription(answer);
      var answerMap = {'answer': answer.toMap(), 'rid': 'roomId'};
      socket.emit('ANSWER_FROM_CLIENT', answerMap);

      debugPrint('received peer offer and answer is sent to peer');
      notifyListeners();
    } catch (e) {
      debugPrint('setOfferMakeAnswer: ${e.toString()}');
    }
  }

  void setAnswerMakeIce(io.Socket socket, Map<String, dynamic> data) async {
    try {
      await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));

      // Send ice candidates
      for (RTCIceCandidate candidate in _rtcIceCandidates) {
        var ice = {'ice': candidate.toMap(), 'rid': 'roomId'};
        socket.emit('ICE_FROM_CLIENT', ice);
      }

      debugPrint('received peer answer and ice is sent to peer');
      notifyListeners();
    } catch (e) {
      debugPrint('setAnswerMakeIce: ${e.toString()}');
    }
  }

  void addIce(Map<String, dynamic> data) async {
    try {
      await _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          data['ice']['candidate'],
          data['ice']['sdpMid'],
          data['ice']['sdpMLineIndex']));

      debugPrint('Ice added to peer connection');
      notifyListeners();
    } catch (e) {
      debugPrint('addIce: ${e.toString()}');
    }
  }

  Future<void> getAudioVideoDeviceList() async {
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

    debugPrint('Device list is set');
    notifyListeners();
  }

  void toggleMic() {
    _isAudioOn = !_isAudioOn;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isAudioOn;
    });

    notifyListeners();
  }

  void toggleCamera() {
    _isVideoOn = !_isVideoOn;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isVideoOn;
    });

    notifyListeners();
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

    switch (isVideo) {
      case false:
        _selectedAudio = device;
        break;
      default:
        _selectedVideo = device;
        break;
    }

    debugPrint('Change video/audio device settings');
    notifyListeners();
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    super.dispose();
  }
}
