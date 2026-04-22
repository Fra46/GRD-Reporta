class EventModel {
  final String id;

  // Ubicación
  final String municipio;
  final String corregimiento;
  final String ubicacion;

  // Evento
  final String tipoEvento;
  final String descripcion;
  final String criticidad;

  // Fechas
  final DateTime fechaEvento;
  final DateTime fechaRegistro;

  // Afectación
  final bool hayAfectacion;
  final int personasAfectadas;
  final int familiasAfectadas;
  final int familiasIndirectas;

  final int viviendasAfectadas;
  final int viviendasDestruidas;

  final double hectareasAfectadas;

  // Activación institucional
  final bool requiereEdan;
  final bool escaladoCmgrd;

  // Ayudas
  final bool apoyoUngrd;
  final bool apoyoDepartamento;
  final bool apoyoMunicipio;

  // Control
  final String estado;
  final String observacion;

  // Auditoría
  final String usuarioId;
  final String usuarioNombre;

  EventModel({
    required this.id,

    required this.municipio,
    this.corregimiento = '',
    this.ubicacion = '',

    required this.tipoEvento,
    required this.descripcion,
    required this.criticidad,

    required this.fechaEvento,
    required this.fechaRegistro,

    required this.hayAfectacion,
    this.personasAfectadas = 0,
    this.familiasAfectadas = 0,
    this.familiasIndirectas = 0,

    this.viviendasAfectadas = 0,
    this.viviendasDestruidas = 0,

    this.hectareasAfectadas = 0,

    required this.requiereEdan,
    required this.escaladoCmgrd,

    this.apoyoUngrd = false,
    this.apoyoDepartamento = false,
    this.apoyoMunicipio = false,

    this.estado = 'abierto',
    this.observacion = '',

    required this.usuarioId,
    required this.usuarioNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'municipio': municipio,
      'corregimiento': corregimiento,
      'ubicacion': ubicacion,

      'tipoEvento': tipoEvento,
      'descripcion': descripcion,
      'criticidad': criticidad,

      'fechaEvento':
          fechaEvento.toIso8601String(),
      'fechaRegistro':
          fechaRegistro.toIso8601String(),

      'hayAfectacion':
          hayAfectacion,

      'personasAfectadas':
          personasAfectadas,

      'familiasAfectadas':
          familiasAfectadas,

      'familiasIndirectas':
          familiasIndirectas,

      'viviendasAfectadas':
          viviendasAfectadas,

      'viviendasDestruidas':
          viviendasDestruidas,

      'hectareasAfectadas':
          hectareasAfectadas,

      'requiereEdan':
          requiereEdan,

      'escaladoCmgrd':
          escaladoCmgrd,

      'apoyoUngrd':
          apoyoUngrd,

      'apoyoDepartamento':
          apoyoDepartamento,

      'apoyoMunicipio':
          apoyoMunicipio,

      'estado': estado,
      'observacion':
          observacion,

      'usuarioId': usuarioId,
      'usuarioNombre':
          usuarioNombre,
    };
  }

  factory EventModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return EventModel(
      id: map['id'] ?? '',

      municipio:
          map['municipio'] ?? '',

      corregimiento:
          map['corregimiento'] ?? '',

      ubicacion:
          map['ubicacion'] ?? '',

      tipoEvento:
          map['tipoEvento'] ?? '',

      descripcion:
          map['descripcion'] ?? '',

      criticidad:
          map['criticidad'] ?? 'baja',

      fechaEvento:
          DateTime.parse(
        map['fechaEvento'],
      ),

      fechaRegistro:
          DateTime.parse(
        map['fechaRegistro'],
      ),

      hayAfectacion:
          map['hayAfectacion'] ??
              false,

      personasAfectadas:
          map['personasAfectadas'] ??
              0,

      familiasAfectadas:
          map['familiasAfectadas'] ??
              0,

      familiasIndirectas:
          map['familiasIndirectas'] ??
              0,

      viviendasAfectadas:
          map['viviendasAfectadas'] ??
              0,

      viviendasDestruidas:
          map['viviendasDestruidas'] ??
              0,

      hectareasAfectadas:
          (map['hectareasAfectadas'] ??
                  0)
              .toDouble(),

      requiereEdan:
          map['requiereEdan'] ??
              false,

      escaladoCmgrd:
          map['escaladoCmgrd'] ??
              false,

      apoyoUngrd:
          map['apoyoUngrd'] ??
              false,

      apoyoDepartamento:
          map['apoyoDepartamento'] ??
              false,

      apoyoMunicipio:
          map['apoyoMunicipio'] ??
              false,

      estado:
          map['estado'] ??
              'abierto',

      observacion:
          map['observacion'] ??
              '',

      usuarioId:
          map['usuarioId'] ?? '',

      usuarioNombre:
          map['usuarioNombre'] ?? '',
    );
  }
}