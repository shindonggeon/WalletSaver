import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  AiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8000';

  final http.Client _client;
  final String _baseUrl;

  Future<String> generateLocationWarning({
    required String placeName,
    required String category,
    required int remainingBudget,
    required int todayBudget,
    required double budgetUsageRate,
    required String monthlyGoal,
    required String characterType,
    required String naggingIntensity,
  }) async {
    return _postText(
      endpoint: '/ai/location-warning',
      responseKey: 'message',
      body: {
        'placeName': placeName,
        'category': category,
        'remainingBudget': remainingBudget,
        'todayBudget': todayBudget,
        'budgetUsageRate': budgetUsageRate,
        'monthlyGoal': monthlyGoal,
        'characterType': characterType,
        'characterTypeLabel': getCharacterTypeLabel(characterType),
        'naggingIntensity': naggingIntensity,
      },
      fallback: _fallbackLocationWarning(
        placeName: placeName,
        remainingBudget: remainingBudget,
        todayBudget: todayBudget,
        monthlyGoal: monthlyGoal,
      ),
    );
  }

  Future<String> generateExpenseFeedback({
    required int amount,
    required String category,
    required String merchant,
    required int remainingBudget,
    required int todayBudget,
    required double budgetUsageRate,
    required String monthlyGoal,
    required String characterType,
    required String naggingIntensity,
  }) async {
    return _postText(
      endpoint: '/ai/expense-feedback',
      responseKey: 'message',
      body: {
        'amount': amount,
        'category': category,
        'merchant': merchant,
        'remainingBudget': remainingBudget,
        'todayBudget': todayBudget,
        'budgetUsageRate': budgetUsageRate,
        'monthlyGoal': monthlyGoal,
        'characterType': characterType,
        'characterTypeLabel': getCharacterTypeLabel(characterType),
        'naggingIntensity': naggingIntensity,
      },
      fallback: _fallbackExpenseFeedback(
        amount: amount,
        category: category,
        merchant: merchant,
        remainingBudget: remainingBudget,
      ),
    );
  }

  Future<String> generateMonthlyReport({
    required int age,
    required int totalBudget,
    required int totalSpent,
    required int remainingBudget,
    required double budgetUsageRate,
    required Map<String, int> categorySpending,
    required String monthlyGoal,
    required String characterType,
  }) async {
    final topCategory = getTopCategory(categorySpending);
    final personaTitle = getPersonaTitle(
      characterType: characterType,
      topCategory: topCategory,
    );

    return _postText(
      endpoint: '/ai/monthly-report',
      responseKey: 'report',
      body: {
        'age': age,
        'totalBudget': totalBudget,
        'totalSpent': totalSpent,
        'remainingBudget': remainingBudget,
        'budgetUsageRate': budgetUsageRate,
        'categorySpending': categorySpending,
        'monthlyGoal': monthlyGoal,
        'characterType': characterType,
        'characterTypeLabel': getCharacterTypeLabel(characterType),
        'topCategory': topCategory,
        'topCategoryLabel': getCategoryLabel(topCategory),
        'personaTitle': personaTitle,
        'personaBaseMessage': getPersonaBaseMessage(
          characterType: characterType,
          topCategory: topCategory,
        ),
      },
      fallback: _fallbackMonthlyReport(
        totalSpent: totalSpent,
        remainingBudget: remainingBudget,
        budgetUsageRate: budgetUsageRate,
        personaTitle: personaTitle,
        topCategory: topCategory,
      ),
    );
  }

  Future<String> _postText({
    required String endpoint,
    required Map<String, dynamic> body,
    required String responseKey,
    required String fallback,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return fallback;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final value = data[responseKey];

      if (value == null || value.toString().trim().isEmpty) {
        return fallback;
      }

      return value.toString();
    } on TimeoutException {
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  String getTopCategory(Map<String, int> categorySpending) {
    if (categorySpending.isEmpty) return 'shopping';

    final entries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.first.key;
  }

  String getCharacterTypeLabel(String characterType) {
    switch (characterType) {
      case 'lion':
        return '충동형 - 사자';
      case 'ant':
        return '계획형 - 개미';
      case 'turtle':
        return '절약형 - 거북이';
      case 'squirrel':
        return '충동적 다람쥐';
      case 'beaver':
        return '절약형 비버';
      default:
        return '일반형';
    }
  }

  String getCategoryLabel(String category) {
    switch (category) {
      case 'shopping':
        return '쇼핑';
      case 'convenience':
        return '편의';
      case 'leisure':
        return '여가';
      case 'self_satisfaction':
        return '자기만족';
      case 'food':
        return '식비';
      case 'cafe':
        return '카페';
      case 'transport':
        return '교통';
      case 'living':
        return '생활';
      case 'etc':
        return '기타';
      default:
        return category;
    }
  }

  String mapToPersonaCategory(String category) {
    switch (category) {
      case 'shopping':
        return 'shopping';
      case 'food':
      case 'cafe':
      case 'transport':
      case 'living':
      case 'convenience':
        return 'convenience';
      case 'leisure':
        return 'leisure';
      case 'self_satisfaction':
      case 'etc':
        return 'self_satisfaction';
      default:
        return 'self_satisfaction';
    }
  }

  String getPersonaTitle({
    required String characterType,
    required String topCategory,
  }) {
    final mappedCategory = mapToPersonaCategory(topCategory);

    final personaMap = {
      'lion_shopping': '즉흥적인 쇼퍼',
      'ant_shopping': '계획적인 쇼퍼',
      'turtle_shopping': '알뜰한 쇼퍼',
      'lion_convenience': '즉흥적인 편의주의자',
      'ant_convenience': '계획적인 편의주의자',
      'turtle_convenience': '알뜰한 편의주의자',
      'lion_leisure': '즉흥적인 여행가',
      'ant_leisure': '계획적인 여행가',
      'turtle_leisure': '알뜰한 여행가',
      'lion_self_satisfaction': '즉흥적인 하비슈머',
      'ant_self_satisfaction': '계획적인 하비슈머',
      'turtle_self_satisfaction': '알뜰한 하비슈머',
    };

    return personaMap['${characterType}_$mappedCategory'] ?? '맞춤형 소비자';
  }

  String getPersonaBaseMessage({
    required String characterType,
    required String topCategory,
  }) {
    final mappedCategory = mapToPersonaCategory(topCategory);

    final messageMap = {
      'lion_shopping':
          '즉흥적인 쇼퍼 유형입니다. 장바구니에 담아두고 하룻밤 더 고민하는 습관을 가져보세요.',
      'ant_shopping':
          '계획적인 쇼퍼 유형입니다. 정해진 예산 안에서 최선의 선택을 내리는 모습이 훌륭합니다.',
      'turtle_shopping':
          '알뜰한 쇼퍼 유형입니다. 무조건 저렴한 것만 찾기보다 오래 입을 수 있는 옷에 투자하는 합리적 소비도 고려해 보세요.',
      'lion_convenience':
          '즉흥적인 편의주의자 유형입니다. 편리함에 익숙해져 새나가는 지출을 막기 위해 직접 움직이는 연습이 필요합니다.',
      'ant_convenience':
          '계획적인 편의주의자 유형입니다. 서비스 활용도와 효율성이 높고 스마트하게 관리하고 있습니다.',
      'turtle_convenience':
          '알뜰한 편의주의자 유형입니다. 지출을 아끼는 것도 좋지만 편리한 시스템을 적절히 이용해보세요.',
      'lion_leisure':
          '즉흥적인 여행가 유형입니다. 즐거운 여가 뒤에 오는 지출이 부담되지 않도록 전용 비상금을 운용해 보세요.',
      'ant_leisure':
          '계획적인 여행가 유형입니다. 철저한 사전 조사와 준비성 덕분에 알찬 여가를 보내는 유형입니다.',
      'turtle_leisure':
          '알뜰한 여행가 유형입니다. 비용을 줄이는 데만 몰두하기보다 본인의 즐거움을 위해 적당한 여가 생활을 누려보세요.',
      'lion_self_satisfaction':
          '즉흥적인 하비슈머 유형입니다. 한꺼번에 많은 비용을 쏟기보다 취미의 깊이를 천천히 더해가며 속도를 조절해 보세요.',
      'ant_self_satisfaction':
          '계획적인 하비슈머 유형입니다. 취미 생활조차 체계적으로 조절하는 절제력이 강점입니다.',
      'turtle_self_satisfaction':
          '알뜰한 하비슈머 유형입니다. 비용을 아끼는 것도 좋지만 취미의 질을 높여줄 핵심적인 부분에는 적당히 지출해 보는 것도 추천합니다.',
    };

    return messageMap['${characterType}_$mappedCategory'] ??
        '사용자의 소비 패턴에 맞춰 지출 습관을 점검해보세요.';
  }

  String _fallbackLocationWarning({
    required String placeName,
    required int remainingBudget,
    required int todayBudget,
    required String monthlyGoal,
  }) {
    return '$placeName 근처는 등록된 위험 지역입니다. 오늘 사용 가능 예산은 ${formatWon(todayBudget)}이고, 이번 달 목표는 "$monthlyGoal"입니다. 들어가기 전에 꼭 필요한 소비인지 한 번만 더 확인해보세요.';
  }

  String _fallbackExpenseFeedback({
    required int amount,
    required String category,
    required String merchant,
    required int remainingBudget,
  }) {
    final afterBudget = remainingBudget - amount;

    return '$merchant에서 ${getCategoryLabel(category)} 지출 ${formatWon(amount)}이 발생했습니다. 결제 후 예상 남은 예산은 ${formatWon(afterBudget)}입니다. 이번 달 목표와 맞는 소비인지 한 번 점검해보세요.';
  }

  String _fallbackMonthlyReport({
    required int totalSpent,
    required int remainingBudget,
    required double budgetUsageRate,
    required String personaTitle,
    required String topCategory,
  }) {
    return '이번 달 소비 유형은 $personaTitle에 가깝습니다. 총 지출은 ${formatWon(totalSpent)}이고 예산 사용률은 ${(budgetUsageRate * 100).toStringAsFixed(1)}%입니다. 가장 눈에 띄는 카테고리는 ${getCategoryLabel(topCategory)}이며, 남은 예산은 ${formatWon(remainingBudget)}입니다. 다음 달에는 자주 쓰는 카테고리에 한도를 정하고 결제 전 남은 예산을 확인하는 습관을 추천합니다.';
  }

  String formatWon(int value) {
    final isNegative = value < 0;
    final text = value.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;

      buffer.write(text[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return '${isNegative ? '-' : ''}$buffer원';
  }
}