class Spot {
  final String title;
  final String location;
  final String image;
  final String description;
  final String touristTitle;
  final String touristLocation;
  final String touristDescription;

  const Spot({
    required this.title,
    required this.location,
    required this.image,
    required this.description,
    required this.touristTitle,
    required this.touristLocation,
    required this.touristDescription,
  });

  factory Spot.fromMap(Map<String, String> map) {
    return Spot(
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      touristTitle: map['tourist_title'] ?? '',
      touristLocation: map['tourist_location'] ?? '',
      touristDescription: map['tourist_description'] ?? '',
    );
  }
} 