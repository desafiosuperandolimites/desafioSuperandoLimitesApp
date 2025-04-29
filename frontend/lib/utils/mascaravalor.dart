part of '../views/env.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Permite apenas dígitos e um ponto decimal
    if (RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(text)) {
      // Verifica o número de casas decimais permitidas
      if (text.contains('.') &&
          text.substring(text.indexOf('.') + 1).length > decimalRange) {
        return oldValue;
      }
      return newValue;
    }

    // Caso contrário, retorna o valor antigo
    return oldValue;
  }
}
