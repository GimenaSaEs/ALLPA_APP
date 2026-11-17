class LaborTypes {
  static const List<String> types = [
    'Preparación del terreno',
    'Siembra',
    'Riego',
    'Abonado',
    'Deshierbo',
    'Aporque',
    'Control de plagas',
    'Cosecha',
    'Otra actividad',
  ];

  static String getLaborIconName(String laborType) {
    switch (laborType) {
      case 'Preparación del terreno':
        return 'landscape';
      case 'Siembra':
        return 'eco';
      case 'Riego':
        return 'water_drop';
      case 'Abonado':
        return 'compost';
      case 'Deshierbo':
      case 'Aporque':
        return 'agriculture';
      case 'Control de plagas':
        return 'pest_control';
      case 'Cosecha':
        return 'inventory_2';
      default:
        return 'handyman';
    }
  }
}
