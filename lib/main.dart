import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_list/notification.dart';
import 'package:to_do_list/routes/app_router.dart';
import 'package:to_do_list/bloc_state_observer.dart';
import 'package:to_do_list/routes/pages.dart';
import 'package:to_do_list/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:to_do_list/tasks/data/repository/task_repository.dart';
import 'package:to_do_list/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:to_do_list/utils/color_palette.dart';
import 'package:timezone/data/latest.dart' as tz;



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  await NotificationService.init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}
// Function to check and request notification, alarm, and reminder permissions
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TaskRepository(taskDataProvider: TaskDataProvider()),
      child: BlocProvider(
        create: (context) => TasksBloc(context.read<TaskRepository>()),
        child: MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          initialRoute: Pages.initial,
          onGenerateRoute: onGenerateRoute,
          theme: ThemeData(
            fontFamily: 'Sora',
            visualDensity: VisualDensity.adaptivePlatformDensity,
            canvasColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
