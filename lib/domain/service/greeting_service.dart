import 'dart:math';
import '../model/greeting.dart';

class GreetingService {
  Greeting generate({DateTime? now}) {
    final dt = now ?? DateTime.now();
    final period = _getPeriod(dt);
    final text = _getGreetingText(period, dt);
    final subText = _getSubText(period, dt);

    return Greeting(
      text: text,
      subText: subText,
      period: period,
      createdAt: dt,
    );
  }

  GreetingPeriod _getPeriod(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 5 && hour < 8) return GreetingPeriod.dawn;
    if (hour >= 8 && hour < 12) return GreetingPeriod.morning;
    if (hour >= 12 && hour < 14) return GreetingPeriod.noon;
    if (hour >= 14 && hour < 18) return GreetingPeriod.afternoon;
    if (hour >= 18 && hour < 21) return GreetingPeriod.evening;
    if (hour >= 21) return GreetingPeriod.night;
    return GreetingPeriod.lateNight;
  }

  String _getGreetingText(GreetingPeriod period, DateTime dt) {
    final season = _getSeason(dt);
    final random = Random(dt.day);

    switch (period) {
      case GreetingPeriod.dawn:
        return _pick(random, [
          '拂晓微光',
          '新的一天开始了',
          '晨曦初露',
          '早起的世界很安静',
        ]);
      case GreetingPeriod.morning:
        return _pick(random, [
          '早安',
          '愿你拥有从容的一天',
          '新的一天，慢慢来',
          '早上好',
        ]);
      case GreetingPeriod.noon:
        return _pick(random, [
          '午安',
          '该歇歇了',
          '午后时光',
          '吃好午饭了吗',
        ]);
      case GreetingPeriod.afternoon:
        return _pick(random, [
          '下午好',
          '今日过得怎样',
          '还好吗',
          '午后的阳光',
        ]);
      case GreetingPeriod.evening:
        return _pick(random, [
          '傍晚好',
          '天色渐暗',
          '辛苦了一天',
          '晚上好',
        ]);
      case GreetingPeriod.night:
        return _pick(random, [
          '晚安',
          '夜深了',
          '该休息了',
          '今天辛苦了',
        ]);
      case GreetingPeriod.lateNight:
        return _pick(random, [
          '夜深了',
          '还没睡吗',
          '早点休息',
          '夜已深，人未眠',
        ]);
    }
  }

  String _getSubText(GreetingPeriod period, DateTime dt) {
    final season = _getSeason(dt);
    final holiday = _getHoliday(dt);
    final random = Random(dt.minute + dt.hour);

    if (holiday != null) {
      return holiday;
    }

    switch (period) {
      case GreetingPeriod.dawn:
        return _pick(random, [
          '愿你被温柔唤醒',
          '新的一天，新的可能',
        ]);
      case GreetingPeriod.morning:
        return _pick(random, [
          '今天想了解些什么？',
          '有 10 条内容等着你',
          '世界正在发生，慢慢看',
        ]);
      case GreetingPeriod.noon:
        return _pick(random, [
          '吃完饭再看也不迟',
          '休息一下，眼睛也需要放松',
        ]);
      case GreetingPeriod.afternoon:
        return _pick(random, [
          '不急，内容都在这里',
          '挑感兴趣的看看',
        ]);
      case GreetingPeriod.evening:
        return _pick(random, [
          '放松一下',
          '今天也辛苦了',
          '适合听一篇文章',
        ]);
      case GreetingPeriod.night:
        return _pick(random, [
          '看完这条就睡吧',
          '明天见',
          '愿你有个好梦',
        ]);
      case GreetingPeriod.lateNight:
        return _pick(random, [
          '早点休息吧',
          '世界明天还在',
          '身体比新闻重要',
        ]);
    }
  }

  String _getSeason(DateTime dt) {
    final month = dt.month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  String? _getHoliday(DateTime dt) {
    final month = dt.month;
    final day = dt.day;

    if (month == 1 && day == 1) return '新年第一天，愿一切顺利';
    if (month == 2 && day >= 10 && day <= 17) return '春节快乐，阖家幸福';
    if (month == 3 && day == 8) return '妇女节快乐';
    if (month == 5 && day == 1) return '劳动节快乐';
    if (month == 6 && day == 1) return '儿童节快乐，愿你保有童心';
    if (month == 9 && day == 21) return '国际和平日，愿世界安宁';
    if (month == 10 && day == 1) return '国庆节快乐';
    if (month == 12 && day == 25) return '圣诞快乐';

    return null;
  }

  String _pick(Random random, List<String> options) {
    return options[random.nextInt(options.length)];
  }
}
