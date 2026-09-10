/// Un veicolo del garage.
class Vehicle {
  final String id;
  String name;
  String plate;

  Vehicle({required this.id, required this.name, this.plate = ''});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plate': plate,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        name: json['name'] as String,
        plate: json['plate'] as String? ?? '',
      );
}
