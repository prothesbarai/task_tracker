class DateTimeHelper {

  /// >>> Format DateTime → "18 Oct 2025, 05:20 PM"
  static String formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final month = months[date.month - 1];
    final year = date.year;
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? "PM" : "AM";
    return "$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $amPm";
  }


  /// >>> Only Date Without Time  → "18 Oct 2025"
  static String formatDateOnly(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final month = months[date.month - 1];
    final year = date.year;
    return "$day $month $year";
  }


  /// >>> Only Time Without Date → "05:20 PM"
  static String formatTimeOnly(DateTime date) {
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? "PM" : "AM";
    return "${hour.toString().padLeft(2, '0')}:$minute $amPm";
  }


  static String formatDuration(int totalSeconds) {
    if(totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2,'0')}:${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}";
  }



  static DateTime parseDateTime(String dateTimeStr) {
    // expected format: "27 Nov 2025, 02:45 PM"
    final parts = dateTimeStr.split(', '); // ["27 Nov 2025", "02:45 PM"]
    final datePart = parts[0].split(' '); // ["27", "Nov", "2025"]
    final timePart = parts[1].split(':'); // ["02", "45 PM"]
    final day = int.parse(datePart[0]);
    final monthStr = datePart[1];
    final year = int.parse(datePart[2]);
    const months = {"Jan":1,"Feb":2,"Mar":3,"Apr":4,"May":5,"Jun":6,"Jul":7,"Aug":8,"Sep":9,"Oct":10,"Nov":11,"Dec":12};
    final month = months[monthStr] ?? 1;
    int hour = int.parse(timePart[0]);
    final minute = int.parse(timePart[1].substring(0,2));
    final amPm = timePart[1].substring(3).trim(); // "AM" বা "PM"
    if(amPm == "PM" && hour != 12) hour += 12;
    if(amPm == "AM" && hour == 12) hour = 0;
    return DateTime(year, month, day, hour, minute);
  }

}
