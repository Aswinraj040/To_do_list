import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list/components/widgets.dart';
import 'package:to_do_list/tasks/data/local/model/task_model.dart';
import 'package:to_do_list/utils/font_sizes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_list/utils/util.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../components/custom_app_bar.dart';
import '../../../notification.dart';
import '../../../utils/color_palette.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController timeController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Only for single day selection
  String _priority = 'High'; // Default priority
  bool _setReminder = false; // Default value for checkbox

  @override
  void initState() {
    _selectedDay = _focusedDay;
    super.initState();

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );


  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      timeController.text = formatDateTime(dateTime: selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: 'Create New Task',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                          if (state is AddTaskFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is AddTasksSuccess) {
                            Navigator.pop(context);
                          }
                        }, builder: (context, state) {
                      return ListView(
                        children: [
                          TableCalendar(
                            calendarFormat: _calendarFormat,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                              CalendarFormat.week: 'Week',
                            },
                            focusedDay: _focusedDay,
                            firstDay: DateTime.utc(2023, 1, 1),
                            lastDay: DateTime.utc(2030, 1, 1),
                            onPageChanged: (focusDay) {
                              _focusedDay = focusDay;
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onDaySelected: (selectedDay, focusDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusDay;
                              });
                            },
                            rangeSelectionMode: RangeSelectionMode
                                .disabled, // Disable range selection
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(.1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5))),
                            child: buildText(
                                _selectedDay != null
                                    ? 'Task scheduled for ${DateFormat.yMMMd().format(_selectedDay!)}'
                                    : 'Select a date',
                                kPrimaryColor,
                                textSmall,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip),
                          ),
                          const SizedBox(height: 20),
                          buildText(
                              'Title',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "Task Title",
                              controller: title,
                              inputType: TextInputType.text,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(
                            height: 20,
                          ),
                          buildText(
                              'Description',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "Task Description",
                              controller: description,
                              inputType: TextInputType.multiline,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(height: 20),
                          buildText(
                              'Time',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: AbsorbPointer(
                              child: BuildTextField(
                                hint: "Select Time",
                                controller: timeController,
                                inputType: TextInputType.datetime,
                                fillColor: kWhiteColor,
                                onChange: (value) {},
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildText(
                            'Priority',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<String>(
                            value: _priority,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1), // Light outline
                              ),
                              filled: true,
                              fillColor: kWhiteColor, // Set background color
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1), // Light outline for the enabled state
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade500,
                                    width: 1), // Slightly darker outline when focused
                              ),
                            ),
                            items: ['Medium', 'High', 'Low']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(color: kBlackColor)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _priority = newValue!;
                              });
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            dropdownColor: kWhiteColor,
                            style: TextStyle(
                              color: kBlackColor,
                              fontSize: textMedium,
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildText(
                              'Set Reminder',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          CheckboxListTile(
                            title: const Text('Set Reminder'),
                            value: _setReminder,
                            onChanged: (bool? value) {
                              setState(() {
                                _setReminder = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kWhiteColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Cancel',
                                          kBlackColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kPrimaryColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Generate a unique 4-digit ID for the task
                                      final String taskId = (1000 + Random().nextInt(9000)).toString();  // Generates a 4-digit number

                                      // Create a new TaskModel with the provided inputs
                                      var taskModel = TaskModel(
                                        id: taskId,
                                        title: title.text,
                                        description: description.text,
                                        startDateTime: _selectedDay,
                                        priority: _priority,
                                      );

                                      // Parse the selected time from the timeController
                                      final selectedTime = DateFormat('hh:mm a').parse(timeController.text);
                                      print(selectedTime.toString());

                                      // Add the task via the TasksBloc which interacts with the SQL database
                                      context.read<TasksBloc>().add(AddNewTaskEvent(taskModel: taskModel));

                                      // Handle notification if reminder is set
                                      if (_setReminder && _selectedDay != null && timeController.text.isNotEmpty) {
                                        // Ensure seconds are set to 00 for the notification time
                                        final DateTime scheduledTime = DateTime(
                                          _selectedDay!.year,
                                          _selectedDay!.month,
                                          _selectedDay!.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                        );

                                        // Schedule the notification
                                        NotificationService.scheduleNotification(
                                          int.parse(taskId), // Use taskId as the notification ID
                                          title.text, // Task title as the notification title
                                          description.text, // Task description as the notification body
                                          scheduledTime, // The scheduled time for the notification
                                        );

                                        print("Scheduled notification for $scheduledTime");
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Save',
                                          kWhiteColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                            ],
                          )
                        ],
                      );
                    })))));
  }
}

String formatDateTime({required DateTime dateTime}) {
  return DateFormat('hh:mm a').format(dateTime); // Example format: 03:30 PM
}
