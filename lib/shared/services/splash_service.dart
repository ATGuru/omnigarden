class SplashService {
  static String getStageImage(DateTime date, String? zone) {
    // Simple tomato planting calendar for Zone 6a (Northern Indiana)
    final month = date.month;
    final day = date.day;
    
    // Approximate tomato growth stages for Zone 6a
    // Seed: Jan 15 - Mar 15 (indoors)
    // Sprout: Mar 20 - Apr 15 
    // Stem: Apr 20 - May 15
    // Flower: May 16 - Jun 20
    // Harvest: Jun 21 - Sep 15
    
    if ((month == 1 && day >= 15) || (month >= 2 && month <= 3)) {
      return 'assets/images/stages/stage_seed.jpg';
    } else if ((month == 3 && day >= 20) || (month >= 4 && month <= 5)) {
      return 'assets/images/stages/stage_sprout.jpg';
    } else if ((month == 5 && day >= 16) || (month >= 6 && month <= 7)) {
      return 'assets/images/stages/stage_stem.jpg';
    } else if ((month == 6 && day >= 21) || (month >= 7 && month <= 9)) {
      return 'assets/images/stages/stage_flower.jpg';
    } else {
      return 'assets/images/stages/stage_harvest.jpg';
    }
  }
}
