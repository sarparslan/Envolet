final RegExp _emailPattern =
    RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[A-Za-z]{2,}$');

const int minPasswordLength = 6;

bool isValidEmail(String email) => _emailPattern.hasMatch(email.trim());

bool isValidPassword(String password) => password.length >= minPasswordLength;
