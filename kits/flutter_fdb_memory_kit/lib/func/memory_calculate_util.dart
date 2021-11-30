const int _kMMode = 1024 * 1024;
const int _kKMode = 1024;

class MemoryCalculateUtil {
  static String byteToSizeString(int size) {
    String unitSize = "";
    if (size / _kMMode >= 1) {
      unitSize = "${(size / _kMMode).toStringAsFixed(1)} MB";
    } else if (size / _kKMode >= 1) {
      unitSize = "${(size / _kKMode).toStringAsFixed(1)} KB";
    } else {
      unitSize = "$size B";
    }
    return unitSize;
  }
}
