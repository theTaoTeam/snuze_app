import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/scoped-models/alarm.dart';
import 'package:snuze/scoped-models/user.dart';
import 'package:snuze/scoped-models/snuze.dart';

class MainModel extends Model with UserModel, AlarmModel, SnuzeModel {}