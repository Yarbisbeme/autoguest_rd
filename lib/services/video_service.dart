import '../models/video_model.dart';
import 'api_service.dart';

class VideoService {
  final ApiService _apiService = ApiService();

  Future<List<VideoModel>> obtenerVideos() async {
    final response = await _apiService.get('videos');

    print('RESPUESTA GET VIDEOS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando videos');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }
}