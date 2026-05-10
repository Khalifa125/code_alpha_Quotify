import 'package:home_widget/home_widget.dart';
import '../models/quote.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.example.quotify';
  static const String _widgetName = 'QuoteWidget';

  Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  Future<void> updateWidget(Quote? quote) async {
    try {
      if (quote == null) {
        await HomeWidget.saveWidgetData<String>('quote_text', 'Open app for daily inspiration');
        await HomeWidget.saveWidgetData<String>('quote_author', 'Quotify');
      } else {
        await HomeWidget.saveWidgetData<String>('quote_text', '"${quote.text}"');
        await HomeWidget.saveWidgetData<String>('quote_author', '— ${quote.author}');
      }
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (_) {}
  }

  Future<void> enableWidget(bool enabled) async {
    // Widget enable/disable handled by platform
  }
}