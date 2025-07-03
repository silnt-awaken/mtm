import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mtm/routing/router.dart';

class PrivyService {
  static final PrivyService _instance = PrivyService._internal();
  factory PrivyService() => _instance;

  PrivyService._internal();

  Privy? _privyInternal;
  bool _isInitialized = false;

  Privy get privy {
    if (!_isInitialized || _privyInternal == null) {
      throw Exception('PrivyService not initialized. Call initialize() first.');
    }
    return _privyInternal!;
  }

  Future<PrivyUser?> initialize({TokenProvider? tokenProvider}) async {
    if (_isInitialized && _privyInternal != null) return _privyInternal!.user;

    final privyConfig = PrivyConfig(
      appId: dotenv.env['PRIVY_APP_ID'] ?? '',
      appClientId: dotenv.env['PRIVY_CLIENT_ID'] ?? '',
      logLevel: PrivyLogLevel.verbose,
      customAuthConfig:
          tokenProvider != null
              ? LoginWithCustomAuthConfig(tokenProvider: tokenProvider)
              : null,
    );

    _privyInternal = Privy.init(config: privyConfig);
    await _privyInternal!.awaitReady();
    _isInitialized = true;
    return _privyInternal!.user;
  }

  bool isAuthenticated() {
    if (!_isInitialized || _privyInternal == null) return false;
    return privy.currentAuthState.isAuthenticated;
  }

  PrivyUser? get currentUser {
    if (!isAuthenticated()) return null;
    return privy.user;
  }

  String? get walletAddress {
    if (!isAuthenticated()) return null;
    final wallets = privy.user?.embeddedSolanaWallets.firstOrNull?.address;

    return wallets;
  }

  void loginWithEmail(String email) async {
    await initialize();

    final Result<void> result = await privy.email.sendCode(email);
    result.fold(
      onSuccess: (_) => debugPrint('OTP sent successfully to $email'),
      onFailure: (error) => debugPrint('Error sending OTP: ${error.message}'),
    );
  }

  Future<void> verifyOtp(String email, String otp, BuildContext context) async {
    await initialize();

    final Result<PrivyUser> result = await privy.email.loginWithCode(
      code: otp,
      email: email,
    );

    result.fold(
      onSuccess: (user) {
        debugPrint('User authenticated successfully: ${user.id}');
        if (context.mounted) context.go(home);
      },
      onFailure: (error) {
        debugPrint('Authentication error: ${error.message}');
      },
    );
  }

  // Future<void> loginWithWallet(BuildContext context) async {
  //   await initialize();

  //   final Result<PrivyUser> result = await privy.
  //   result.fold(
  //     onSuccess: (user) {
  //       debugPrint('Wallet connected successfully: ${user.id}');
  //       if (context.mounted) context.go(home);
  //     },
  //     onFailure: (error) {
  //       debugPrint('Wallet connection error: ${error.message}');
  //     },
  //   );
  // }

  // Future<String?> signMessage(String message) async {
  //   if (!isAuthenticated()) return null;

  //   try {
  //     final Result<String> result = await privy.signMessage(message);
  //     return result.fold(
  //       onSuccess: (signature) => signature,
  //       onFailure: (error) {
  //         debugPrint('Error signing message: ${error.message}');
  //         return;
  //       },
  //     );
  //   } catch (e) {
  //     debugPrint('Error signing message: $e');
  //     return null;
  //   }
  // }

  // Future<String?> signTransaction(String transaction) async {
  //   if (!isAuthenticated()) return null;

  //   try {
  //     final Result<String> result = await privy.signTransaction(transaction);
  //     return result.fold(
  //       onSuccess: (signature) => signature,
  //       onFailure: (error) {
  //         debugPrint('Error signing transaction: ${error.message}');
  //         return;
  //       },
  //     );
  //   } catch (e) {
  //     debugPrint('Error signing transaction: $e');
  //     return null;
  //   }
  // }

  // Future<bool> createWallet() async {
  //   if (!isAuthenticated()) return false;

  //   try {
  //     final Result<void> result = await privy.createWallet();
  //     return result.fold(
  //       onSuccess: (_) {
  //         debugPrint('Wallet created successfully');
  //         return true;
  //       },
  //       onFailure: (error) {
  //         debugPrint('Error creating wallet: ${error.message}');
  //         return false;
  //       },
  //     );
  //   } catch (e) {
  //     debugPrint('Error creating wallet: $e');
  //     return false;
  //   }
  // }

  Future<bool> logout(BuildContext context) async {
    try {
      if (_isInitialized && _privyInternal != null) {
        await _privyInternal!.logout();
      }

      _isInitialized = false;
      _privyInternal = null;

      if (context.mounted) {
        context.go(login);
      }

      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  // // Get wallet info for UI display
  // Map<String, dynamic>? get walletInfo {
  //   if (!isAuthenticated()) return null;

  //   final wallets =
  //       privy.user?.linkedAccounts
  //           .where((account) => account.type == 'wallet')
  //           .toList();

  //   if (wallets?.isEmpty ?? true) return null;

  //   final wallet = wallets!.first;
  //   return {
  //     'address': wallet.address,
  //     'type': wallet.walletClient,
  //     'chainId': wallet.chainId,
  //   };
  // }

  // Check if user has a wallet connected
  bool get hasWallet {
    if (!isAuthenticated()) return false;
    return walletAddress != null;
  }

  // // Get user's email if authenticated via email
  // String? get userEmail {
  //   if (!isAuthenticated()) return null;
  //   final emails =
  //       privy.user?.linkedAccounts
  //           .where((account) => account.type == 'email')
  //           .toList();
  //   if (emails?.isEmpty ?? true) return null;
  //   return emails!.first.type;
  // }
}
