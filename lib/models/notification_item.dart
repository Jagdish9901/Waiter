// class NotificationItem {
//   final String orderNo;
//   final String itemName;
//   final String tableName;
//   final DateTime timestamp;
//   bool isRead;

//   NotificationItem({
//     required this.orderNo,
//     required this.itemName,
//     required this.tableName,
//     required this.timestamp,
//     this.isRead = false,
//   });

//   // Add this if you need to create from JSON
//   factory NotificationItem.fromJson(Map<String, dynamic> json) {
//     final kotMasDTO = json['kotMasDTO'];
//     return NotificationItem(
//       orderNo: kotMasDTO['shopvno'].toString(),
//       itemName: kotMasDTO['itname'] ?? 'Unknown Item',
//       tableName: json['tablename'] ?? 'Unknown Table',
//       timestamp: DateTime.now(),
//     );
//   }
// }

// notification not showing after logout

class NotificationItem {
  final String orderNo;
  final String itemName;
  final String tableName;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.orderNo,
    required this.itemName,
    required this.tableName,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final kotMasDTO = json['kotMasDTO'];
    return NotificationItem(
      orderNo: kotMasDTO['shopvno'].toString(),
      itemName: kotMasDTO['itname'] ?? 'Unknown Item',
      tableName: json['tablename'] ?? 'Unknown Table',
      timestamp: DateTime.now(),
    );
  }
}
