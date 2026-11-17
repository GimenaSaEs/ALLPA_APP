class CropTypes {
  static const List<String> speciesList = [
    'Papa',
    'Maíz',
    'Cebada',
    'Trigo',
    'Haba',
    'Arveja',
    'Olluco',
    'Quinua',
    'Mashua',
    'Oca',
    'Tarwi',
    'Pastos cultivados',
    'Otro cultivo',
  ];

  static const Map<String, List<String>> varietiesMap = {
    'Papa': [
      'Canchán',
      'Yungay',
      'Peruanita',
      'Amarilla Tumbay',
      'Huayro',
      'Blanca',
      'Nativa / Mixta',
      'Otra variedad',
    ],
    'Maíz': [
      'Blanco común',
      'Choclero',
      'Amarillo duro',
      'Morado',
      'San Jerónimo',
      'Otra variedad',
    ],
    'Cebada': ['Común del valle', 'Centenario', 'Criolla', 'Otra variedad'],
    'Trigo': ['Andino', 'Centenario', 'Gavilan', 'Criollo', 'Otra variedad'],
    'Haba': ['Verde común', 'Gigante', 'Criolla', 'Otra variedad'],
    'Arveja': ['Usui', 'Remate', 'Criolla', 'Otra variedad'],
    'Olluco': ['Amarillo', 'Rosado', 'Criollo'],
    'Quinua': ['Blanca de Junín', 'Rosada', 'Amarilla'],
    'Otro cultivo': ['Variedad local', 'Otra variedad'],
  };
}
