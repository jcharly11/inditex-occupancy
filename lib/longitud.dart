bool validation(String input) {
  final regex = RegExp(r'^[A-Z0-9]{24}$');
  return regex.hasMatch(input);
}
