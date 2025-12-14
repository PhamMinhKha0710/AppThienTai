

/// VALIDATION CLASS
class MinhValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  /// Username Validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required.';
    }

    // Define a regular expression pattern for the username.
    const pattern = r"^[a-zA-Z0-9_-]{3,20}$";

    // Create a RegExp instance from the pattern.
    final regex = RegExp(pattern);

    // Use the hasMatch method to check if the username matches the pattern.
    bool isValid = regex.hasMatch(username);

    // Check if the username doesn't start or end with an underscore or hyphen.
    if (isValid) {
      isValid = !username.startsWith('_') && !username.startsWith('-') && !username.endsWith('_') && !username.endsWith('-');
    }

    if (!isValid) {
      return 'Username is not valid.';
    }

    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bạn phải nhập mật khẩu.';
    }

    // Độ dài tối thiểu
    // if (value.length < 6) {
    //   return 'Mật khẩu phải có ít nhất 6 ký tự.';
    // }

    // Chữ in hoa
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Mật khẩu phải có ít nhất một chữ cái in hoa (A–Z).';
    // }

    // Chữ số
    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'Mật khẩu phải có ít nhất một chữ số.';
    // }

    // Ký tự đặc biệt
    // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    //   return 'Mật khẩu phải có ít nhất một ký tự đặc biệt (ví dụ: ! @ # \$ % ...).';
    // }

    return null;
  }


  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bạn phải nhập số điện thoại';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{9,12}$');


    if (!phoneRegExp.hasMatch(value)) {
      return 'Định dạng số điện thoại không hợp lệ (yêu cầu 9, 10, 11, 12 chữ số).';
    }

    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Bạn cần phải xác nhận mật khẩu';
    }

    if (password == null || password.isEmpty) {
      return 'Bạn phải nhập mật khẩu';
    }

    if (password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp!';
    }

    return null;
  }

// Add more custom validators as needed for your specific requirements.
}














