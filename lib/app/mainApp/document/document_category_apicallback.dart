class DocumentCategoryApiCallBack {
   int? totalCount;
   bool? success;
   List<Items>? items;
  String? message;
   int? status;
  String? currentTime;
  String? currentUtcTime;

  DocumentCategoryApiCallBack(
      {required this.totalCount,
        required this.success,
        required this.items,
        required this.message,
        required this.status,
        required this.currentTime,
        required this.currentUtcTime});

  DocumentCategoryApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
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

class Items {
   int? id;
   int? parentId;
  String? categoryName;
   int? categoryType;
   int? accessLevel;
   int? companyId;
  String? department;
  String? locations;
  String? designations;
   int? status;
   int? createdBy;
   int? isdeleted;
  String? createdAt;
  String? updatedAt;
   Company? company;
   List<SubCategory>? subCategory;

  Items(
      {required this.id,
        required this.parentId,
        required this.categoryName,
        required this.categoryType,
        required this.accessLevel,
        required this.companyId,
        required this.department,
        required this.locations,
        required this.designations,
        required this.status,
        required this.createdBy,
        required this.isdeleted,
        required this.createdAt,
        required this.updatedAt,
        required this.company,
        required this.subCategory});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    categoryName = json['category_name'];
    categoryType = json['category_type'];
    accessLevel = json['access_level'];
    companyId = json['company_id'];
    department = json['department'];
    locations = json['locations'];
    designations = json['designations'];
    status = json['status'];
    createdBy = json['created_by'];
    isdeleted = json['isdeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    company =
    json['company'] != null ? new Company.fromJson(json['company']) : null;
    if (json['sub_category'] != null) {
      subCategory = [];
      json['sub_category'].forEach((v) {
        subCategory!.add(new SubCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['category_name'] = this.categoryName;
    data['category_type'] = this.categoryType;
    data['access_level'] = this.accessLevel;
    data['company_id'] = this.companyId;
    data['department'] = this.department;
    data['locations'] = this.locations;
    data['designations'] = this.designations;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['isdeleted'] = this.isdeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['company'] = this.company!.toJson();
      data['sub_category'] = this.subCategory!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Company {
   int? id;
   int? parentId;
  String? companyName;
  String? companyEmail;
  String? companyLocation;
  String? companyAddress;
  String? companyNumber;
  String? companyLogo;
  String? fulldayWorkingHours;
  String? halfdayWorkingHours;
  String? weekendDays;
   int? isdeleted;
   int? status;
  String? createdAt;
  String? updatedAt;
   int? createdBy;

  Company(
      {required this.id,
        required this.parentId,
        required this.companyName,
        required this.companyEmail,
        required this.companyLocation,
        required this.companyAddress,
        required this.companyNumber,
        required this.companyLogo,
        required this.fulldayWorkingHours,
        required this.halfdayWorkingHours,
        required this.weekendDays,
        required this.isdeleted,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
        required this.createdBy});

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    companyName = json['company_name'];
    companyEmail = json['company_email'];
    companyLocation = json['company_location'];
    companyAddress = json['company_address'];
    companyNumber = json['company_number'];
    companyLogo = json['company_logo'];
    fulldayWorkingHours = json['fullday_working_hours'];
    halfdayWorkingHours = json['halfday_working_hours'];
    weekendDays = json['weekend_days'];
    isdeleted = json['isdeleted'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['company_name'] = this.companyName;
    data['company_email'] = this.companyEmail;
    data['company_location'] = this.companyLocation;
    data['company_address'] = this.companyAddress;
    data['company_number'] = this.companyNumber;
    data['company_logo'] = this.companyLogo;
    data['fullday_working_hours'] = this.fulldayWorkingHours;
    data['halfday_working_hours'] = this.halfdayWorkingHours;
    data['weekend_days'] = this.weekendDays;
    data['isdeleted'] = this.isdeleted;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    return data;
  }
}

class SubCategory {
  int? id;
  int? parentId;
  String? categoryName;
  int? categoryType;
  int? accessLevel;
  int? companyId;
  String? department;
  String? locations;
  String? designations;
  int? status;
  int? createdBy;
  int? isdeleted;
  String? createdAt;
  String? updatedAt;
   Company? company;

  SubCategory(
      {required this.id,
        required this.parentId,
        required this.categoryName,
        required this.categoryType,
        required this.accessLevel,
        required this.companyId,
        required this.department,
        required this.locations,
        required this.designations,
        required this.status,
        required this.createdBy,
        required this.isdeleted,
        required this.createdAt,
        required this.updatedAt,
        required this.company});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    categoryName = json['category_name'];
    categoryType = json['category_type'];
    accessLevel = json['access_level'];
    companyId = json['company_id'];
    department = json['department'];
    locations = json['locations'];
    designations = json['designations'];
    status = json['status'];
    createdBy = json['created_by'];
    isdeleted = json['isdeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    company = Company.fromJson(json['company']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['category_name'] = this.categoryName;
    data['category_type'] = this.categoryType;
    data['access_level'] = this.accessLevel;
    data['company_id'] = this.companyId;
    data['department'] = this.department;
    data['locations'] = this.locations;
    data['designations'] = this.designations;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['isdeleted'] = this.isdeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['company'] = this.company!.toJson();
      return data;
  }
}


