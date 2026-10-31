class CategoryDeleteException implements Exception {
  const CategoryDeleteException(this.message);

  final String message;

  @override
  String toString() => message;
}
