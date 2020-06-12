class BusyHours {
  List<int> monday;
  List<int> tuesday;
  List<int> wednesday;
  List<int> thursday;
  List<int> friday;
  List<int> saturday;
  List<int> sunday;
  BusyHours(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});
  BusyHours.fromJson(Map<String, dynamic> json) {
    monday = json['Monday'].cast<int>();
    tuesday = json['Tuesday'].cast<int>();
    wednesday = json['Wednesday'].cast<int>();
    thursday = json['Thursday'].cast<int>();
    friday = json['Friday'].cast<int>();
    saturday = json['Saturday'].cast<int>();
    sunday = json['Sunday'].cast<int>();
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