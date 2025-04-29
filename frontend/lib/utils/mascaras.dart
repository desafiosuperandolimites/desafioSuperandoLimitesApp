part of '../views/env.dart';

class Mascaras {
  // Controlador para máscara de CPF
  static MaskedTextController cpfController() {
    return MaskedTextController(mask: '000.000.000-00');
  }

  // Controlador para máscara de CNPJ
  static MaskedTextController cnpjController() {
    return MaskedTextController(mask: '00.000.000/0000-00');
  }

  // Controlador para máscara de CEP
  static MaskedTextController cepController() {
    return MaskedTextController(mask: '00000-000');
  }

  // Controlador para máscara de telefone
  static MaskedTextController cellphoneController() {
    return MaskedTextController(mask: '(00) 00000-0000');
  }

  // Controlador para máscara de altura (x.xx)
  static MaskedTextController alturaController() {
    return MaskedTextController(mask: '0.00');
  }

  static MaskedTextController kmPercorrido() {
    return MaskedTextController(mask: '00.00');
  }

  // Controlador para máscara de data (xxx.x)
  static MaskedTextController dateController() {
    return MaskedTextController(mask: '00/00/0000');
  }

  static MaskedTextController taxaInscricaoController() {
    final controller = MaskedTextController(mask: '00.00');

    // Definir o valor inicial como "1.00" para não forçar o "0" à esquerda
    controller.text = '1.00';

    controller.addListener(() {
      // Verifica se o usuário já digitou um valor numérico completo
      double? currentValue = double.tryParse(controller.text);

      if (currentValue != null) {
        if (currentValue > 99.99) {
          // Se o valor for maior que 99.99, define o limite superior
          controller.text = '99.99';
        } else if (currentValue < 1.00 && controller.text.length >= 4) {
          // Se o valor for menor que 1.00 e o campo tem pelo menos 4 caracteres, define o limite mínimo
          controller.text = '1.00';
        }

        // Ajusta a posição do cursor ao final do texto atualizado
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });

    return controller;
  }
}

class MascaraPeso extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^\d{0,3}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    // If the new value doesn't match, return the old value to prevent clearing
    return oldValue;
  }
}
