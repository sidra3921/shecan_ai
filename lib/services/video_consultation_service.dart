class VideoConsultationService {
  static final VideoConsultationService _instance = VideoConsultationService._internal();
  factory VideoConsultationService() => _instance;
  VideoConsultationService._internal();

  Future<void> scheduleConsultation() async {}
}
