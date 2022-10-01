// ignore_for_file: omit_local_variable_types

import 'package:aopcommon/aopcommon.dart';
import 'package:test/test.dart';

void main() {
  group('String Tests', stringTests);
  group('Date Tests', dateTests);
}

void stringTests() {
  test('left string', () {
    expect(left('aBcdE', 2), equals('aB'));
    expect(left('aBcdE', 5), equals('aBcdE'));
    expect(left('aBcdE', 6), equals('aBcdE'));
    expect(left('aBcdE', 0), equals(''));
    expect(() => left('xxxx', -1), throwsRangeError);
  });
  test('right string', () {
    expect(right('aBcdE', 2), equals('dE'));
    expect(right('aBcdE', 5), equals('aBcdE'));
    expect(right('aBcdE', 6), equals('aBcdE'));
    expect(right('aBcdE', 0), equals(''));
    expect(() => right('xxxx', -1), throwsRangeError);
  });
} // of stringTests

void dateTests() {
  test('addMonths', () {
    //  (DateTime dt, int value)
    DateTime startDate = DateTime(2000, 4, 4);
    DateTime beforeDate = DateTime(1999, 10, 4);
    DateTime afterDate = DateTime(2001, 8, 4);
    expect(beforeDate, equals(addMonths(startDate, -6)));
    expect(afterDate, equals(addMonths(startDate, 16)));
  });
  test('daysInMonth', () {
    expect(28,equals(daysInMonth(2013,2)));
    expect(31,equals(daysInMonth(2013,12)));
    expect(29,equals(daysInMonth(2016,2)));
    expect(30,equals(daysInMonth(2016,11)));
  });
  test('dbDate', () {
    DateTime dy = DateTime(2020,1,2,3,4,5,6,7,);
    String target = '2020-01-02 03:04:05.006';
    expect(target,equals(dbDate(dy)));
    //  dbDate(DateTime dt)
  });
  test('formatDate', () {
    //  formatDate(DateTime aDate, {String format = 'yyyy-mm-d'})
    DateTime dy = DateTime(2020,1,2,3,4,5,6,7,);
   // String target = '2020-01-02 03:04:05.006';
    expect('2020-01-2',equals(formatDate(dy)));
    expect('2020-01-02',equals(formatDate(dy,format:'yyyy-mm-dd')));
  });
  test('parseDMY', () {
    //  parseDMY(String inputStr, {bool allowYearOnly = false})
  });
  test('dateTimeFromExif', () {
    //  dateTimeFromExif(String exifString)
  });
} // of dateTests
