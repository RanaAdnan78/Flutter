class CompanyModel {
  final String id;
  final String userId;
  final String businessName;
  final String registrationNo;
  final String ntn;
  final String province;
  final String address;
  final String phone;
  final String? email;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.registrationNo,
    required this.ntn,
    required this.province,
    required this.address,
    required this.phone,
    this.email,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CompanyModel(
      id: documentId,
      userId: data['userId'] ?? '',
      businessName: data['businessName'] ?? '',
      registrationNo: data['registrationNo'] ?? '',
      ntn: data['ntn'] ?? '',
      province: data['province'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      logoUrl: data['logoUrl'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as DateTime) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as DateTime) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'registrationNo': registrationNo,
      'ntn': ntn,
      'province': province,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
