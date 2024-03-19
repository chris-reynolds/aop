///
/// Created by Chris on 15/03/2024.
///
///

String onlyFileName(String path) => (path.lastIndexOf('/') > 0)
    ? path.substring(path.lastIndexOf('/') + 1)
    : path.substring(path.lastIndexOf('\\') + 1);

String onlyDirectory(String path) => (path.lastIndexOf('/') > 0)
    ? path.substring(0, path.lastIndexOf('/'))
    : path.substring(0, path.lastIndexOf('\\'));

String onlyExtension(String path) => path.substring(path.lastIndexOf('.') + 1);
