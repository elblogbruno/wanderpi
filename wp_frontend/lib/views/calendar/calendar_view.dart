/* Creates a rounded box that holds a title and image */


import 'package:calendar_view/calendar_view.dart';


import 'package:flutter/material.dart';
import 'package:wp_frontend/models/event.dart';

import 'package:wp_frontend/models/travel.dart';

import '../../ui/bar/context_bar.dart';

class CalendarView extends StatefulWidget
{
  final Travel? travel;
  final Function? onBackPressed;
  const CalendarView({Key? key, this.travel, this.onBackPressed}) :  super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();

}
DateTime get _now => DateTime.now();

class _CalendarViewState extends State<CalendarView> {

  String _calendarViewType = 'month';

  @override
  Widget build(BuildContext context) {
    EventController<Event> _eventController = EventController<Event>()..addAll(_events);

    return CalendarControllerProvider<Event>(
        controller: _eventController,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onBackPressed!();
                },
              ),
              title: Text(_title),
              actions: _buildWidgets(),
            ),
            body: _switchCalendarView(_calendarViewType, _eventController),
        ),
    );
  }

  List<Widget> _buildWidgets(){
    return  <Widget>[
      const VerticalDivider(),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Add Event"),
                  content: const TextField(
                    decoration: InputDecoration(
                      labelText: "Title",
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Add"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        },
      ),
      const VerticalDivider(),
      IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () {
          setState(() {
            _calendarViewType = 'month';
          });
        },
      ),
      const VerticalDivider(),
      IconButton(
        icon: const Icon(Icons.view_agenda),
        onPressed: () {
          setState(() {
            _calendarViewType = 'week';
          });
        },
      ),
      const VerticalDivider(),
      IconButton(
        icon: const Icon(Icons.view_list),
        onPressed: () {
          setState(() {
            _calendarViewType = 'day';
          });
        },
      ),
      //_buildCalendarDropDown(),
    ];
  }

  Widget _switchCalendarView(String viewType, EventController<Event> eventController) {
    switch (viewType) {
      case 'month':
        return MonthView(
          controller: eventController,
          borderColor: Colors.grey,
          borderSize: 1,
          cellAspectRatio: 1.5,
        );
      case 'week':
        return WeekView(
          controller: eventController,
        );
      case 'day':
        return DayView(
          controller: eventController,
        );
      default:
        return MonthView(
          controller: eventController,
          borderColor: Colors.grey,
          borderSize: 1,
          cellAspectRatio: 1.5,
        );
    }
  }

  String get _title {
    if (widget.travel != null) {
      return "${widget.travel!.name} Calendar";
    }
    return "Global Calendar";
  }

  Widget _buildTitle(){
    String title = "Global Calendar";

    if ( widget.travel != null) {
      title = "${widget.travel!.name} Calendar";
    }

    return ContextBar(
      title: title,
      onBackPressed: widget.onBackPressed,
      showBackButton: widget.travel != null,
      child: Container(),
    );

    /*return Container(
      padding: const EdgeInsets.all(10.0),
      child: Text(title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );*/
  }

}

final List<CalendarEventData<Event>> _events = [
  CalendarEventData(
    date: _now,
    event: Event(title: "Joe's Birthday"),
    title: "Project meeting",
    description: "Today is project meeting.",
    startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 22),
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 1)),
    startTime: DateTime(_now.year, _now.month, _now.day, 18),
    endTime: DateTime(_now.year, _now.month, _now.day, 19),
    event: Event(title: "Wedding anniversary"),
    title: "Wedding anniversary",
    description: "Attend uncle's wedding anniversary.",
  ),
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, _now.month, _now.day, 14),
    endTime: DateTime(_now.year, _now.month, _now.day, 17),
    event: Event(title: "Football Tournament"),
    title: "Football Tournament",
    description: "Go to football tournament.",
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    startTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    event: Event(title: "Sprint Meeting."),
    title: "Sprint Meeting.",
    description: "Last day of project submission for last year.",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        14),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        16),
    event: Event(title: "Team Meeting"),
    title: "Team Meeting",
    description: "Team Meeting",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        10),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        12),
    event: Event(title: "Chemistry Viva"),
    title: "Chemistry Viva",
    description: "Today is Joe's birthday.",
  ),
];
