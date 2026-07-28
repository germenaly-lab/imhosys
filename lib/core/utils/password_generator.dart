import 'dart:math';

class PasswordGenerator {
  static const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String numberChars = '0123456789';
  static const String symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    String allowedChars = '';
    if (includeUppercase) allowedChars += uppercaseChars;
    if (includeLowercase) allowedChars += lowercaseChars;
    if (includeNumbers) allowedChars += numberChars;
    if (includeSymbols) allowedChars += symbolChars;

    if (allowedChars.isEmpty) {
      allowedChars = lowercaseChars + numberChars;
    }

    final rand = Random.secure();
    
    // Ensure at least one character from each selected category
    List<String> result = [];
    if (includeUppercase) result.add(uppercaseChars[rand.nextInt(uppercaseChars.length)]);
    if (includeLowercase) result.add(lowercaseChars[rand.nextInt(lowercaseChars.length)]);
    if (includeNumbers) result.add(numberChars[rand.nextInt(numberChars.length)]);
    if (includeSymbols) result.add(symbolChars[rand.nextInt(symbolChars.length)]);

    while (result.length < length) {
      result.add(allowedChars[rand.nextInt(allowedChars.length)]);
    }

    result.shuffle(rand);
    return result.join('');
  }
}
