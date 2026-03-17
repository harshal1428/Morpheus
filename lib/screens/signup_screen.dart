import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const SignupScreen({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Account created! Please check your email.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to login after a delay
        Future.delayed(const Duration(seconds: 2), widget.onLogin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${authService.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF163339),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onLogin,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF5DF22A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Join Morpheus Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8BA5A8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Full Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password Field
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Create a strong password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFF21444A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF5DF22A)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF5DF22A),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Confirm Password Field
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFF21444A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF5DF22A)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF5DF22A),
                    ),
                    onPressed: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value ?? false);
                    },
                    side: const BorderSide(color: Color(0xFF5DF22A)),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                              color: Color(0xFF8BA5A8),
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFF5DF22A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Sign Up Button
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  return ElevatedButton(
                    onPressed:
                        authService.isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DF22A),
                      foregroundColor: const Color(0xFF163339),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade600,
                    ),
                    child: authService.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF163339).withOpacity(0.7),
                              ),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Color(0xFF8BA5A8),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onLogin,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF5DF22A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: const Color(0xFF21444A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF5DF22A)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
