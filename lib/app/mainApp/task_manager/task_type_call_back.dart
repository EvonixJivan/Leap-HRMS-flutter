class TaskTypeCallBack {
  late int status;
 late bool success;
 String? message;
 late int offset;
 String? totalCount;
 String? extra;
 late int limit;
  List<Data> data =[];

  TaskTypeCallBack(
      {required this.status,
        required this.success,
       required this.message,
       required this.offset,
       required this.totalCount,
       required this.extra,
       required this.limit,
       required this.data});

  TaskTypeCallBack.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    message = json['message'];
    offset = json['offset'];
    totalCount = json['totalCount'];
    extra = json['extra'];
    limit = json['limit'];
    if (json['data'] != null) {
      data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['totalCount'] = this.totalCount;
    data['extra'] = this.extra;
    data['limit'] = this.limit;
    data['data'] = this.data.map((v) => v.toJson()).toList();
      return data;
  }
}

class Data {
  late int id;
  String? typeName;

  Data({required this.id, required this.typeName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeName = json['typeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['typeName'] = this.typeName;
    return data;
  }
}

