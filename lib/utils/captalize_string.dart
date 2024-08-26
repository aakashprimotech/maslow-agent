extension StringExtension on String {
  String? capitalize() {
    if (this == null) {
      return null;
    }
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
