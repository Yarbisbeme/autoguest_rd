import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _service = VideoService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<VideoModel> _videos = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<VideoModel> get videos => _videos;

  Future<void> cargarVideos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _videos = await _service.obtenerVideos();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _videos = [];
    _errorMessage = '';
    notifyListeners();
  }
}