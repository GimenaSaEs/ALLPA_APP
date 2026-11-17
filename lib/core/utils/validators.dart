class Validators {
  static String? requiredField(
    String? value, {
    String message = 'Este campo es obligatorio',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(
    String? value, {
    String message = 'Ingrese un número mayor a 0',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  static String? nonNegativeNumber(
    String? value, {
    String message = 'Ingrese un número válido (mayor o igual a 0)',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return message;
    }
    return null;
  }

  static String? optionalNonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return 'Ingrese un número mayor o igual a 0';
    }
    return null;
  }

  static String? validateAreaAgainstTerreno(
    String? areaCultivoStr,
    double areaTerreno,
  ) {
    final err = positiveNumber(
      areaCultivoStr,
      message: 'La superficie debe ser mayor a 0',
    );
    if (err != null) return err;
    final areaCultivo = double.parse(areaCultivoStr!.replaceAll(',', '.'));
    if (areaCultivo > areaTerreno * 1.05) {
      // tolerancia del 5% o aviso
      return 'La superficie ($areaCultivo ha) excede el área del terreno ($areaTerreno ha)';
    }
    return null;
  }
}
