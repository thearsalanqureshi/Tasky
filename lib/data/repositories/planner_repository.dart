import '../../core/constants/storage_keys.dart';
import '../models/planner_day_model.dart';
import '../services/local_storage_service.dart';

class PlannerRepository {
  const PlannerRepository(this._localStorageService);

  final LocalStorageService _localStorageService;

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
    return _localStorageService.remove(StorageKeys.plannerDays);
  }

  Map<String, PlannerDayModel> _storedPlannerDays() {
    final rawDays = _localStorageService.getJsonMap(StorageKeys.plannerDays);
    final plannerDays = <String, PlannerDayModel>{};
    for (final entry in rawDays.entries) {
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

  Future<bool> _savePlannerDays(Map<String, PlannerDayModel> plannerDays) {
    return _localStorageService.setJsonMap(
      StorageKeys.plannerDays,
      plannerDays.map((key, value) => MapEntry(key, value.toJson())),
    );
  }
}
