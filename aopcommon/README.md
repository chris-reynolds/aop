A common library for All Our Photos apps.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:aopcommon/aopcommon.dart';

main() {
  loadConfig(filename);
}
```

## Features and bugs

### Global Objects are:
1. config
3. log

### List support
1. mixin Selection\<T\>
2. abstract class ListProvider<T>

### Utility functions are:
1. left(String,int)
3. right(String,int)
4. addMonths(DateTime dt, int value)
5. daysInMonth(int year, int month)
6. dbDate(DateTime dt)
7. formatDate(DateTime aDate, {String format = 'yyyy-mm-d'})
8. parseDMY(String inputStr, {bool allowYearOnly = false})
9. dateTimeFromExif(String exifString)



Please don't file feature requests and bugs.


