class Validation {
  static isPhoneValid(String phone) {
    var regexPhone = RegExp(r'[0-9]+$');
    return regexPhone.hasMatch(phone);
  }

  static isPasswordValid(String pass) {
    return pass.length >= 6;
  }

  static isDisplayNameValid(String displayName) {
    return displayName.length >= 5;
  }
}
