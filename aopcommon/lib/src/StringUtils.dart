///
///  Created by Chris on 21/09/2018.
///
// ignore_for_file: omit_local_variable_types

String left(String s, int count) {
  if (s.length <= count) {
    return s;
  } else {
    return s.substring(0, count);
  }
} // of left

String right(String s, int count) {
  if (s.length <= count) {
    return s;
  } else {
    return s.substring(s.length - count);
  }
} // of left

String cleanUpLines(String lineStr, String token) {
  List<String> lines = lineStr.split('\n');
  for (int lineIx = lines.length - 1; lineIx >= 0; lineIx--) {
    if (lines[lineIx].contains(token)) lines.removeAt(lineIx);
  }
  return lines.join('\n');
} // of cleanUpLines
