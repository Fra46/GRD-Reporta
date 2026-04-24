class EvidenceModel {
  final String id;
  final String eventoId;
  final String url;
  final String? descripcion;
  final DateTime fechaCaptura;
  final String subidoPor;

  EvidenceModel({
    required this.id,
    required this.eventoId,
    required this.url,
    this.descripcion,
    required this.fechaCaptura,
    required this.subidoPor,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'eventoId': eventoId,
        'url': url,
        'descripcion': descripcion ?? '',
        'fechaCaptura': fechaCaptura.toIso8601String(),
        'subidoPor': subidoPor,
      };

  factory EvidenceModel.fromMap(Map<String, dynamic> map) => EvidenceModel(
        id: map['id'] ?? '',
        eventoId: map['eventoId'] ?? '',
        url: map['url'] ?? '',
        descripcion: map['descripcion'],
        fechaCaptura: DateTime.parse(map['fechaCaptura']),
        subidoPor: map['subidoPor'] ?? '',
      );
}