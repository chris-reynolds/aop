/*
  Created by chrisreynolds on 3/09/20
  
  Purpose: This provides a route handler that servers up metadata

*/

import 'dart:io';
import 'package:exif/exif.dart';

Future<String> extractExiff(String path) async {
  List<String> result = [];
  Map<String, IfdTag> data = await readExifFromBytes(await new File(path).readAsBytes());
  if (data == null || data.isEmpty)
    result.add('Error: No EXIF information found');
  else {
    String thisKey = 'JPEGThumbnail';
    if (data.containsKey(thisKey)) {
      result.add('File has $thisKey');
      data.remove(thisKey);
    }
    thisKey = 'TIFFThumbnail';
    if (data.containsKey(thisKey)) {
      result.add('File has $thisKey');
      data.remove(thisKey);
    }
    thisKey = 'EXIF UserComment';
    String zz = data[thisKey].toString();
    if (data.containsKey(thisKey)  && data[thisKey].toString().isNotEmpty &&
        data[thisKey].toString().startsWith('\[0, 0,')) {
      result.add('File has $thisKey');
      data.remove(thisKey);
    }
    for (String key in data.keys) result.add("$key (${data[key].tagType}): ${data[key]}");
  }
  return result.join('\n');
} // of extractExif
