import 'dart:async';
import 'package:mysql1/mysql1.dart';
import 'package:aopcommon/aopcommon.dart';


MySqlConnection dbConn;

class DbAllOurPhotos {
  static Map _lastConfig;
  Future<int> initConnection(Map config) async {
    if (dbConn==null ) {
      if (config['dbname'] == null) throw 'No db config';
      dbConn = await MySqlConnection.connect(new ConnectionSettings(
          host: config['dbhost'], port: int.tryParse(config['dbport']??'1111'), user: config['dbuser'],
          password:config['dbpassword'], db: config['dbname']));
      log.message('Database connected to ${config["dbhost"]} ${config["dbname"]}');
      _lastConfig = config; // save for reconnect
    }
    return 1;
  } // future<int> forces us to use await with compile error

  Future<int> startSession(Map config) async {
    try {
      Results res = await dbConn.query("select spsessioncreate('${config['sesuser']}','${config['sespassword']}','${config['sesdevice']}')");
      Iterable spResult = res.first.asMap().values;
      int sessionid = spResult.first as int;
      log.message('session created with id=$sessionid');
      return sessionid;
    } catch(ex) {
      throw "Failed to create aop session $ex";
    }

  } // of startSession

  static Future<int> reconnect() async {
    if (dbConn!=null)
      dbConn.close();
    dbConn = null;
    var dbAop = DbAllOurPhotos();
    await dbAop.initConnection(_lastConfig);
    await dbAop.startSession(_lastConfig);
    return 1;
  }
  /*
  Future<dynamic> addImage(Media item,List<int> picContents) async {
    // Insert some data
    await initConnection();
    var result = await dbConn.query(
        'insert into aopimages ( file_name, width,height, taken_date, longitude, latitude, directory, ranking, has_thumbnail, media) '
            +'values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
        [ item.name, item.width, item.height, item.taken_date.toIso8601String(), item.longtitude, item.latitude,'mydirectory', 3, 0, picContents]);
    print("Inserted row - aopimages id=${result.insertId}");
  } // addImage
*/
  void close() {
    if (dbConn!=null)
      dbConn.close();
    dbConn = null;
  }  // of close


}  // of DbAllOurPhotos


