///
///  Created by Chris on 21/09/2018.
///
// ignore_for_file: omit_local_variable_types

String left(String s, int count) {
  if (s.length<=count) {
    return s;
  } else {
    return s.substring(0, count);
  }
} // of left

String right(String s, int count) {
  if (s.length<=count) {
    return s;
  } else {
    return s.substring(s.length - count);
  }
} // of left
