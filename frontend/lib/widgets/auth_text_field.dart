import 'package:flutter/material.dart';

/// Text field used on the login and register screens.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autocorrect: !widget.isPassword,
      onChanged: widget.onChanged,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(widget.icon, color: Colors.grey),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: true,
        fillColor: Colors.white70,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Full-width primary button with a built-in loading state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
