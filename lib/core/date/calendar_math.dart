int floorDiv(int value, int divisor) {
  if (divisor <= 0) {
    throw ArgumentError.value(divisor, 'divisor', '必须大于 0');
  }

  final remainder = positiveModulo(value, divisor);
  return (value - remainder) ~/ divisor;
}

int positiveModulo(int value, int modulus) {
  if (modulus <= 0) {
    throw ArgumentError.value(modulus, 'modulus', '必须大于 0');
  }

  return ((value % modulus) + modulus) % modulus;
}
