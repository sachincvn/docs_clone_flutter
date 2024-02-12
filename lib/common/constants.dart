class Constants {
  static const apiBaseUrl = "http://192.168.0.105:3001";

  static const signUpApi = "$apiBaseUrl/api/signup";
  static const getUserApi = "$apiBaseUrl/";
  static const createDocumentApi = "$apiBaseUrl/doc/create";
  static const getDocuments = "$apiBaseUrl/doc/getDocuments";
  static getDocumentById(String id) => "$apiBaseUrl/doc/$id";
  static const updateTitle = "$apiBaseUrl/doc/title";
}
