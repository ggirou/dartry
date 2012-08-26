class FollowersCount {
  String id;
  var value;
  
  FollowersCount(this.id, this.value);
  
  FollowersCount.parse(String json) {
    var obj = JSON.parse(json);
    id = obj["id"];
    value = obj["value"];
  }
  
  toString() => JSON.stringify({"id": id, "value": value});
}
