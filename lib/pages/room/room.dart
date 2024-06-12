import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../state/auth_state.dart';
import '../../state/room_state.dart';
import 'signaling.dart';

class StreamSocket {
  final _socketResponse = StreamController<Map<String, dynamic>>();

  void Function(Map<String, dynamic>) get addResponse =>
      _socketResponse.sink.add;

  Stream<Map<String, dynamic>> get getResponse => _socketResponse.stream;

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
  Signaling signalingController = Signaling();
  StreamSocket streamSocket = StreamSocket();
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    roomController = widget.roomController;
    signalingController.onInit();

    // Socket
    if (kIsWeb) {
      socket = io.io(
        'http://localhost:3000',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );
    } else {
      if (Platform.isAndroid) {
        // var baseUrl = 'http://10.0.2.2:3000';
        // var baseUrl = 'http://localhost:3000';
        var baseUrl = 'http://192.168.0.19:3000';
        socket = io.io(
          baseUrl,
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build(),
        );
      } else if (Platform.isIOS) {
        socket = io.io(
          'http://127.0.0.1:3000',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build(),
        );
      }
    }

    // Initial socket connection when entering the room
    socket.connect();

    socket.onConnect((_) {
      var message = {
        'rid': 'roomId',
        'uid': 'userId',
      };

      socket.emit('JOIN_ROOM', message);
    });

    // Check if socket is connected to server
    socket.on('CONNECTED', (data) {
      debugPrint('CONNECTED: $data');

      // Make user media streams and offers for peers
      onInit();
    });

    // Listen for peer offers
    socket.on('OFFER_FROM_SERVER', (data) {
      streamSocket.addResponse({'event': 'OFFER_FROM_SERVER', 'data': data});
      // signalingController.setOfferMakeAnswer(socket, data);
    });

    // Listen for peer answers
    socket.on('ANSWER_FROM_SERVER', (data) {
      streamSocket.addResponse({'event': 'ANSWER_FROM_SERVER', 'data': data});
      // signalingController.setAnswerMakeIce(socket, data);
    });

    // Listen for ice candidates
    socket.on('ICE_FROM_SERVER', (data) {
      streamSocket.addResponse({'event': 'ICE_FROM_SERVER', 'data': data});
      // signalingController.addIce(data);
    });

    // Check disconnection state
    socket.onDisconnect((_) => debugPrint('disconnect'));
  }

  void onInit() async {
    await signalingController.getPeerConnection();
    await signalingController.makeOffer(socket);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
        stream: streamSocket.getResponse,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          // debugPrint(snapshot.data.toString());

          switch (snapshot.data!['event']) {
            case 'OFFER_FROM_SERVER':
              signalingController.setOfferMakeAnswer(
                  socket, snapshot.data!['data']);
              break;
            case 'ANSWER_FROM_SERVER':
              signalingController.setAnswerMakeIce(
                  socket, snapshot.data!['data']);
              break;
            case 'ICE_FROM_SERVER':
              signalingController.addIce(snapshot.data!['data']);
              break;
            default:
              debugPrint(snapshot.data.toString());
          }

          return Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () async {
                      await signalingController.getAudioVideoDeviceList();

                      if (context.mounted) {
                        Scaffold.of(context).openDrawer();
                      }
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
                  ListenableBuilder(
                      listenable: signalingController,
                      builder: (context, child) {
                        return Visibility(
                          visible: signalingController.deviceList.isNotEmpty,
                          child: DropdownButton<MediaDeviceInfo>(
                            value: signalingController.selectedAudio,
                            onChanged: (MediaDeviceInfo? device) {
                              signalingController.changeInputDevice(device,
                                  isVideo: false);
                            },
                            items: signalingController.audioInputList
                                .map<DropdownMenuItem<MediaDeviceInfo>>(
                                    (MediaDeviceInfo device) {
                              return DropdownMenuItem<MediaDeviceInfo>(
                                value: device,
                                child: Text(device.label),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                  const SizedBox(height: 16),
                  const Text('Video Setting'),
                  ListenableBuilder(
                      listenable: signalingController,
                      builder: (context, child) {
                        return Visibility(
                          visible: signalingController.deviceList.isNotEmpty,
                          child: DropdownButton<MediaDeviceInfo>(
                            value: signalingController.selectedVideo,
                            isExpanded: true,
                            onChanged: (MediaDeviceInfo? device) {
                              signalingController.changeInputDevice(device);
                            },
                            items: signalingController.videoInputList
                                .map<DropdownMenuItem<MediaDeviceInfo>>(
                                    (MediaDeviceInfo device) {
                              return DropdownMenuItem<MediaDeviceInfo>(
                                value: device,
                                child: Text(device.label),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                ],
              ),
            ),
            body: ListenableBuilder(
                listenable: signalingController,
                builder: (context, child) {
                  return Column(
                    children: [
                      Expanded(
                        child: RTCVideoView(
                          signalingController.localRTCVideoRenderer,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                          mirror: true,
                        ),
                      ),
                      Expanded(
                        child: RTCVideoView(
                          signalingController.remoteRTCVideoRenderer,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                          mirror: true,
                        ),
                      ),
                    ],
                  );
                }),
          );
        });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
}
