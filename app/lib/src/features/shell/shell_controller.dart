import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellController extends Notifier<int> {
  @override
  int build() => 0;

  void goTo(int index) => state = index;

  void openSearch() => state = 2;
}

final shellProvider = NotifierProvider<ShellController, int>(ShellController.new);
