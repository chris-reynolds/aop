import 'dart:async';
import 'package:aopcommon/aopcommon.dart';
import './dbAllOurPhotos.dart';


bool sqlLogging = false;

abstract class DomainObject {
  DomainObject({Map<String, dynamic> data});

  int id;
  DateTime createdOn;
  DateTime updatedOn;
  String updatedUser;
  List<String> lastErrors = [];

  bool get isValid => lastErrors.length == 0;

  Future<void> validate() async {
    lastErrors = [];
  } // this writes to the lastErrors

  Future<void> save() async {
    throw Exception("todo save");
  }

  Map<String, dynamic> toMap();

  void fromMap(Map<String, dynamic> map);

  void fromRow(dynamic row) {
    String fld;
    try {
      fld = 'id';
      id = row[0];
      fld = 'createdOn';
      createdOn = row[1];
      fld = 'updatedOn';
      updatedOn = row[2];
      fld = 'updatedUser';
      updatedUser = row[3];
    } catch (ex) {
      throw Exception('Failed to assign field $fld : ' + ex.toString());
    }
  } // from Row

  List<dynamic> toRow() {
    var result = [];
    result.add(id);
    result.add(createdOn);
    result.add(updatedOn);
    result.add(updatedUser);
    return result;
  } // to Row

} // of abstract class DomainObject

List<int> idList(List<DomainObject> dobjList) {
  List<int> result = [];
  dobjList.forEach((element) {result.add(element.id);});
  return result;
} // of idList

class DOProvider<TDO extends DomainObject> {
  String tableName;
  List<String> columnList;
  SQLStatementFactory sqlStatements;
  Function newFn;

  List<TDO> toList(dynamic r) {
    // todo tighter declaration than dynamic
    var result = <TDO>[];
    for (var row in r) {
      TDO newDomainObject = (newFn() as TDO);
      newDomainObject.fromRow(row);
      result.add(newDomainObject);
    }
    return result;
  }

  DOProvider(this.tableName, this.columnList, this.newFn) {
    sqlStatements = SQLStatementFactory(tableName, columnList);
  }

  Future<dynamic> queryWithReOpen(String sql) async {
    try {
      var r = await dbConn.query(sql);
      return r;
    } catch (ex) {
      log.error('query problem with ${ex.message}\n $sql');
      if (ex.message.substring(0, 12) == 'Cannot write') {
        log.message('reconnecting to database');
        await DbAllOurPhotos.reconnect();
        return await dbConn.query(sql);
      } else
        rethrow;
    } // of catch
  } // of queryWithReOpen

  Future<int> save(TDO aDomainObject) async {
    String sql;
    try {
      List<dynamic> dataFields = aDomainObject.toRow();
      if (aDomainObject.id != null && aDomainObject.id > 0) {
        // then update
        sql = sqlStatements.updateStatement();
        if (sqlLogging) log.message('save sql : $sql');
        dataFields.add(aDomainObject.id);
//        dataFields.add(aDomainObject.updatedOn);
        var r = await dbConn.query(sql, dataFields);
        await refreshFromDb(aDomainObject);
        if (r.affectedRows == 0)
          throw "Failed to update item with $sql";
        return r.affectedRows;
      } else {
        // insert
        sql = sqlStatements.insertStatement();
        if (sqlLogging) log.message('save sql : $sql');
        var r = await dbConn.query(sql, dataFields);
        aDomainObject.id = r.insertId;
        await refreshFromDb(aDomainObject);
        return r.insertId;
      }
    } catch (ex) {
      log.error('$ex');
      rethrow;
    }
  } // of save

  Future<TDO> get(int id) async {
    var r = await dbConn.query(sqlStatements.getStatement(), [id]);
    List<TDO> results = toList(r);
    if (results.length == 0) throw Exception('id $id not found in $tableName');
    if (results.length > 1) throw Exception('id $id is duplicate in $tableName');
    return results[0];
  } //

  Future<List<TDO>> getWithFKey(String keyname, int keyValue) async {
    var sql = sqlStatements.getSomeStatement('$keyname=$keyValue');
    var r = await queryWithReOpen(sql);
    return toList(r);
  }

  Future<List<TDO>> getSome(String whereClause, {String orderBy = 'created_on'}) async {
    var sql = sqlStatements.getSomeStatement(whereClause, orderBy: orderBy);
    try {
      log.message('SQL:$sql');
      var r = await queryWithReOpen(sql);
      return toList(r);
    } catch (ex) {
      log.error(ex.toString());
      rethrow;
    }
  }

  Future<bool> delete(TDO aDomainObect) async {
    var r = await dbConn.query(sqlStatements.deleteStatement(), [aDomainObect.id]);
    if (r.affectedRows == 0)
      throw Exception('Failed Delete for $tableName id=${aDomainObect.id} ');
    else if (sqlLogging) log.message('Delete for $tableName id=${aDomainObect.id} ');
    return true;
  }

  Future<dynamic> rawExecute(String sql, [List<dynamic> params]) async {
    return await dbConn.query(sql, params);
  } // of execute

  Future<int> refreshFromDb(TDO aDomainObject) async {
    var r = await dbConn.query(sqlStatements.getStatement(), [aDomainObject.id]);
//    List<TDO> results = toList(r);
    if (r.length == 0) throw Exception('id ${aDomainObject.id} not found in $tableName');
    aDomainObject.fromRow(r.single);
    return r.affectedRows;
  } //

} // of DOProvider

class SQLStatementFactory {
  final List<String> _lockedColumns = ['id', 'created_on', 'updated_on', 'updated_user'];
  final String _tableName;
  final List<String> _columnNames;
  String _placeholders;

  SQLStatementFactory(this._tableName, this._columnNames) {
    List<String> questions = [];
    _columnNames.forEach((s) {
      questions.add('?');
    });
    _placeholders = questions.join(',');
  }

  String deleteStatement() {
    return 'delete from `$_tableName` where id=?';
  }

  String insertStatement() {
    var result = 'insert into `$_tableName`(${_columnNames.join(",")}) ';
    result += ' values($_placeholders); ';
    return result;
  }

  String updateStatement() {
    var result = 'update `$_tableName` set ';
    _columnNames.forEach((colName) {
      result += '$colName=?,';
    });
    result = result.substring(0, result.length - 1) // trim last comma
        +
        ' where id=? ';
    // todo multi-user and updated_on=?'; // tie breaker for record locking
    return result;
  } // of update Statement

  String getStatement() =>
      'select ${_lockedColumns.join(",")},${_columnNames.join(",")}' +
      ' from $_tableName where id=?';

  String getSomeStatement(String whereClause, {String orderBy = 'created_on'}) =>
      'select ${_lockedColumns.join(",")},${_columnNames.join(",")}' +
      ' from $_tableName where $whereClause order by $orderBy';
} // of SQLStatementFactory
