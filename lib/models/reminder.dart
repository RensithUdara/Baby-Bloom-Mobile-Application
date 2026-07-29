class Reminder {
  int? id;
  final String title;
  final DateTime date;

  Reminder({this.id, required this.title, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'date': date.toIso8601String()};
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
