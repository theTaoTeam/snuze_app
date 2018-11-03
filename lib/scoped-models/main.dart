import 'package:scoped_model/scoped_model.dart';

import './connected_user_alarm.dart';
import './alarm.dart';

class MainModel extends Model with ConnectedUserAlarmModel, UserModel, UtilityModel, AlarmModel{
}
