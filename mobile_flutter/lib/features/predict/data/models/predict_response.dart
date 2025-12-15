class PredictResponse {
  PredictResponse({
    required this.approved,
    this.probability,
  });

  final bool approved;
  final double? probability;

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      approved: json['approved'] as bool,
      probability: json['probability'] != null
          ? (json['probability'] as num).toDouble()
          : null,
    );
  }
}

