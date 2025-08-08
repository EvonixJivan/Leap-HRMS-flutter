class InsertTaskCallback {
 late int totalCount;
 late bool success;
 late Items? items;
 String? message;
 late int status;
 String? currentTime;
 String? currentUtcTime;

  InsertTaskCallback(
      {required this.totalCount,
       required this.success,
       required this.items,
       required this.message,
       required this.status,
       required this.currentTime,
       required this.currentUtcTime});

  InsertTaskCallback.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'] != null ? Items.fromJson(json['items']) : null;
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.toJson();
      data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Items {
 late int id;
 late int taskId;
 late int userId;
 String? comment;
 String? deviceDateTime;
 late int isSeen;
 late int isdeleted;
 String? createdAt;
 String? updatedAt;

  Items(
      {required this.id,
       required this.taskId,
       required this.userId,
       required this.comment,
       required this.deviceDateTime,
       required this.isSeen,
       required this.isdeleted,
       required this.createdAt,
       required this.updatedAt});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskId = json['taskId'];
    userId = json['userId'];
    comment = json['comment'];
    deviceDateTime = json['deviceDateTime'];
    isSeen = json['isSeen'];
    isdeleted = json['isdeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['taskId'] = this.taskId;
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['deviceDateTime'] = this.deviceDateTime;
    data['isSeen'] = this.isSeen;
    data['isdeleted'] = this.isdeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

