/// Share of a category in a month's total spending.
class CategoryShare {
  const CategoryShare({required this.category, required this.percentage});

  final String category;
  final double percentage;

  factory CategoryShare.fromJson(Map<String, dynamic> json) => CategoryShare(
        category: json['category'] as String,
        percentage: (json['percentage'] as num).toDouble(),
      );
}
