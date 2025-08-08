
class EmployeeTaskApiCallBack {
 late int status;
 String? message;
 late int offset;
 late bool suceess;
 late int count;
 late int limit;
 late int totalCount;
 late int taskApprovedCount;
 late int taskNonApprovedCount;
 late int taskCount;
  List<Data> data =[];

  EmployeeTaskApiCallBack(
      {required this.status,
     required this.message,
     required this.offset,
     required this.suceess,
     required this.count,
     required this.limit,
     required this.totalCount,
       required this.taskApprovedCount,
       required this.taskNonApprovedCount,
       required this.taskCount,
     required this.data});

  EmployeeTaskApiCallBack.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    offset = json['offset'];
    suceess = json['suceess'];
    count = json['count'];
    limit = json['limit'];
    totalCount = json['totalCount'];
    taskApprovedCount = json['taskApprovedCount'];
    taskNonApprovedCount = json['taskNonApprovedCount'];
    taskCount = json['taskCount'];
    if (json['data'] != null) {
        data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
      }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['suceess'] = this.suceess;
    data['count'] = this.count;
    data['limit'] = this.limit;
    data['totalCount'] = this.totalCount;
    data['taskApprovedCount'] = this.taskApprovedCount;
    data['taskNonApprovedCount'] = this.taskNonApprovedCount;
    data['taskCount'] = this.taskCount;
    data['data'] = this.data.map((v) => v.toJson()).toList();
      return data;
  }
}

class Data {
 late int id;
 String? task;
 String? minutes;
 String? projectName;
 String? clientName;
 late int percentage;
 late int isNew;
 late int commentCount = 0;
 late int isApproved;
 String? createdAt;

  Data(
      {required this.id,
      required this.task,
      required this.minutes,
      required this.projectName,
      required this.clientName,
      required this.percentage,
      required this.isNew,
      required this.isApproved,
      required this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    task = json['task'];
    minutes = json['minutes'];
    projectName = json['projectName'];
    clientName = json['clientName'];
    percentage = json['percentage'];
    isNew = json['isNew'];
    isApproved = json['isApproved'];
    createdAt = json['created_at'];
    commentCount = json['commentCount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['task'] = this.task;
    data['minutes'] = this.minutes;
    data['projectName'] = this.projectName;
    data['clientName'] = this.clientName;
    data['percentage'] = this.percentage;
    data['isNew'] = this.isNew;
    data['isApproved'] = this.isApproved;
    data['created_at'] = this.createdAt;
    return data;
  }
}
