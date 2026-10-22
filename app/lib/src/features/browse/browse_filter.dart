import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrowseFilter {
  const BrowseFilter({this.teacher = '', this.category = '', this.type = ''});

  final String teacher;
  final String category;
  final String type;

  bool get isEmpty => teacher.isEmpty && category.isEmpty && type.isEmpty;

  BrowseFilter copyWith({String? teacher, String? category, String? type}) =>
      BrowseFilter(
        teacher: teacher ?? this.teacher,
        category: category ?? this.category,
        type: type ?? this.type,
      );
}

class BrowseFilterNotifier extends Notifier<BrowseFilter> {
  @override
  BrowseFilter build() => const BrowseFilter();

  void setTeacher(String slug) => state = state.copyWith(teacher: slug);

  void setCategory(String slug) => state = state.copyWith(category: slug);

  void setType(String slug) => state = state.copyWith(type: slug);

  void clear() => state = const BrowseFilter();
}

final browseFilterProvider =
    NotifierProvider<BrowseFilterNotifier, BrowseFilter>(BrowseFilterNotifier.new);
