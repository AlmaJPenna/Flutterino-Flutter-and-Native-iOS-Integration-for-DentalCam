import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

bool _isRecording = false;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TelecamerinApp',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: S700cView(),
    );
  }
}

class S700cView extends StatefulWidget {
  const S700cView({super.key});

  @override
  State<S700cView> createState() => _S700cViewState();
}

class _S700cViewState extends State<S700cView> {
  static const platform = MethodChannel('com.example.flutterino/stream');
  bool isExporting = false;
  double angle = 0.0;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  asyncInit() async {
    platform.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'photoCaptured':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto scattata"),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'noFrameAvailable':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nessun frame disponibile"),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'photoPreview':
        Uint8List imageData = call.arguments;
        bool? saveResult = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Anteprima',
                style: TextStyle(fontSize: 16),
              ),
              content: Image.memory(imageData),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Salva',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text(
                    'Annulla',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
        if (saveResult ?? false) {
          await _saveImage(imageData);
        }
        break;
      case 'videoPreview':
        Uint8List videoData = call.arguments;
        bool? saveResult = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Salva il video?'),
              content: const Text('Vuoi salvare il video registrato?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Sì'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (saveResult ?? false) {
          await _saveVideo(videoData);
        }
        break;
      case 'RECORDING_STARTED':
        setState(() {
          _isRecording = true;
          _startTimer();
        });
        break;
      case 'RECORDING_STOPPED':
        setState(() {
          _isRecording = false;
          _stopTimer();
        });
        break;
      default:
        throw PlatformException(
            code: "Not Implemented",
            message: "Method ${call.method} not implemented.");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveImage(Uint8List imageData) async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/temp_image.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageData);
      bool? result;
      try {
        result = await GallerySaver.saveImage(imagePath);
      } catch (e) {
        //print("[DEBUG] Error saving image to gallery: $e");
      }

      if (result ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Immagine salvata con successo"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Salvataggio immagine fallito"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore durante il salvataggio dell'immagine: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveVideo(Uint8List videoData) async {
    try {
      final directory = await getTemporaryDirectory();
      final videoPath = '${directory.path}/dental_Cam.mp4';
      final file = File(videoPath);
      await file.writeAsBytes(videoData);
      bool? result;
      try {
        result = await GallerySaver.saveVideo(videoPath);
      } catch (e) {
        //print("[DEBUG] Error saving video to gallery: $e");
      }

      if (result ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video salvato con successo"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Salvataggio video fallito"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore durante il salvataggio del video: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _foto() async {
    try {
      await platform.invokeMethod('foto_ios');
    } catch (e) {
      //print("Failed to capture photo: '${e}'.");
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _recordDuration = 0; // Reset the timer
      });
      await platform.invokeMethod('startVideoRecording');
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await platform.invokeMethod('stopVideoRecording');
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop recording: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isExporting)
              const Center(
                  child: SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        color: Colors.teal,
                      )))
            else ...[
              Expanded(
                child: Center(
                  child: Platform.isIOS
                      ? const UiKitView(
                          viewType: 'my_uikit_view',
                        )
                      : const AndroidView(
                          viewType: 'mjpeg-view-type',
                        ),
                ),
              ),
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _formatDuration(_recordDuration),
                    style: TextStyle(color: Colors.red, fontSize: 24),
                  ),
                ),
              _FinalButtonRow(
                fotoCallBack: () {
                  _foto();
                },
                videoCallBack: _toggleRecording,
              )
            ],
          ],
        ),
      ),
    );
  }
}

_CameraMode _mode = _CameraMode.photo;

class _FinalButtonRow extends StatefulWidget {
  const _FinalButtonRow(
      {required this.fotoCallBack, required this.videoCallBack});
  final VoidCallback fotoCallBack;
  final Function() videoCallBack;
  @override
  State<_FinalButtonRow> createState() => __FinalButtonRowState();
}

class __FinalButtonRowState extends State<_FinalButtonRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: InkWell(
                        enableFeedback: false,
                        highlightColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          if (Platform.isAndroid) {
                            const OpenSettingsPlusAndroid().wifi();
                          } else if (Platform.isIOS) {
                            const OpenSettingsPlusIOS().wifi();
                          }
                        },
                        child: Icon(
                          Icons.wifi,
                          color: Colors.white.withOpacity(0.7),
                          size: 35,
                        ),
                      ),
                    )),
              ),
              InkWell(
                enableFeedback: false,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  if (_mode == _CameraMode.photo) {
                    widget.fotoCallBack();
                  } else {
                    await widget.videoCallBack();
                  }
                },
                child: Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      shape: BoxShape.circle),
                ),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    enableFeedback: false,
                                    highlightColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    onTap: () {
                                      _mode = _CameraMode.photo;
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: _mode == _CameraMode.photo
                                          ? Colors.teal
                                          : Colors.white.withOpacity(0.7),
                                      size: 35,
                                    ),
                                  ),
                                  Text(
                                    'Foto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _mode == _CameraMode.photo
                                            ? Colors.teal
                                            : Colors.black),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                InkWell(
                                  enableFeedback: false,
                                  highlightColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: () {
                                    _mode = _CameraMode.video;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: _mode == _CameraMode.video
                                        ? Colors.teal
                                        : Colors.white.withOpacity(0.7),
                                    size: 35,
                                  ),
                                ),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _mode == _CameraMode.video
                                          ? Colors.teal
                                          : Colors.black),
                                )
                              ],
                            ),
                          ],
                        ))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CameraMode {
  photo,
  video;
}
