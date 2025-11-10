class Observation {
  final int? id;
  final String observation;
  final String observationTime;
  final String? comments;
  final int hikeId; // Foreign Key

  const Observation({
    this.id,
    required this.observation,
    required this.observationTime,
    this.comments,
    required this.hikeId,
  });

  // fromMap factory
  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id'] as int?,
      observation: map['observation'] as String,
      observationTime: map['observation_time'] as String,
      comments: map['comments'] as String?,
      hikeId: map['hike_id'] as int,
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'observation': observation,
      'observation_time': observationTime,
      'comments': comments,
      'hike_id': hikeId,
    };
  }
}
