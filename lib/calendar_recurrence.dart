enum EventFrequency {
  /*not available on iOS: secondly, minutely, hourly, */
  daily,
  weekly,
  monthly,
  yearly
}

class EventRecurrence {
  /// The frequency of the recurrence rule.
  final EventFrequency? frequency;

  /// Indicates the number of occurrences until the rule ends.
  final int? occurrences;

  /// Indicates when the recurrence rule ends.
  final DateTime? endDate;

  /// Specifies how often the recurrence rule repeats over the unit of time indicated by its frequency.
  final int interval;

  /// (Android only) If you have a specific rule that cannot be matched with current parameters, you can specify a RRULE in RFC5545 format
  final String? rRule;
  EventRecurrence({
    required this.frequency,
    this.occurrences,
    this.endDate,
    this.interval = 1,
    this.rRule,
  }) : assert(occurrences == null || endDate == null,
  "Specify either occurrences or endDate");

  Map<String, dynamic> toJson() => {
    'frequency': frequency?.index,
    'occurrences': occurrences,
    'endDate': endDate?.millisecondsSinceEpoch,
    'interval': interval,
    'rRule': rRule,
  };
}