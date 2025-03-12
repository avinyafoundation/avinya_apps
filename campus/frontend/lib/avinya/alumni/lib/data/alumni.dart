class Alumni {
  int? id;
  String? status;
  String? company_name;
  String? job_title;
  String? linkedin_id;
  String? facebook_id;
  String? instagram_id;
  String? updated_by;

  Alumni({
    this.id,
    this.status,
    this.company_name,
    this.job_title,
    this.linkedin_id,
    this.facebook_id,
    this.instagram_id,
    this.updated_by
  });

  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['id'],
      status: json['status'],
      company_name: json['company_name'],
      job_title: json['job_title'],
      linkedin_id: json['linkedin_id'],
      facebook_id:json['facebook_id'],
      instagram_id: json['instagram_id'],
      updated_by:json['updated_by']
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (status != null) 'status': status,
        if (company_name != null) 'company_name': company_name,
        if (job_title != null) 'job_title': job_title,
        if (linkedin_id !=null) 'linkedin_id': linkedin_id,
        if (facebook_id !=null) 'facebook_id': facebook_id,
        if (instagram_id !=null) 'instagram_id':instagram_id,
        if (updated_by !=null) 'updated_by': updated_by
      };
}
