import 'dart:convert';
import 'package:to_do_list/tasks/data/local/database_helper.dart';
import 'package:to_do_list/tasks/data/local/model/task_model.dart';
import 'package:to_do_list/utils/exception_handler.dart';

class TaskDataProvider {
  List<TaskModel> tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<TaskModel>> getTasks() async {
    try {
      tasks = await _dbHelper.getTasks();
      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      return tasks;
    } catch (e) {
      throw Exception(handleException(e));
    }
  }

  Future<List<TaskModel>> sortTasks(int sortOption) async {
    switch (sortOption) {
      case 0:
      // Sort by date
        tasks.sort((a, b) {
          return a.startDateTime!.compareTo(b.startDateTime!);
        });
        break;

      case 1:
      // Sort by completed tasks
        tasks.sort((a, b) {
          if (!a.completed && b.completed) {
            return 1;
          } else if (a.completed && !b.completed) {
            return -1;
          }
          return 0;
        });
        break;

      case 2:
      // Sort by pending tasks
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
        break;

      case 3:
      // Sort by priority (High -> Medium -> Low)
        tasks.sort((a, b) {
          int getPriorityValue(String priority) {
            switch (priority) {
              case 'High':
                return 0;
              case 'Medium':
                return 1;
              case 'Low':
                return 2;
              default:
                return 3; // In case any unexpected priority values are encountered
            }
          }

          return getPriorityValue(a.priority).compareTo(getPriorityValue(b.priority));
        });
        break;
    }
    return tasks;
  }

  Future<void> createTask(TaskModel taskModel) async {
    try {
      await _dbHelper.insertTask(taskModel);
      tasks = await getTasks();
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      await _dbHelper.updateTask(taskModel);
      tasks = await getTasks();
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    try {
      await _dbHelper.deleteTask(taskModel.id);
      tasks = await getTasks();
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> searchTasks(String keywords) async {
    var searchText = keywords.toLowerCase();
    tasks = await getTasks(); // Fetch all tasks from database
    return tasks.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }
}
