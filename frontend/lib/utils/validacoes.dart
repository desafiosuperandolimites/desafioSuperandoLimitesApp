part of '../views/env.dart';

class Validacoes {
  // Nome validation function
  static String? validateNome(String nome) {
    if (nome.isEmpty) {
      return 'Por favor, insira seu nome completo.';
    }
    return null;
  }

  // Validação de CPF (Simples)
  static String? validateCPF(String cpf) {
    String cpfSanitized = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfSanitized.length != 11) {
      return 'CPF inválido. Deve conter 11 dígitos.';
    }
    return null;
  }

  // Validação de CNPJ (Simples)
  static String? validateCNPJ(String cnpj) {
    String cnpjSanitized = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cnpjSanitized.length != 14) {
      return 'CNPJ inválido. Deve conter 14 dígitos.';
    }
    return null;
  }

  // Validação de CEP (Simples)
  static String? validateCEP(String cep) {
    String cepSanitized = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cepSanitized.length != 8) {
      return 'CEP inválido. Deve conter 8 dígitos.';
    }
    return null;
  }

  // Validação de telefone
  static String? validateCellphone(String phone) {
    String phoneSanitized = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneSanitized.length != 11) {
      return 'Número de telefone inválido. Deve conter 11 dígitos.';
    }
    return null;
  }

  // Validação de e-mail usando regex
  static String? validateEmail(String email) {
    String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  // Validação de senha com requisitos de complexidade
  static String? validatePassword(String senha) {
    if (senha.isEmpty) {
      return 'Por favor, insira uma senha.';
    }
    if (senha.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(senha)) {
      return 'A senha precisa ter pelo menos uma letra maiúscula.';
    }
    if (!RegExp(r'[a-z]').hasMatch(senha)) {
      return 'A senha precisa ter pelo menos uma letra minúscula.';
    }
    if (!RegExp(r'[0-9]').hasMatch(senha)) {
      return 'A senha precisa ter pelo menos um número.';
    }
    if (!RegExp(r'[\W_]').hasMatch(senha)) {
      return 'A senha precisa ter pelo menos um caractere especial.';
    }
    return null;
  }

// Validação de data no formato DD/MM/AAAA
  static String? validateDate(String date) {
    String datePattern = r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$';
    if (!RegExp(datePattern).hasMatch(date)) {
      return 'Por favor, insira uma data válida no formato DD/MM/AAAA.';
    }

    try {
      // Tentar converter a string em uma data válida
      List<String> parts = date.split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime parsedDate = DateTime(year, month, day);

      // Verificar se a data é válida (dia e mês corretos)
      if (parsedDate.day != day ||
          parsedDate.month != month ||
          parsedDate.year != year) {
        return 'Data inválida.';
      }
    } catch (e) {
      return 'Data inválida.';
    }

    return null;
  }

  // Validação de altura (Simples)
  static String? validateAltura(String altura) {
    String alturaSanitized = altura.replaceAll(RegExp(r'[^\d.]'), '');
    if (alturaSanitized.isEmpty || double.tryParse(alturaSanitized)! <= 0) {
      return 'Altura inválida. Informe um valor positivo.';
    }
    return null;
  }

  // Validação de peso (Simples)
  static String? validatePeso(String peso) {
    String pesoSanitized = peso.replaceAll(RegExp(r'[^\d.]'), '');
    if (pesoSanitized.isEmpty || double.tryParse(pesoSanitized)! <= 0) {
      return 'Peso inválido. Informe um valor positivo.';
    }
    return null;
  }
}
