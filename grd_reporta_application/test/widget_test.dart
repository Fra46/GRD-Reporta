import 'package:flutter_test/flutter_test.dart';
import 'package:grd_reporta_application/models/event_model.dart';

void main() {
  test('EventModel copyWith preserves unchanged fields', () {
    final original = EventModel(
      id: '123',
      municipio: 'Valledupar',
      tipoEvento: 'Incendio',
      descripcion: 'Fuego en zona rural',
      criticidad: 'alta',
      fechaEvento: DateTime(2026, 4, 24),
      fechaRegistro: DateTime(2026, 4, 24),
      hayAfectacion: true,
      requiereEdan: true,
      escaladoCmgrd: true,
      usuarioId: 'user-1',
      usuarioNombre: 'Prueba',
    );

    final updated = original.copyWith(
      municipio: 'Aguachica',
      estado: 'cerrado',
    );

    expect(updated.id, original.id);
    expect(updated.tipoEvento, original.tipoEvento);
    expect(updated.municipio, 'Aguachica');
    expect(updated.estado, 'cerrado');
    expect(updated.descripcion, original.descripcion);
  });
}
