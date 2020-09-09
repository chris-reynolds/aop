///
///  Created by chrisreynolds on 2019-05-29
///
///  Purpose: This can contain any list utility functions
///
///
// ignore_for_file: omit_local_variable_types

mixin Selection<T> {
  List<T> _selectionlist = <T>[]; // ignore: prefer_final_fields
  bool isSelected(T dObj) {
    int idx = _selectionlist.indexOf(dObj);
    return (idx>=0);
  } // of isSelected

  void setSelected(T dObj, bool value) {
    int idx = _selectionlist.indexOf(dObj);
    if (idx<0  && value) {
      _selectionlist.add(dObj);
    } else if (idx>=0 && !value) {
      _selectionlist.removeAt(idx);
    }
  } // of setSelected

  void toggleSelected(T dObj) {
    int idx = _selectionlist.indexOf(dObj);
    if (idx<0) {
      _selectionlist.add(dObj);
    } else {
      _selectionlist.removeAt(idx);
    }
  } // of toggleSelected;

  void clearSelected() {
    _selectionlist.length = 0;
  } // clearSelected

  List<T> get selectionList => _selectionlist;
} // of Selection

