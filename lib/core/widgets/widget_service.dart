import 'package:home_widget/home_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const _widgetGroupId = 'com.yoyotime.app.widget';
  
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_widgetGroupId);
  }

  Future<void> updateWidget({
    required int totalCount,
    required int consumedCount,
    required String greeting,
  }) async {
    await HomeWidget.saveWidgetData<int>('total_count', totalCount);
    await HomeWidget.saveWidgetData<int>('consumed_count', consumedCount);
    await HomeWidget.saveWidgetData<String>('greeting', greeting);
    
    await HomeWidget.updateWidget(
      name: 'TodayWidget',
      androidName: 'TodayWidget',
      iOSName: 'TodayWidget',
    );
  }

  Future<void> updateGreeting(String greeting) async {
    await HomeWidget.saveWidgetData<String>('greeting', greeting);
    await HomeWidget.updateWidget(
      name: 'TodayWidget',
      androidName: 'TodayWidget',
      iOSName: 'TodayWidget',
    );
  }
}

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});
