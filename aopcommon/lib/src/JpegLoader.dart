/// Created by Chris on 21/09/2018.
// ignore_for_file: omit_local_variable_types

import 'package:exif/exif.dart' as exif;
import 'package:aopcommon/aopcommon.dart';

class JpegLoader {
  static const dynamic UNKNOWN_LONGLAT = null;

  Map<String, dynamic> tags = <String, dynamic>{};

  Future<void> extractTags(List<int> newBuffer) async {
    var progressKey = '';
    tags.clear();
    try {
      var mytags = await exif.readExifFromBytes(newBuffer);
      mytags.forEach((String key, exif.IfdTag value) {
        progressKey = key;
        if (key.length > 6 && key.substring(0, 6) == 'Image ') {
          key = key.substring(6);
        }
        if (key.length > 4 && key.substring(0, 4) == 'GPS ') {
          key = key.substring(4);
        }
        if (key.length > 5 && key.substring(0, 5) == 'EXIF ') {
          key = key.substring(5);
        }
        if (value.tagType.contains('Ratio') &&
            value.printable.startsWith('\[') &&
            value.values is exif.IfdRatios) {
          tags[key] = (value.values as exif.IfdRatios).ratios;
        } else {
          var strValue = value.toString();
          if (int.tryParse(strValue) != null) {
            tags[key] = int.parse(strValue);
          } else {
            tags[key] = strValue;
          }
        }
      });
    } catch (ex, st) {
      log.error('failed to extract tag $progressKey with $ex \n $st');
    }
    if (tags.containsKey('MakerNote')) {
      tags.remove('MakerNote');
    }
//    Log.message('tags length= ${tags.length}');
  }

  String cleanString(String s) {
    RegExp nullMask = RegExp(r'[\0|\00]');
    String result = s.replaceAll(nullMask, '');
    return result.trim();
  } // of cleanString

  double? dmsToDeg(List? dms, String direction) {
    if (dms == null) return UNKNOWN_LONGLAT;
    double result = 0.0;
    for (int ix in [2, 1, 0]) {
      if (dms[ix].denominator > 0) {
        result = result / 60 + (dms[ix].numerator / dms[ix].denominator);
      }
    }
    if ('sSwW'.contains(direction)) result = -result;
    return result;
  } // of dmsToDeg

  DateTime? dateTimeFromExif(String exifString) {
    try {
      String tmp = exifString.substring(0, 4) +
          '-' +
          exifString.substring(5, 7) +
          '-' +
          exifString.substring(8);
      return DateTime.parse(tmp);
    } catch (ex) {
      return null;
    } // of try catch
  } // dateTimeFromExit

  dynamic tag(String tagName) {
    dynamic result;
    tagName = tagName.toLowerCase();
    tags.forEach((String key, value) {
      if (key.toLowerCase() == tagName || key.toLowerCase() == 'image $tagName') {
        result = value;
      }
    });
//      if (result == null)
//        Log.message('++++++++++++++++tag $tagName not found');
    return result;
  }

  void cleanTags() {
    for (var key in tags.keys) {
      if (!(tags[key] is String || tags[key] is int)) {
        tags[key] = tags[key].toString();
      }
    }
  } // of cleanTags
} // of JpegLoader
