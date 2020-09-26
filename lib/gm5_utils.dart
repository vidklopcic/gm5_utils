import 'package:gm5_utils/utils/date_utils.dart';
import 'package:gm5_utils/utils/event_utils.dart';

class _Gm5Utils {
  EventUtils eventUtils = EventUtils();
  DateUtils dateUtils = DateUtils();

  int get secondsFromEpoch => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

_Gm5Utils gm5Utils = _Gm5Utils();
