import 'package:flutter/material.dart';
import 'package:imgsrc/gallery_repository.dart';
import 'package:imgsrc/model/gallery_item.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:video_player/video_player.dart';

class GalleryImagePage extends StatefulWidget {
  GalleryImagePage(
    this.item, {
    Key key,
  }) : super(key: key);

  final GalleryItem item;

  @override
  _GalleryImagePageState createState() => _GalleryImagePageState();
}

class _GalleryImagePageState extends State<GalleryImagePage> {
  VideoPlayerController _controller;

  @override
  void dispose() {
    if (_controller != null) {
      _controller.pause();
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.item.link;
    if (widget.item.isAlbum) {
      imageUrl = widget.item.images[0].pageUrl();
    }

    if (imageUrl.contains(".mp4")) {
      var videoController = VideoPlayerController.network(imageUrl);
      var player = VideoPlayer(videoController);

      setState(() {
        _controller = videoController;
        _controller.setLooping(true);
        _controller.setVolume(0);

        _controller.initialize().then((_) {
          _controller.play();
        });
      });
      return player;
    } else {
      return Image.network(imageUrl);
    }
  }
}

class GalleryAlbumPage extends StatefulWidget {
  GalleryAlbumPage(this.item, {Key key}) : super(key: key);

  final GalleryItem item;

  @override
  _GalleryAlbumPageState createState() => _GalleryAlbumPageState();
}

class _GalleryAlbumPageState extends State<GalleryAlbumPage> {
  int _position = 0;
  List<GalleryItem> _images;

  //note: if the album is large enough, we might have to manually dispose as user swipes through...
  Map<int, VideoPlayerController> _controllers = new Map();

  @override
  void initState() {
    super.initState();

    this._images = widget.item.images;
    _loadAlbumDetails();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadAlbumDetails() {
    var repository = GalleryRepository();
    repository.getAlbumDetails(widget.item.id).then((it) {
      setState(() {
        if (it.isOk()) {
          this._images = it.body.images;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = this._images[_position].pageUrl();

    if (imageUrl.contains(".mp4")) {
      VideoPlayerController controller = _controllers[_position];
      VideoPlayer player = new VideoPlayer(controller);

      if (controller == null) {
        VideoPlayerController controller = VideoPlayerController.network(imageUrl);
        player = VideoPlayer(controller);
        setState(() {
          _controllers[_position] = controller;
          controller.setLooping(true);
          controller.setVolume(0);

          controller.initialize().then((_) {
            controller.play();
          });
        });
      }
      return player;
    } else {
      return Image.network(imageUrl);
    }
  }

  void _onSwipeUp() {
    if (_position < _images.length - 1) {
      setState(() {
        _position++;
      });
    }
  }

  void _onSwipeDown() {
    if (_position > 0) {
      setState(() {
        _position--;
      });
    }
  }
}