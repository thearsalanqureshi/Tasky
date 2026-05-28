import 'package:get/get.dart';

import '../../data/mock/tasky_mock_data.dart';
import '../../data/models/task_model.dart';

class PlannerController extends GetxController {
  final RxSet<String> checkedBlocks = <String>{}.obs;

  List<TaskModel> get priorityTasks {
    final high = TaskyMockData.tasks
        .where((task) => task.priority == 'High' && !task.isCompleted)
        .take(3)
        .toList();
    return high;
  }

  List<PlannerBlock> get timeBlocks {
    final tasks = priorityTasks;
    return [
      PlannerBlock(
        id: 'morning',
        time: '9:00 AM',
        title: tasks.isNotEmpty ? tasks[0].title : 'Plan the day',
        energy: 'High',
        estimatedMinutes: tasks.isNotEmpty ? tasks[0].estimatedMinutes : 25,
      ),
      PlannerBlock(
        id: 'midday',
        time: '1:30 PM',
        title: tasks.length > 1 ? tasks[1].title : 'Reset task list',
        energy: 'Medium',
        estimatedMinutes: tasks.length > 1 ? tasks[1].estimatedMinutes : 20,
      ),
      PlannerBlock(
        id: 'evening',
        time: '6:00 PM',
        title: tasks.length > 2 ? tasks[2].title : 'Wrap up notes',
        energy: 'Low',
        estimatedMinutes: tasks.length > 2 ? tasks[2].estimatedMinutes : 15,
      ),
    ];
  }

  int get totalEstimatedMinutes {
    return timeBlocks.fold(0, (total, block) => total + block.estimatedMinutes);
  }

  double get progressRatio {
    final total = timeBlocks.length;
    return total == 0 ? 0 : checkedBlocks.length / total;
  }

  void toggleBlock(String id) {
    if (checkedBlocks.contains(id)) {
      checkedBlocks.remove(id);
    } else {
      checkedBlocks.add(id);
    }
  }
}

class PlannerBlock {
  const PlannerBlock({
    required this.id,
    required this.time,
    required this.title,
    required this.energy,
    required this.estimatedMinutes,
  });

  final String id;
  final String time;
  final String title;
  final String energy;
  final int estimatedMinutes;
}
