class XValidator {
  static const maxFullNameLength = 50;
  static const minFullNameLength = 3;
  static const minNameLength = 1;
  static const maxNameLength = 50;
  static const minPwdLength = 6;
  static final regexSpaces = RegExp(r'\\s+');
  static final regexFullName = RegExp(
    r"^[\p{L}]+([ '-][\p{L}]+)*$",
    unicode: true,
  );
  //r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\/\-=€£¥₹0-9\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]]');
  static final regexPwd = RegExp(
    r'^(0|\+84)(\s|\.)?((3[0-9])|(4[0-9])|(5[0-9])|(7[0-9])|(8[0-9])|(9[0-9]))(\d)(\s|\.)?(\d{3})(\s|\.)?(\d{3})$',
  );
  static final regexEmail = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );
  static final regexGmail = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

  static String? checkPhoneNo(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your phone number';
      //return 'Vui lòng nhập số điện thoại';
    }
    final trimmedText = text!.trim();
    if (regexSpaces.hasMatch(trimmedText)) {
      return 'The phone number must not contain spaces';
      //return 'Số điện thoại không chứa khoảng trắng';
    } else if (!regexPwd.hasMatch(trimmedText)) {
      return 'Invalid phone number';
      //return 'Số điện thoại chưa hợp lệ';
    }
    return null;
  }

  static String? checkEmail(String? text, {bool isGmail = false}) {
    if (text?.trim().isEmpty == true) {
      return ' Please enter your email';
      //return 'Vui lòng nhập email';
    }

    final trimmedText = text?.trim() ?? '';
    final isMatched = isGmail
        ? regexGmail.hasMatch(trimmedText)
        : regexEmail.hasMatch(trimmedText);
    if (!isMatched) {
      return 'Invalid ${isGmail ? 'Gmail' : 'Email'} format';
    }
    return null;
  }

  static String? checkPassword(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your password';
      //return 'Vui lòng nhập mật khẩu';
    }
    final trimmedText = text!.trim();
    if (trimmedText.length < minPwdLength) {
      return 'The password must contain at least $minPwdLength characters';
      //return 'Mật khẩu chứa tối thiểu 8 ký tự';
    }

    return null;
  }

  static String? checkConfirmPassword(String? text, {String? password}) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter the confirmation password';
      //return 'Vui lòng nhập mật khẩu xác nhận';
    }
    final trimmedText = text!.trim();
    if (trimmedText.length < minPwdLength) {
      return 'The password must contain at least $minPwdLength characters';
      //return 'Mật khẩu chứa tối thiểu 8 kí tự';
    }
    final pwdLength = password?.length ?? 0;
    if (pwdLength >= minPwdLength && password != trimmedText) {
      return 'Confirmation password does not match';
      //return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  static String? checkFullName(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your full name';
      //return 'Vui lòng nhập họ tên';
    }
    final trimmedText = text!.trim();
    if (!regexFullName.hasMatch(trimmedText)) {
      return 'Invalid full name';
      //return 'Họ tên chưa hợp lệ';
    }
    final length = trimmedText.length;
    if (length < minFullNameLength) {
      return 'Full name is too short';
      //return 'Họ tên quá ngắn';
    }
    if (length > maxFullNameLength) {
      return 'Full name is too long';
      //return 'Họ tên quá dài';
    }
    return null;
  }

  static String? checkFirstName(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your first name';
      //return 'Vui lòng nhập tên đăng nhập';
    }
    final trimmedText = text!.trim();
    if (!regexFullName.hasMatch(trimmedText)) {
      return 'Invalid first name';
      //return 'Họ tên chưa hợp lệ';
    }
    final length = trimmedText.length;
    if (length < minNameLength) {
      return 'First name is too short';
      //return 'Họ tên quá ngắn';
    }
    if (length > maxNameLength) {
      return 'First name is too long';
      //return 'Họ tên quá dài';
    }
    return null;
  }

  static String? checkLastName(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your last name';
      //return 'Vui lòng nhập tên đăng nhập';
    }
    final trimmedText = text!.trim();
    if (!regexFullName.hasMatch(trimmedText)) {
      return 'Invalid last name';
      //return 'Họ tên chưa hợp lệ';
    }
    final length = trimmedText.length;
    if (length < minNameLength) {
      return 'Last name is too short';
      //return 'Họ tên quá ngắn';
    }
    if (length > maxNameLength) {
      return 'Last name is too long';
      //return 'Họ tên quá dài';
    }

    return null;
  }

  static String? checkUserName(String? text) {
    if (text?.trim().isEmpty == true) {
      return 'Please enter your username';
      //return 'Vui lòng nhập tên đăng nhập';
    }

    return null;
  }

  static bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }

    return double.tryParse(s) != null;
  }
}
