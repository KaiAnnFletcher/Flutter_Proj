class HoursOpen {
  List<String> monday;
  List<String> tuesday;
  List<String> wednesday;
  List<String> thursday;
  List<String> friday;
  List<String> saturday;
  List<String> sunday;

  HoursOpen(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  HoursOpen.fromJson(Map<String, dynamic> json) {
    monday = json['Monday'].cast<String>();
    tuesday = json['Tuesday'].cast<String>();
    wednesday = json['Wednesday'].cast<String>();
    thursday = json['Thursday'].cast<String>();
    friday = json['Friday'].cast<String>();
    saturday = json['Saturday'].cast<String>();
    sunday = json['Sunday'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Monday'] = this.monday;
    data['Tuesday'] = this.tuesday;
    data['Wednesday'] = this.wednesday;
    data['Thursday'] = this.thursday;
    data['Friday'] = this.friday;
    data['Saturday'] = this.saturday;
    data['Sunday'] = this.sunday;
    return data;
  }
}