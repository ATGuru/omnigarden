// lib/core/constants/app_constants.dart

abstract final class AppConstants {
  // ── Spacing scale (8pt grid) ────────────────────────────
  static const spXS  = 4.0;
  static const spSM  = 8.0;
  static const spMD  = 16.0;
  static const spLG  = 24.0;
  static const spXL  = 32.0;
  static const spXXL = 48.0;

  // ── Content constraints ─────────────────────────────────
  static const maxContentWidth = 480.0;
  static const minTapTarget    = 48.0;

  // ── Animation durations ─────────────────────────────────
  static const animFast   = Duration(milliseconds: 150);
  static const animNormal = Duration(milliseconds: 300);
  static const animSlow   = Duration(milliseconds: 500);

  // ── Phase 1 hard-coded frost dates by zone ──────────────
  // Format: zone -> { lastFrost (spring), firstFrost (fall) }
  static const Map<String, Map<String, String>> frostDates = {
    'Zone 3a': {'last': 'Jun 1',  'first': 'Sep 15'},
    'Zone 3b': {'last': 'May 25', 'first': 'Sep 20'},
    'Zone 4a': {'last': 'May 20', 'first': 'Sep 25'},
    'Zone 4b': {'last': 'May 12', 'first': 'Oct 1'},
    'Zone 5a': {'last': 'May 5',  'first': 'Oct 8'},
    'Zone 5b': {'last': 'Apr 25', 'first': 'Oct 15'},
    'Zone 6a': {'last': 'Apr 18', 'first': 'Oct 25'}, // Fort Wayne IN
    'Zone 6b': {'last': 'Apr 10', 'first': 'Nov 1'},
    'Zone 7a': {'last': 'Apr 3',  'first': 'Nov 8'},  // West Plains MO
    'Zone 7b': {'last': 'Mar 28', 'first': 'Nov 15'},
    'Zone 8a': {'last': 'Mar 20', 'first': 'Nov 22'},
    'Zone 8b': {'last': 'Mar 10', 'first': 'Dec 1'},
    'Zone 9a': {'last': 'Feb 28', 'first': 'Dec 10'},
    'Zone 9b': {'last': 'Feb 15', 'first': 'Dec 20'},
  };

  // ── Month → zone greeting (dry-humor Mom voice) ─────────
  // Removed dashboardGreetings - now using dynamic seasonal tips in dashboard hero
}
