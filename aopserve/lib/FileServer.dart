/*
  Created by chrisreynolds on 15/10/20
  
  Purpose: This provides a static webserver BUT NOT YET USED. Still using VirtualDirectory.

*/
import 'dart:io';


class FileServer {
  Directory? _rootDir;

  FileServer(String dirName)  {
    Directory fl = Directory(dirName);
    if (   fl.existsSync())
      _rootDir = Directory(dirName);
    else
      throw '$dirName does not exist';
  }
}

