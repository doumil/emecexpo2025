class Userscan {
  String lastname;
  String firstname;
  String company;
  String profession;
  String email;
  String phone;
  String evolution;
  String action;
  String notes;
  String created;
  String updated;


  Userscan(this.lastname, this.firstname,this.company,this.profession, this.email,this.phone,this.evolution,this.action,this.notes,this.created,this.updated);
  factory Userscan.fromJson(dynamic json) {
    return Userscan(json['lastname'] as String, json['firstname'] as String,
        json['company'] as String,json['profession'] as String, json['email'] as String,
        json['phone'] as String, json['evolution'] as String, json['action'] as String,
        json['notes'] as String, json['created'] as String,
        json['updated'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'lastname': lastname,
      'firstname': firstname,
      'company': company,
      'profession':profession,
      'email': email,
      'phone': phone,
      'evolution': evolution,
      'action': action,
      'notes': notes,
      'created':created,
      'updated':updated
    };
  }
  @override
  String toString() {
    return 'lastname : $lastname,firstname : $firstname,company : $company,proffession : $profession,email : $email,phone : $phone,evolution : $evolution,action : $action,notes : $notes,created : $created,updated : $updated';
  }
}
