// ignore_for_file: constant_identifier_names

enum Currency {
  EGP,
  EUR,
  USD,
}

extension CurrencyExtension on Currency {
  String get code {
    switch (this) {
      case Currency.EGP:
        return 'EGP';
      case Currency.EUR:
        return 'EUR';
      case Currency.USD:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.EGP:
        return 'EGP';
      case Currency.EUR:
        return '€';
      case Currency.USD:
        return '\$';
    }
  }

  String get flag {
    switch (this) {
      case Currency.EGP:
        return '🇪🇬';
      case Currency.EUR:
        return '🇪🇺';
      case Currency.USD:
        return '🇺🇸';
    }
  }
}
