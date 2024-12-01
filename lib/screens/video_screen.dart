// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class VideoScreen extends StatefulWidget {
//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   void _initializeVideoPlayer() async {
//     _controller = VideoPlayerController.network(
//       'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
//     );

//     // Initialize the controller and update the state
//     await _controller.initialize().then((_) {
//       setState(() {
//         _isInitialized = true;  // Set initialized flag to true
//       });
//     }).catchError((error) {
//       print('Error initializing video: $error');
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Testing Screen'),
//       ),
//       body: Center(
//         child: _isInitialized
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   ),
//                   VideoProgressIndicator(_controller, allowScrubbing: true),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
//                         onPressed: () {
//                           setState(() {
//                             _controller.value.isPlaying
//                                 ? _controller.pause()
//                                 : _controller.play();
//                           });
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.stop),
//                         onPressed: () {
//                           setState(() {
//                             _controller.pause();
//                             _controller.seekTo(Duration.zero);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               )
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
// }
