import 'dart:math';

/// 生成一个简单的唯一 id
String generateUniqueId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random();
  final randomNumber = random.nextInt(10000);
  final uniqueId = '${timestamp}_$randomNumber';
  return uniqueId;
}
