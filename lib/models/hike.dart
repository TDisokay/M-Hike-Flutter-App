class Hike {
  final int? id;
  final String name;
  final String location;
  final String hikeDate;
  final String parkingAvailable;
  final double length;
  final String difficulty;
  final String? description;

  const Hike({
    this.id,
    required this.name,
    required this.location,
    required this.hikeDate,
    required this.parkingAvailable,
    required this.length,
    required this.difficulty,
    this.description,
  });

  // Create Hike from database data
  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      hikeDate: map['hike_date'] as String,
      parkingAvailable: map['parking_available'] as String,
      length: map['length'] as double,
      difficulty: map['difficulty'] as String,
      description: map['description'] as String?,
    );
  }

  // Convert Hike to database format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'hike_date': hikeDate,
      'parking_available': parkingAvailable,
      'length': length,
      'difficulty': difficulty,
      'description': description,
    };
  }
}
