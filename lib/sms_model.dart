// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SMS {
  int? id;
  String text;
  String sender;
  int date;
  SMS({
    this.id,
    required this.text,
    required this.sender,
    required this.date,
  });

  SMS copyWith({
    int? id,
    String? text,
    String? sender,
    int? date,
  }) {
    return SMS(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'sender': sender,
      'date': date,
    };
  }

  factory SMS.fromMap(Map<String, dynamic> map) {
    return SMS(
      id: map['id'] != null ? map['id'] as int : null,
      text: map['text'] as String,
      sender: map['sender'] as String,
      date: map['date'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SMS.fromJson(String source) => SMS.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SMS(id: $id, text: $text, sender: $sender, date: $date)';
  }

  @override
  bool operator ==(covariant SMS other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.text == text &&
      other.sender == sender &&
      other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      text.hashCode ^
      sender.hashCode ^
      date.hashCode;
  }
}
