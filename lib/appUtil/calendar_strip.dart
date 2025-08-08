
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarStrip extends StatefulWidget {
  // This widget is the root of your application.
  final Function onDateSelected;
  final Function onWeekSelected;
  final Function dateTileBuilder;
  final BoxDecoration containerDecoration;
  final double containerHeight;
  final Function monthNameWidget;
  final Color iconColor;
  final DateTime selectedDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> markedDates;
  final bool addSwipeGesture;
  final bool weekStartsOnSunday;
  final Icon rightIcon;
  final Icon leftIcon;

  CalendarStrip({
    this.addSwipeGesture = false,
    this.weekStartsOnSunday = false,
    required this.onDateSelected,
    required this.onWeekSelected,
     required this.dateTileBuilder,
     required this.containerDecoration,
     required this.containerHeight,
     required this.monthNameWidget,
     required this.iconColor,
     required this.selectedDate,
     required this.startDate,
     required this.endDate,
     required this.markedDates,
     required this.rightIcon,
     required this.leftIcon,
  });

  State<CalendarStrip> createState() =>
      CalendarStripState(selectedDate, startDate, endDate);
}

class CalendarStripState extends State<CalendarStrip>
    with TickerProviderStateMixin {
  DateTime currentDate = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool inBetweenMonths = false;
  double opacity = 0.0;
  TextStyle monthLabelStyle = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87);
  TextStyle selectedDateStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white);
  bool isOnEndingWeek = false, isOnStartingWeek = false;
  bool doesDateRangeExists = false;
    DateTime? selectedDate;
  String? monthLabel;
   DateTime? rowStartingDate;
   DateTime? lastDayOfMonth;
   DateTime? today;


  List<String> monthLabels = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List<String> dayLabels = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"];

  CalendarStripState(
      DateTime selectedDate, DateTime startDate, DateTime endDate) {
    today = getDateOnly(DateTime.now());
    
    lastDayOfMonth = AppDateUtils.getLastDayOfMonth(currentDate);
    runPresetsAndExceptions(selectedDate, startDate, endDate);
    this.selectedDate = currentDate;
  }

  runPresetsAndExceptions(selectedDate, startDate, endDate) {
    if ((startDate == null && endDate != null) ||
        (startDate != null && endDate == null)) {
      throw Exception(
          "Both 'startDate' and 'endDate' are mandatory to specify range");
    } else if (selectedDate != null &&
        (isDateBefore(selectedDate, startDate) ||
            isDateAfter(selectedDate, endDate))) {
      throw Exception("Selected Date is out of range from start and end dates");
    } else if (startDate == null && startDate == null) {
      doesDateRangeExists = false;
    } else {
      doesDateRangeExists = true;
    }
    if (doesDateRangeExists) {
      if (endDate != null && isDateAfter(currentDate, endDate)) {
        currentDate = getDateOnly(startDate);
      } else if (isDateBefore(currentDate, startDate)) {
        currentDate = getDateOnly(startDate);
      }
    }
    if (selectedDate != null) {
      currentDate = getDateOnly(nullOrDefault(selectedDate, currentDate));
    }
  }

  @override
  void didUpdateWidget(CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate &&
        (isDateBefore(widget.selectedDate, widget.startDate) ||
            isDateAfter(widget.selectedDate, widget.endDate))) {
      throw Exception("Selected Date is out of range from start and end dates");
    } else {
      setState(() {
        selectedDate = getDateOnly(widget.selectedDate?? DateTime.now());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    int subtractDuration = widget.weekStartsOnSunday == true
        ? currentDate.weekday
        : currentDate.weekday - 1;
    rowStartingDate = rowStartingDate != null
        ? rowStartingDate
        : currentDate.subtract(Duration(days: subtractDuration));
    var dateRange = calculateDateRange(null);

    setState(() {
      isOnEndingWeek = dateRange['isEndingWeekOnRange']!;
      isOnStartingWeek = dateRange['isStartingWeekOnRange']!;
    });
  }

  int getLastDayOfMonth(rowStartingDay) {
    return AppDateUtils.getLastDayOfMonth(
        currentDate.add(Duration(days: rowStartingDay)))
        .day;
  }

  String getMonthName(
      DateTime dateObj,
      ) {
    return monthLabels[dateObj.month - 1];
  }

  String getMonthLabel() {
    DateTime startingDayObj = rowStartingDate!,
        endingDayObj = rowStartingDate!.add(Duration(days: 6));
    String label = "";
    if (startingDayObj.month == endingDayObj.month) {
      label = "${getMonthName(startingDayObj)} ${startingDayObj.year}";
      print(label);
    } else {
      var startingDayYear =
          "${startingDayObj.year == endingDayObj.year ? "" : startingDayObj.year}";
      label =
      "${getMonthName(startingDayObj)} $startingDayYear / ${getMonthName(endingDayObj)} ${endingDayObj.year}";
    }
    return label;
  }

  isDateBefore(date1, date2) {
    DateTime _date1 = DateTime(date1.year, date1.month, date1.day);
    DateTime _date2 = DateTime(date2.year, date2.month, date2.day);
    return _date1.isBefore(_date2);
  }

  isDateAfter(date1, date2) {
    DateTime _date1 = DateTime(date1.year, date1.month, date1.day);
    DateTime _date2 = DateTime(date2.year, date2.month, date2.day);
    return _date1.isAfter(_date2);
  }

  DateTime getDateOnly(DateTime dateTimeObj) {
    return DateTime.utc(dateTimeObj.year, dateTimeObj.month, dateTimeObj.day);
  }

  bool isDateMarked(date) {
    date = getDateOnly(date);
    bool _isDateMarked = false;
    widget.markedDates.forEach((DateTime eachMarkedDate) {
      if (getDateOnly(eachMarkedDate) == date) {
        _isDateMarked = true;
      }
    });
      return _isDateMarked;
  }

  Map<String, bool> calculateDateRange(mode) {
    if (doesDateRangeExists) {
      DateTime _nextRowStartingDate;
      DateTime weekStartingDate, weekEndingDate;
      if (mode != null) {
        _nextRowStartingDate = mode == "PREV"
            ? rowStartingDate!.subtract(Duration(days: 7))
            : rowStartingDate!.add(Duration(days: 7));
      } else {
        _nextRowStartingDate = rowStartingDate!;
      }
      weekStartingDate = getDateOnly(_nextRowStartingDate);
      weekEndingDate = getDateOnly(_nextRowStartingDate.add(Duration(days: 6)));
      bool isStartingWeekOnRange =
      isDateAfter(widget.startDate, weekStartingDate);
      bool isEndingWeekOnRange = isDateBefore(widget.endDate, weekEndingDate);
      return {
        "isEndingWeekOnRange": isEndingWeekOnRange,
        "isStartingWeekOnRange": isStartingWeekOnRange
      };
    } else {
      return {"isEndingWeekOnRange": false, "isStartingWeekOnRange": false};
    }
  }

  onPrevRow() {
    var dateRange = calculateDateRange("PREV");
    setState(() {
      rowStartingDate = rowStartingDate!.subtract(Duration(days: 7));
      // widget.onWeekSelected(DateTime.now());
      isOnEndingWeek = dateRange['isEndingWeekOnRange']!;
      isOnStartingWeek = dateRange['isStartingWeekOnRange']!;
    });
  }

  onNextRow() {
    var dateRange = calculateDateRange("NEXT");
    setState(() {
      rowStartingDate = rowStartingDate!.add(Duration(days: 7));
      // widget.onWeekSelected(rowStartingDate??dateRange.isEmpty);
      isOnEndingWeek = dateRange['isEndingWeekOnRange']!;
      isOnStartingWeek = dateRange['isStartingWeekOnRange']!;
    });
  }

  onDateTap(date) {
    if (!doesDateRangeExists) {
      setState(() {
        selectedDate = date;
        widget.onDateSelected(date);
      });
    } else if (!isDateBefore(date, widget.startDate) &&
        !isDateAfter(date, widget.endDate)) {
      setState(() {
        selectedDate = date;
        widget.onDateSelected(date);
        // widget.markedDates.add(date);
      });
    } else {}
  }

  nullOrDefault(var normalValue, var defaultValue) {
    if (normalValue == null) {
      return defaultValue;
    }
    return normalValue;
  }

  // monthLabelWidget(monthLabel) {
  //   return widget.monthNameWidget(monthLabel);
  //     return Container(
  //       child: Text(monthLabel, style: monthLabelStyle),
  //       padding: EdgeInsets.only(top: 7, bottom: 3));
  // }
  monthLabelWidget(monthLabel) {
  return widget.monthNameWidget(monthLabel);

}

  rightIconWidget() {
    if (!isOnEndingWeek) {
      return InkWell(
        child: widget.rightIcon ??
            Icon(
              CupertinoIcons.right_chevron,
              size: 30,
              color: nullOrDefault(widget.iconColor, Colors.black),
            ),
        onTap: onNextRow,
        splashColor: Colors.black26,
      );
    } else {
      return Container(width: 20);
    }
  }

  leftIconWidget() {
    if (!isOnStartingWeek) {
      return InkWell(
        child: widget.leftIcon ??
            Icon(
              CupertinoIcons.left_chevron,
              size: 30,
              color: nullOrDefault(widget.iconColor, Colors.black),
            ),
        onTap: onPrevRow,
        splashColor: Colors.black26,
      );
    } else {
      return Container(width: 20);
    }
  }

  checkOutOfRangeStatus(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    if (!isDateBefore(date, widget.startDate) &&
        !isDateAfter(date, widget.endDate)) {
      return false;
    } else {
      return true;
    }
    }

  onStripDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0 || !widget.addSwipeGesture) return;
    if (details.primaryVelocity! < 0) {
      if (!isOnEndingWeek) {
        onNextRow();
      }
    } else {
      if (!isOnStartingWeek) {
        onPrevRow();
      }
    }
  }

  buildDateRow() {
    List<Widget> currentWeekRow = [];
    for (var eachDay = 0; eachDay < 7; eachDay++) {
      var index = eachDay;
      currentWeekRow.add(dateTileBuilder(
          rowStartingDate!.add(Duration(days: eachDay)), selectedDate!, index));
    }
    monthLabel = getMonthLabel();
    return Column(children: [
      monthLabelWidget(monthLabel),

      Container(

          padding: EdgeInsets.all(0),
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) =>
                onStripDrag(details),
            child: Row(children: [
              leftIconWidget(),
              Expanded(child: Row(children: currentWeekRow)),
              rightIconWidget()
            ]),
          ))
    ]);
  }

  Widget dateTileBuilder(DateTime date, DateTime selectedDate, int rowIndex ) {
    bool isDateOutOfRange = checkOutOfRangeStatus(date);
    String dayName = dayLabels[date.weekday - 1];

    return Expanded(
      child: SlideFadeTransition(
        delay: 30 + (30 * rowIndex),
        id: "${date.day}${date.month}${date.year}",
        curve: Curves.ease,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () => onDateTap(date),
          child: Container(
            child: widget.dateTileBuilder(date, selectedDate, rowIndex,
                dayName, isDateMarked(date), isDateOutOfRange),

          ),
        ),
      ),
    );


  
    // bool isSelectedDate = date.compareTo(selectedDate) == 0;
    // var normalStyle = TextStyle(
    //     fontSize: 17,
    //     fontWeight: FontWeight.w800,
    //     color: isDateOutOfRange ? Colors.black26 : Colors.black54);
    // return Expanded(
    //   child: SlideFadeTransition(
    //     delay: 30 + (30 * rowIndex),
    //     id: "${date.day}${date.month}${date.year}",
    //     curve: Curves.ease,
    //     child: InkWell(
    //       onTap: () => onDateTap(date),
    //       child: Container(
    //         alignment: Alignment.center,
    //         padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
    //         decoration: BoxDecoration(
    //           color: !isSelectedDate ? Colors.transparent : Colors.red,
    //           borderRadius: BorderRadius.all(Radius.circular(60)),
    //         ),
    //         child: Column(
    //           children: [
    //             Text(
    //               dayLabels[date.weekday - 1],
    //               style: TextStyle(
    //                 fontSize: 14.5,
    //                 color: !isSelectedDate ? Colors.black : Colors.white,
    //               ),
    //             ),
    //             Text(date.day.toString(),
    //                 style: !isSelectedDate ? normalStyle : selectedDateStyle),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

  }


  getMarkedIndicatorWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        margin: EdgeInsets.only(left: 1, right: 1),
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      )
    ]);
  }

  build(BuildContext context) {
    return Container(
      height: nullOrDefault(widget.containerHeight, 90.0),
      child: buildDateRow(),
      decoration: widget.containerDecoration != null
          ? widget.containerDecoration
          : BoxDecoration(),
    );
  }
}

