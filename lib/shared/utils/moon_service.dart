import 'dart:math';

class MoonPhase {
  final String name;
  final String emoji;
  final double illumination;
  final String recommendation;
  final String recommendationDetail;

  const MoonPhase({
    required this.name,
    required this.emoji,
    required this.illumination,
    required this.recommendation,
    required this.recommendationDetail,
  });
}

class MoonService {
  // Calculates moon age (days since new moon) using astronomical formula
  static double moonAge(DateTime date) {
    final year  = date.year;
    final month = date.month;
    final day   = date.day;

    // Julian date
    var jd = 367 * year
        - (7 * (year + ((month + 9) ~/ 12))) ~/ 4
        + (275 * month) ~/ 9
        + day
        + 1721013.5
        + (date.hour + date.minute / 60) / 24;

    // Known new moon reference: Jan 6, 2000 18:14 UTC → JD 2451549.75
    const knownNewMoon = 2451549.75;
    const synodicMonth = 29.53058867;

    final daysSince = jd - knownNewMoon;
    final cycles    = daysSince / synodicMonth;
    final age       = (cycles - cycles.floor()) * synodicMonth;

    return age;
  }

  static double illuminationPercent(double age) {
    // Illumination follows a cosine curve over the synodic month
    return ((1 - cos(2 * pi * age / 29.53058867)) / 2 * 100);
  }

  static MoonPhase forDate(DateTime date) {
    final age   = moonAge(date);
    final illum = illuminationPercent(age);

    if (age < 1.85) {
      return MoonPhase(
        name: 'New Moon',
        emoji: '🌑',
        illumination: illum,
        recommendation: 'Rest & Prepare',
        recommendationDetail:
            'Good time to plan, prepare soil, add compost, and weed. Avoid planting today.',
      );
    } else if (age < 7.38) {
      return MoonPhase(
        name: 'Waxing Crescent',
        emoji: '🌒',
        illumination: illum,
        recommendation: 'Plant Above-Ground Crops',
        recommendationDetail:
            'Excellent for sowing leafy greens, herbs, tomatoes, peppers, beans, and squash. Sap is rising.',
      );
    } else if (age < 9.22) {
      return MoonPhase(
        name: 'First Quarter',
        emoji: '🌓',
        illumination: illum,
        recommendation: 'Plant Fruiting Crops',
        recommendationDetail:
            'Good for fruiting vegetables like tomatoes, corn, squash, and cucumbers.',
      );
    } else if (age < 14.77) {
      return MoonPhase(
        name: 'Waxing Gibbous',
        emoji: '🌔',
        illumination: illum,
        recommendation: 'Plant & Transplant',
        recommendationDetail:
            'Strong growth energy. Great for transplanting seedlings outdoors and planting above-ground crops.',
      );
    } else if (age < 16.61) {
      return MoonPhase(
        name: 'Full Moon',
        emoji: '🌕',
        illumination: illum,
        recommendation: 'Plant Root Crops',
        recommendationDetail:
            'Best day for planting root vegetables — potatoes, carrots, beets, onions, garlic, and turnips.',
      );
    } else if (age < 22.15) {
      return MoonPhase(
        name: 'Waning Gibbous',
        emoji: '🌖',
        illumination: illum,
        recommendation: 'Harvest & Fertilize',
        recommendationDetail:
            'Good for harvesting crops that will be stored. Apply fertilizer and compost — roots absorb well now.',
      );
    } else if (age < 23.99) {
      return MoonPhase(
        name: 'Last Quarter',
        emoji: '🌗',
        illumination: illum,
        recommendation: 'Weed & Prune',
        recommendationDetail:
            'Pull weeds, prune, mow, and cut back. Energy is moving downward — removed growth is less likely to regrow.',
      );
    } else if (age < 29.0) {
      return MoonPhase(
        name: 'Waning Crescent',
        emoji: '🌘',
        illumination: illum,
        recommendation: 'Harvest & Rest',
        recommendationDetail:
            'Good for harvesting herbs and root crops for storage. Prepare beds for next planting cycle.',
      );
    } else {
      return MoonPhase(
        name: 'New Moon',
        emoji: '🌑',
        illumination: illum,
        recommendation: 'Rest & Prepare',
        recommendationDetail:
            'Good time to plan, prepare soil, add compost, and weed.',
      );
    }
  }

  // Returns the next 30 days of moon phases
  static List<Map<String, dynamic>> next30Days() {
    final today = DateTime.now();
    return List.generate(30, (i) {
      final date  = today.add(Duration(days: i));
      final phase = forDate(date);
      return {
        'date':  date,
        'phase': phase,
      };
    });
  }
}
