class ProjectListCallBack {
  List<Data>? data = [];
  String? extra;
  int? limit;
  String? message;
  int? offset;
  int? status;
  bool success;
  int? total;

  ProjectListCallBack({required this.data, required this.extra, required this.limit, required this.message, required this.offset, required this.status, required this.success, required this.total});

  factory ProjectListCallBack.fromJson(Map<String, dynamic> json) {
    return ProjectListCallBack(
      data: json['data'] != null ? (json['data'] as List).map((i) => Data.fromJson(i)).toList() : [],
      extra: json['extra'],
      limit: json['limit'],
      message: json['message'],
      offset: json['offset'],
      status: json['status'],
      success: json['success'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['extra'] = this.extra;
    data['limit'] = this.limit;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total'] = this.total;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Data {
  int? id;
  String? name;

  Data({required this.id, required this.name});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}