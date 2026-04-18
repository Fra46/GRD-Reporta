enum SyncStatus { local, synced, syncing, error }

enum RolUsuario {
  reportante,
  tecnico,
  directivo;

  String get label {
    switch (this) {
      case RolUsuario.reportante: return 'Reportante de Campo';
      case RolUsuario.tecnico:    return 'Técnico ODGRD';
      case RolUsuario.directivo:  return 'Directivo';
    }
  }

  static RolUsuario fromString(String v) =>
      RolUsuario.values.firstWhere((e) => e.name == v,
          orElse: () => RolUsuario.reportante);
}

enum EstadoEvento {
  abierto,
  enValidacion,
  cerrado;

  String get label {
    switch (this) {
      case EstadoEvento.abierto:      return 'Abierto';
      case EstadoEvento.enValidacion: return 'En Validación';
      case EstadoEvento.cerrado:      return 'Cerrado';
    }
  }

  // Firestore guarda 'en_validacion', no 'enValidacion'
  String get firestoreKey {
    if (this == EstadoEvento.enValidacion) return 'en_validacion';
    return name;
  }

  static EstadoEvento fromString(String v) {
    if (v == 'en_validacion' || v == 'enValidacion') {
      return EstadoEvento.enValidacion;
    }
    return EstadoEvento.values.firstWhere((e) => e.name == v,
        orElse: () => EstadoEvento.abierto);
  }
}

enum NivelAlerta {
  verde, amarillo, naranja, rojo;

  String get label {
    switch (this) {
      case NivelAlerta.verde:    return 'Verde';
      case NivelAlerta.amarillo: return 'Amarillo';
      case NivelAlerta.naranja:  return 'Naranja';
      case NivelAlerta.rojo:     return 'Rojo';
    }
  }

  static NivelAlerta fromString(String v) =>
      NivelAlerta.values.firstWhere((e) => e.name == v,
          orElse: () => NivelAlerta.verde);
}

enum TipoEvento {
  inundacion,
  deslizamiento,
  incendioForestal,
  incendioEstructural,
  vendaval,
  sequia,
  granizada,
  otro;

  String get label {
    const labels = {
      'inundacion':          'Inundación',
      'deslizamiento':       'Deslizamiento',
      'incendioForestal':    'Incendio Forestal',
      'incendioEstructural': 'Incendio Estructural',
      'vendaval':            'Vendaval',
      'sequia':              'Sequía',
      'granizada':           'Granizada',
      'otro':                'Otro',
    };
    return labels[name] ?? name;
  }

  static TipoEvento fromString(String v) =>
      TipoEvento.values.firstWhere((e) => e.name == v,
          orElse: () => TipoEvento.otro);
}

enum TipoEvidencia { foto, video, documento }

enum EspecieAnimal {
  bovino, porcino, aviar, caprino, equino, piscicola, otro;

  String get label {
    const labels = {
      'bovino': 'Bovino', 'porcino': 'Porcino', 'aviar': 'Aviar',
      'caprino': 'Caprino', 'equino': 'Equino',
      'piscicola': 'Piscícola', 'otro': 'Otro',
    };
    return labels[name] ?? name;
  }

  static EspecieAnimal fromString(String v) =>
      EspecieAnimal.values.firstWhere((e) => e.name == v,
          orElse: () => EspecieAnimal.otro);
}