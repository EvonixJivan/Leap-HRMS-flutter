class StartAttendanceApiCallBack {
  Items? items;
  String message;
  int status;
  bool success;
  int total_count;

  StartAttendanceApiCallBack(
      {required this.items, required this.message, required this.status, required this.success, required this.total_count});

  factory StartAttendanceApiCallBack.fromJson(Map<String, dynamic> json) {
    return StartAttendanceApiCallBack(
      items: json['items'] != null ? Items.fromJson(json['items']) : null,
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.toJson();
      return data;
  }
}

class Items {
  String attachment;
  String created_at;
  int id;
  String inTime;
  int isdeleted;
  String punchDate;
  int punchTypeId;
  String startLatitude;
  String startLongitude;
  String updated_at;
  String userId;

  Items(
      {required this.attachment,
      required this.created_at,
     required this.id,
     required this.inTime,
     required this.isdeleted,
     required this.punchDate,
     required this.punchTypeId,
     required this.startLatitude,
     required this.startLongitude,
     required this.updated_at,
     required this.userId});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      attachment: json['attachment'],
      created_at: json['created_at'],
      id: json['id'],
      inTime: json['inTime'],
      isdeleted: json['isdeleted'],
      punchDate: json['punchDate'],
      punchTypeId: json['punchTypeId'],
      startLatitude: json['startLatitude'],
      startLongitude: json['startLongitude'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachment'] = this.attachment;
    data['created_at'] = this.created_at;
    data['id'] = this.id;
    data['inTime'] = this.inTime;
    data['isdeleted'] = this.isdeleted;
    data['punchDate'] = this.punchDate;
    data['punchTypeId'] = this.punchTypeId;
    data['startLatitude'] = this.startLatitude;
    data['startLongitude'] = this.startLongitude;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}

class StopAttendanceApiCallBack {
  StopItems? items;
  String message;
  int status;
  bool success;
  int total_count;

  StopAttendanceApiCallBack(
      {required this.items, required this.message, required this.status, required this.success, required this.total_count});

  factory StopAttendanceApiCallBack.fromJson(Map<String, dynamic> json) {
    return StopAttendanceApiCallBack(
      items: json['items'] != null ? StopItems.fromJson(json['items']) : null,
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.toJson();
      return data;
  }
}

class StopItems {
  String? approval_status;
  String? reason;
  String attachment;
  String created_at;
  String endLatitude;
  String endLongitute;
  int id;
  String inTime;
  int isdeleted;
  String outTime;
  String punchDate;
  int punchTypeId;
  String startLatitude;
  String startLongitude;
  int status;
  String updated_at;
  int userId;

  StopItems({
    this.approval_status,
    this.reason,
    required this.attachment,
    required this.created_at,
    required this.endLatitude,
    required this.endLongitute,
    required this.id,
    required this.inTime,
    required this.isdeleted,
    required this.outTime,
    required this.punchDate,
    required this.punchTypeId,
    required this.startLatitude,
    required this.startLongitude,
    required this.status,
    required this.updated_at,
    required this.userId,
  });

  factory StopItems.fromJson(Map<String, dynamic> json) {
    return StopItems(
      approval_status: json['approval_status'],
      reason: json['reason'],
      attachment: json['attachment'],
      created_at: json['created_at'],
      endLatitude: json['endLatitude'],
      endLongitute: json['endLongitute'],
      id: json['id'],
      inTime: json['inTime'],
      isdeleted: json['isdeleted'],
      outTime: json['outTime'],
      punchDate: json['punchDate'],
      punchTypeId: json['punchTypeId'],
      startLatitude: json['startLatitude'],
      startLongitude: json['startLongitude'],
      status: json['status'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['approval_status'] = this.approval_status;
    data['reason'] = this.reason;
    data['attachment'] = this.attachment;
    data['created_at'] = this.created_at;
    data['endLatitude'] = this.endLatitude;
    data['endLongitute'] = this.endLongitute;
    data['id'] = this.id;
    data['inTime'] = this.inTime;
    data['isdeleted'] = this.isdeleted;
    data['outTime'] = this.outTime;
    data['punchDate'] = this.punchDate;
    data['punchTypeId'] = this.punchTypeId;
    data['startLatitude'] = this.startLatitude;
    data['startLongitude'] = this.startLongitude;
    data['status'] = this.status;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}

class PauseAttendanceApiCall {
  PauseItems? items;
  String message;
  int status;
  bool success;
  int total_count;

  PauseAttendanceApiCall(
      {required this.items, required this.message, required this.status, required this.success, required this.total_count});

  factory PauseAttendanceApiCall.fromJson(Map<String, dynamic> json) {
    return PauseAttendanceApiCall(
      items: json['items'] != null ? PauseItems.fromJson(json['items']) : null,
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.toJson();
      return data;
  }
}

class PauseItems {
  String created_at;
  int id;
  String inTime;
  int isdeleted;
  String punchDate;
  int punchTypeId;
  String reason;
  String startLatitude;
  String startLongitude;
  String updated_at;
  String userId;

  PauseItems(
      {required this.created_at,
     required this.id,
     required this.inTime,
     required this.isdeleted,
     required this.punchDate,
     required this.punchTypeId,
     required this.reason,
     required this.startLatitude,
     required this.startLongitude,
     required this.updated_at,
     required this.userId});

  factory PauseItems.fromJson(Map<String, dynamic> json) {
    return PauseItems(
      created_at: json['created_at'],
      id: json['id'],
      inTime: json['inTime'],
      isdeleted: json['isdeleted'],
      punchDate: json['punchDate'],
      punchTypeId: json['punchTypeId'],
      reason: json['reason'],
      startLatitude: json['startLatitude'],
      startLongitude: json['startLongitude'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['id'] = this.id;
    data['inTime'] = this.inTime;
    data['isdeleted'] = this.isdeleted;
    data['punchDate'] = this.punchDate;
    data['punchTypeId'] = this.punchTypeId;
    data['reason'] = this.reason;
    data['startLatitude'] = this.startLatitude;
    data['startLongitude'] = this.startLongitude;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}

class ResumeAttendanceApiCallBack {
  String message;
  ResumeItems? resumeItems;
  int status;
  bool success;
  int total_count;

  ResumeAttendanceApiCallBack(
      {required this.message,
      required this.resumeItems,
     required this.status,
     required this.success,
     required this.total_count});

  factory ResumeAttendanceApiCallBack.fromJson(Map<String, dynamic> json) {
    return ResumeAttendanceApiCallBack(
      message: json['message'],
      resumeItems:
          json['items'] != null ? ResumeItems.fromJson(json['items']) : null,
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.resumeItems!.toJson();
      return data;
  }
}

class ResumeItems {
  String? approval_status;
  String? attachment;
  String created_at;
  String endLatitude;
  String endLongitute;
  int id;
  String inTime;
  int isdeleted;
  String outTime;
  String punchDate;
  int punchTypeId;
  String reason;
  String startLatitude;
  String startLongitude;
  int status;
  String updated_at;
  int userId;

  ResumeItems(
      {required this.approval_status,
     required this.attachment,
     required this.created_at,
     required this.endLatitude,
     required this.endLongitute,
     required this.id,
     required this.inTime,
     required this.isdeleted,
     required this.outTime,
     required this.punchDate,
     required this.punchTypeId,
     required this.reason,
     required this.startLatitude,
     required this.startLongitude,
     required this.status,
     required this.updated_at,
     required this.userId});

  factory ResumeItems.fromJson(Map<String, dynamic> json) {
    return ResumeItems(
      approval_status: json['approval_status'],
      attachment: json['attachment'],
      created_at: json['created_at'],
      endLatitude: json['endLatitude'],
      endLongitute: json['endLongitute'],
      id: json['id'],
      inTime: json['inTime'],
      isdeleted: json['isdeleted'],
      outTime: json['outTime'],
      punchDate: json['punchDate'],
      punchTypeId: json['punchTypeId'],
      reason: json['reason'],
      startLatitude: json['startLatitude'],
      startLongitude: json['startLongitude'],
      status: json['status'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['approval_status'] = this.approval_status;
    data['attachment'] = this.attachment;
    data['created_at'] = this.created_at;
    data['endLatitude'] = this.endLatitude;
    data['endLongitute'] = this.endLongitute;
    data['id'] = this.id;
    data['inTime'] = this.inTime;
    data['isdeleted'] = this.isdeleted;
    data['outTime'] = this.outTime;
    data['punchDate'] = this.punchDate;
    data['punchTypeId'] = this.punchTypeId;
    data['reason'] = this.reason;
    data['startLatitude'] = this.startLatitude;
    data['startLongitude'] = this.startLongitude;
    data['status'] = this.status;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}

class GeoTrackingAddApiCallBack {
  int id;
  int serverId;

  GeoTrackingAddApiCallBack({required this.id, required this.serverId});

  factory GeoTrackingAddApiCallBack.fromJson(Map<String, dynamic> json) {
    return GeoTrackingAddApiCallBack(
      id: json['id'],
      serverId: json['serverId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['serverId'] = this.serverId;
    return data;
  }
}

class WorkingTypeApiCallBack {
  int? totalCount;
  bool? success;
  List<Item>? items;
  String? message;
  int? status;
  String? currentTime;
  String? currentUtcTime;

  WorkingTypeApiCallBack({
    this.totalCount,
    this.success,
    this.items,
    this.message,
    this.status,
    this.currentTime,
    this.currentUtcTime,
  });

  WorkingTypeApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_count'] = totalCount;
    data['success'] = success;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['status'] = status;
    data['current_time'] = currentTime;
    data['current_utc_time'] = currentUtcTime;
    return data;
  }
}

class Item {
 late int id;
 String? name;
 late int status;
 late int geofencing;
 String? createdAt;
 String? updatedAt;

  Item(
      {required this.id,
     required this.name,
     required this.status,
     required this.geofencing,
     required this.createdAt,
     required this.updatedAt});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    geofencing = json['geofencing'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['geofencing'] = this.geofencing;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class TodaysBirthdayApiCallBack {
 late int totalCount;
 late bool success;
List<BirthdayItems>? items;
 String? message;
 late int status;
 String? currentTime;
 String? currentUtcTime;

  TodaysBirthdayApiCallBack(
      {required this.totalCount,
      required this.success,
     required this.items,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  TodaysBirthdayApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        items!.add(new BirthdayItems.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class BirthdayItems {
 late int id;
 String? profileImage;
 String? contactNo;
 late int companyId;
 String? firstName;
 String? lastName;
 String? birthDate;

  BirthdayItems(
      {required this.id,
     required this.profileImage,
     required this.contactNo,
     required this.companyId,
     required this.firstName,
     required this.lastName,
     required this.birthDate});

  BirthdayItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileImage = json['profileImage'];
    contactNo = json['contact_no'];
    companyId = json['company_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    birthDate = json['birth_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['profileImage'] = this.profileImage;
    data['contact_no'] = this.contactNo;
    data['company_id'] = this.companyId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['birth_date'] = this.birthDate;
    return data;
  }
}

class LocationTracking {
 late int totalCount;
 late bool success;
 late List<Tracking> trackingItems;
 String? message;
 late int status;
 String? currentTime;
 String? currentUtcTime;

  LocationTracking(
      {required this.totalCount,
     required this.success,
     required this.trackingItems,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  LocationTracking.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        trackingItems.add(new Tracking.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.trackingItems.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Tracking {
 late int userid;
 String? date;
 late int deviceId;
 String? latitude;
 String? longitude;
 String? deviceDate;
 late int locationAccuracy;
 late int isDeleted;

  Tracking(
      {required this.userid,
     required this.date,
     required this.deviceId,
     required this.latitude,
     required this.longitude,
     required this.deviceDate,
     required this.locationAccuracy,
     required this.isDeleted});

  Tracking.fromJson(Map<String, dynamic> json) {
    userid = json['userId'];
    date = json['date'];
    deviceId = json['deviceId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    deviceDate = json['deviceDate'];
    locationAccuracy = json['locationAccuracy'];
    isDeleted = json['isdeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userid;
    data['date'] = this.date;
    data['deviceId'] = this.deviceId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['deviceDate'] = this.deviceDate;
    data['locationAccuracy'] = this.locationAccuracy;
    data['isdeleted'] = this.isDeleted;
    return data;
  }
}
