import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/connected_user_alarm.dart';
import 'package:snuze/scoped-models/alarm.dart';

class MainModel extends Model with ConnectedUserAlarmModel, UserModel, UtilityModel, AlarmModel{
}
