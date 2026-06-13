import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/content.dart';

enum ToneAction { allow, demote, block }

class ToneResult {
  final ToneAction action;
  final String? reason;

  const ToneResult({required this.action, this.reason});
}

class ToneRule {
  final String type;
  final RegExp pattern;
  final ToneAction action;
  final String reason;

  ToneRule({
    required this.type,
    required this.pattern,
    required this.action,
    required this.reason,
  });
}

class PolicyConfig {
  final String policy;
  final List<ToneRule> rules;

  const PolicyConfig({required this.policy, required this.rules});
}

class ToneEngine {
  Map<String, PolicyConfig> _categories = {};
  String _defaultPolicy = 'normal';

  Future<void> loadRules() async {
    final raw = await rootBundle.loadString('assets/config/tone_rules.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _defaultPolicy = json['defaultPolicy'] as String? ?? 'normal';

    final cats = json['categories'] as Map<String, dynamic>? ?? {};
    for (final entry in cats.entries) {
      final catJson = entry.value as Map<String, dynamic>;
      final rulesJson = catJson['rules'] as List<dynamic>? ?? [];
      final rules = rulesJson.map((r) {
        final rMap = r as Map<String, dynamic>;
        return ToneRule(
          type: rMap['type'] as String,
          pattern: RegExp(rMap['pattern'] as String),
          action: _parseAction(rMap['action'] as String),
          reason: rMap['reason'] as String,
        );
      }).toList();

      _categories[entry.key] = PolicyConfig(
        policy: catJson['policy'] as String? ?? _defaultPolicy,
        rules: rules,
      );
    }
  }

  ToneAction _parseAction(String action) {
    switch (action) {
      case 'block':
        return ToneAction.block;
      case 'demote':
        return ToneAction.demote;
      default:
        return ToneAction.allow;
    }
  }

  ToneResult evaluate(ContentItem item) {
    final combinedText = '${item.title} ${item.summary} ${item.fullText ?? ''}';

    ToneAction mostSevere = ToneAction.allow;
    String? reason;

    void checkRules(List<ToneRule> rules) {
      for (final rule in rules) {
        if (rule.pattern.hasMatch(combinedText)) {
          if (_isMoreSevere(rule.action, mostSevere)) {
            mostSevere = rule.action;
            reason = rule.reason;
          }
        }
      }
    }

    for (final topic in item.topics) {
      final config = _categories[topic];
      if (config != null) {
        checkRules(config.rules);
      }
    }

    final general = _categories['general'];
    if (general != null) {
      checkRules(general.rules);
    }

    return ToneResult(action: mostSevere, reason: reason);
  }

  bool _isMoreSevere(ToneAction a, ToneAction b) {
    const order = {ToneAction.block: 2, ToneAction.demote: 1, ToneAction.allow: 0};
    return (order[a] ?? 0) > (order[b] ?? 0);
  }

  List<ContentItem> filter(List<ContentItem> items) {
    final allowed = <ContentItem>[];
    final demoted = <ContentItem>[];

    for (final item in items) {
      final result = evaluate(item);
      switch (result.action) {
        case ToneAction.block:
          break;
        case ToneAction.demote:
          demoted.add(item);
          break;
        case ToneAction.allow:
          allowed.add(item);
          break;
      }
    }

    allowed.addAll(demoted);
    return allowed;
  }
}

final toneEngineProvider = Provider<ToneEngine>((ref) {
  return ToneEngine();
});
