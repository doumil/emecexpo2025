class Speakers {
  String fname;
  String lname;
  String company;
  String definition;
  String characteristic;
  String image;
  bool isFavorite;



  Speakers(this.fname, this.lname,this.company,this.definition, this.characteristic,this.image,this.isFavorite);
  factory Speakers.fromJson(dynamic json) {
    return Speakers(json['fname'] as String, json['lname'] as String,json['company'] as String,
      json['definition'] as String, json['characteristic'] as String,json['image'] as String,json['isFavorite'] as bool);
  }
  Map<String, dynamic> toMap() {
    return {
      'fname': fname,
      'lname': lname,
      'company': company,
      'definition': definition,
      'characteristic': characteristic,
      'image': image,
      'isFavorite': isFavorite,
    };
  }
  @override
  String toString() {
    return 'firstname : $lname,lastname : $fname,definition : $definition,characteristic : $characteristic,image : $image,isFavorite : $isFavorite';
  }
}
