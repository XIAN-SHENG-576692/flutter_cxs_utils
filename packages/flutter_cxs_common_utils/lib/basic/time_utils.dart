extension DateTimeStringFormat on DateTime {
  String toFileFormat() {
    return "${year.toString().padLeft(2, '0')}"
      "-${month.toString().padLeft(2, '0')}"
      "-${day.toString().padLeft(2, '0')}"
      "_${hour.toString().padLeft(2, '0')}"
      "-${minute.toString().padLeft(2, '0')}"
      "-${second.toString().padLeft(2, '0')}"
      "_${millisecond.toString().padLeft(3, '0')}"
      "${microsecond.toString().padLeft(3, '0')}";
  }
}
