import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mtm/core/theme/app_palette.dart';
import 'package:mtm/services/privy_service.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final otpController = useTextEditingController();
    final isEmailSent = useState(false);
    final isLoading = useState(false);
    final privyService = PrivyService();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.musicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppPalette.contrastLight,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 50,
                    color: AppPalette.musicPurple,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Welcome to MTM',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.contrastLight,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Music That Matters',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppPalette.contrastMedium,
                  ),
                ),

                const SizedBox(height: 48),

                // Login form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!isEmailSent.value) ...[
                        // Email input
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(
                              color: AppPalette.contrastMedium,
                            ),
                            hintText: 'Enter your email',
                            hintStyle: const TextStyle(
                              color: AppPalette.contrastMedium,
                            ),
                            filled: true,
                            fillColor: AppPalette.backgroundAccent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppPalette.musicPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: AppPalette.contrastLight,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 24),

                        // Send OTP button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLoading.value
                                    ? null
                                    : () async {
                                      if (emailController.text.isEmpty) {
                                        _showSnackBar(
                                          context,
                                          'Please enter your email',
                                        );
                                        return;
                                      }

                                      isLoading.value = true;
                                      try {
                                        privyService.loginWithEmail(
                                          emailController.text,
                                        );
                                        isEmailSent.value = true;
                                        _showSnackBar(
                                          context,
                                          'OTP sent to your email!',
                                        );
                                      } catch (e) {
                                        _showSnackBar(
                                          context,
                                          'Failed to send OTP. Please try again.',
                                        );
                                      } finally {
                                        isLoading.value = false;
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.musicPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                isLoading.value
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppPalette.contrastLight,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppPalette.contrastLight,
                                      ),
                                    ),
                          ),
                        ),
                      ] else ...[
                        // OTP input
                        Text(
                          'Enter the code sent to\n${emailController.text}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppPalette.contrastMedium,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: otpController,
                          decoration: InputDecoration(
                            labelText: 'Verification Code',
                            labelStyle: const TextStyle(
                              color: AppPalette.contrastMedium,
                            ),
                            hintText: 'Enter 6-digit code',
                            hintStyle: const TextStyle(
                              color: AppPalette.contrastMedium,
                            ),
                            filled: true,
                            fillColor: AppPalette.backgroundAccent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppPalette.musicPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: AppPalette.contrastLight,
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLoading.value
                                    ? null
                                    : () async {
                                      if (otpController.text.isEmpty) {
                                        _showSnackBar(
                                          context,
                                          'Please enter the verification code',
                                        );
                                        return;
                                      }

                                      isLoading.value = true;
                                      try {
                                        await privyService.verifyOtp(
                                          emailController.text,
                                          otpController.text,
                                          context,
                                        );
                                      } catch (e) {
                                        _showSnackBar(
                                          context,
                                          'Invalid code. Please try again.',
                                        );
                                      } finally {
                                        isLoading.value = false;
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.musicPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                isLoading.value
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppPalette.contrastLight,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Verify & Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppPalette.contrastLight,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back button
                        TextButton(
                          onPressed: () {
                            isEmailSent.value = false;
                            otpController.clear();
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(color: AppPalette.contrastMedium),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Wallet connect option
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      //await privyService.loginWithWallet(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppPalette.contrastLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppPalette.contrastLight,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Connect Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.contrastLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Terms and privacy
                const Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.contrastMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPalette.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
