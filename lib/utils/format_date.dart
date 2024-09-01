import 'package:intl/intl.dart';

void formatDate(String date) {
  // Parse the date string into a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Format the DateTime object into a desired string format
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
  
  // Output the formatted date
  print(formattedDate); // Example output: 2024-09-01 – 12:34
}