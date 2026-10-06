class AppConstants {
  static const maxCharacters = 20;
  static const minPasswordLength = 6;
  static const resentCodeTimer = 60;
  static const pageSize = 25;
  static const totalRecords = 25;
  static const maxCharactersForComment = 250;
  static const maxCharactersForCommentItemDetails = 100;
  static const maxCharactersForPrice = 14;
  static const maxCharactersForQuantity = 12;
  static const imageSizeLimitMB = 5; // limit in MB
  static const imageSizeLimitBytes = imageSizeLimitMB * 1000 * 1000;
  static const apptype = "mobile";
  static const List<String> allowedImageFormats = [
    "jpg",
    "jpeg",
    "png",
    "heic",
    "heif"
  ];
}
