import '../model/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences prefs);
  Future<int> getDailyConsumedCount();
  Future<void> incrementDailyConsumedCount();
}