class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final int delay;
  final String id;
  final Curve curve;

  SlideFadeTransition(
      {required this.child, required this.id, required this.delay, required this.curve});

  @override
  SlideFadeTransitionState createState() => SlideFadeTransitionState();
}

class SlideFadeTransitionState extends State<SlideFadeTransition>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _animOffset;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    final _curve = CurvedAnimation(
        curve: widget.curve != null ? widget.curve : Curves.decelerate,
        parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero)
            .animate(_curve);

    _animController.reset();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (!_disposed) _animController.forward();
    });
    }

  @override
  void didUpdateWidget(SlideFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (!_disposed) _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(position: _animOffset, child: widget.child),
      opacity: _animController,
    );
  }
}


class AppDateUtils {
  static DateTime toMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isToday(DateTime date) {
    var now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  static bool isPastDay(DateTime date) {
    var today = toMidnight(DateTime.now());
    return date.isBefore(today);
  }

  static DateTime addDaysToDate(DateTime date, int days) {
    DateTime newDate = date.add(Duration(days: days));

    if (date.hour != newDate.hour) {
      var hoursDifference = date.hour - newDate.hour;

      if (hoursDifference <= 3 && hoursDifference >= -3) {
        newDate = newDate.add(Duration(hours: hoursDifference));
      } else if (hoursDifference <= -21) {
        newDate = newDate.add(Duration(hours: 24 + hoursDifference));
      } else if (hoursDifference >= 21) {
        newDate = newDate.add(Duration(hours: hoursDifference - 24));
      }
    }
    return newDate;
  }

  static bool isSpecialPastDay(DateTime date) {
    return isPastDay(date) || (isToday(date) && DateTime.now().hour >= 12);
  }

  static DateTime getFirstDayOfCurrentMonth() {
    var dateTime = DateTime.now();
    dateTime = getFirstDayOfMonth(dateTime);
    return dateTime;
  }

  static DateTime getFirstDayOfNextMonth() {
    var dateTime = getFirstDayOfCurrentMonth();
    dateTime = addDaysToDate(dateTime, 31);
    dateTime = getFirstDayOfMonth(dateTime);
    return dateTime;
  }

  static DateTime getLastDayOfCurrentMonth() {
    return getLastDayOfMonth(DateTime.now());
  }

  static DateTime getLastDayOfNextMonth() {
    return getLastDayOfMonth(getFirstDayOfNextMonth());
  }

  static DateTime addMonths(DateTime fromMonth, int months) {
    DateTime firstDayOfCurrentMonth = fromMonth;
    for (int i = 0; i < months; i++) {
      firstDayOfCurrentMonth = getLastDayOfMonth(firstDayOfCurrentMonth).add(Duration(days: 1));
    }

    return firstDayOfCurrentMonth;
  }

  static DateTime getFirstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  static DateTime getLastDayOfMonth(DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month);
    DateTime nextMonth = firstDayOfMonth.add(Duration(days: 32));
    DateTime firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month);
    return firstDayOfNextMonth.subtract(Duration(days: 1));
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day && date1.month == date2.month && date1.year == date2.year;
  }

  static bool isCurrentMonth(DateTime date) {
    var now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  static int calculateMaxWeeksNumberMonthly(DateTime startDate, DateTime endDate) {
    int monthsNumber = calculateMonthsDifference(startDate, endDate);

    List<int> weeksNumbersMonthly = [];

    if (monthsNumber == 0) {
      return calculateWeeksNumber(startDate, endDate);
    } else {
      weeksNumbersMonthly.add(calculateWeeksNumber(startDate, getLastDayOfMonth(startDate)));

      DateTime firstDateOfMonth = getFirstDayOfMonth(startDate);
      for (int i = 1; i <= monthsNumber - 2; i++) {
        firstDateOfMonth = firstDateOfMonth.add(Duration(days: 31));
        weeksNumbersMonthly.add(calculateWeeksNumber(firstDateOfMonth, getLastDayOfMonth(firstDateOfMonth)));
      }

      weeksNumbersMonthly.add(calculateWeeksNumber(getFirstDayOfMonth(endDate), endDate));

      weeksNumbersMonthly.sort((a, b) => b.compareTo(a));
      return weeksNumbersMonthly[0];
    }
  }

  static int calculateMonthsDifference(DateTime startDate, DateTime endDate) {
    var yearsDifference = endDate.year - startDate.year;
    return 12 * yearsDifference + endDate.month - startDate.month;
  }

  static int calculateWeeksNumber(DateTime monthStartDate, DateTime monthEndDate) {
    int rowsNumber = 1;

    DateTime currentDay = monthStartDate;
    while (currentDay.isBefore(monthEndDate)) {
      currentDay = currentDay.add(Duration(days: 1));
      if (currentDay.weekday == DateTime.monday) {
        rowsNumber += 1;
      }
    }

    return rowsNumber;
  }
}
