class Config {
  //if elton
  //static const String master = 'http://192.168.1.237:5000';
  //if house wifi
  //static const String master = 'http://192.168.0.114:5000';
  //if samsung wifi
  //static const String master = 'http://192.168.101.253:5000';
  //master ip

  static const String master = 'http://192.168.1.237:5000';
  // Change this URL as needed
  static const String serverUpload = '$master/upload';
  static const String ingredient = '$master/recommend_by_ingredients';
  static const String youmaylike = '$master/recommend_popular';
  static const String tag = '$master/recommend_by_tags';
  static const String uploadrecipe = '$master/upload-recipe';
}
