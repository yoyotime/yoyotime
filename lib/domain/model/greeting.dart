class Greeting {
  final String text;
  final String subText;
  final GreetingPeriod period;
  final DateTime createdAt;

  const Greeting({
    required this.text,
    required this.subText,
    required this.period,
    required this.createdAt,
  });
}

enum GreetingPeriod {
  dawn,    // 5:00 - 7:59   拂晓
  morning, // 8:00 - 11:59  早安
  noon,    // 12:00 - 13:59 午安
  afternoon, // 14:00 - 17:59 下午
  evening, // 18:00 - 20:59 傍晚
  night,   // 21:00 - 23:59 晚安
  lateNight, // 0:00 - 4:59 深夜
}
