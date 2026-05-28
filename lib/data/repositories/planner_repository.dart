import 'dart:convert';
import '../models/planner_day_model.dart';
import '../services/local_storage_service.dart';

class PlannerRepository {
  const PlannerRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

  static const String _plannerDaysKey = 'plannerDays';

  PlannerDayModel getPlannerDay(DateTime date) {
    final dateKey = PlannerDayModel.dateKeyFor(date);
    final storedDays = _storedPlannerDays();
    return storedDays[dateKey] ?? PlannerDayModel.empty(date);
  }

  Future<bool> savePlannerDay(PlannerDayModel plannerDay) {
    final storedDays = _storedPlannerDays();
    storedDays[plannerDay.dateKey] = plannerDay.copyWith(
      updatedAt: DateTime.now(),
    );
    return _savePlannerDays(storedDays);
  }

  PlannerDayModel getTodayPlanner() {
    return getPlannerDay(DateTime.now());
  }

  Future<bool> saveTodayPlanner(PlannerDayModel plannerDay) {
    return savePlannerDay(
      plannerDay.copyWith(dateKey: PlannerDayModel.dateKeyFor(DateTime.now())),
    );
  }

  Future<bool> clearPlannerDay(DateTime date) {
    final storedDays = _storedPlannerDays()
      ..remove(PlannerDayModel.dateKeyFor(date));
    return _savePlannerDays(storedDays);
  }

  Future<bool> clearAllPlannerData() {
    return _localStorageService.writeString(_plannerDaysKey, '');
  }

  Map<String, PlannerDayModel> _storedPlannerDays() {
    final jsonString = _localStorageService.readString(_plannerDaysKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <String, PlannerDayModel>{};
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        final plannerDays = <String, PlannerDayModel>{};
        for (final entry in decoded.entries) {
          final rawValue = entry.value;
          if (rawValue is! Map) {
            continue;
          }
          final plannerDay = PlannerDayModel.fromJson(
            Map<String, dynamic>.from(rawValue),
          );
          plannerDays[plannerDay.dateKey] = plannerDay;
        }
        return plannerDays;
      }
    } catch (_) {
      // fallback
    }
    return <String, PlannerDayModel>{};
  }

  Future<bool> _savePlannerDays(Map<String, PlannerDayModel> plannerDays) {
    final jsonString = jsonEncode(
      plannerDays.map((key, value) => MapEntry(key, value.toJson())),
    );
    return _localStorageService.writeString(
      _plannerDaysKey,
      jsonString,
    );
  }
}
