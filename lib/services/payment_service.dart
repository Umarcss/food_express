import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';

class PaymentInitialization {
  final String accessCode;
  final String reference;

  const PaymentInitialization({
    required this.accessCode,
    required this.reference,
  });
}

class PaymentResult {
  final bool isSuccess;
  final bool wasCancelled;
  final String reference;
  final String message;

  const PaymentResult({
    required this.isSuccess,
    required this.wasCancelled,
    required this.reference,
    required this.message,
  });
}

class PaymentService {
  PaymentService({
    FirebaseFunctions? functions,
    Paystack? paystack,
    bool firebaseEnabled = true,
  })  : _functions = functions,
        _paystack = paystack ?? Paystack(),
        _firebaseEnabled = firebaseEnabled;

  static const String publicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_de45fc7fc1290a45fd0df71a2558ceddb141445b',
  );

  final FirebaseFunctions? _functions;
  final Paystack _paystack;
  final bool _firebaseEnabled;
  bool _isInitialized = false;

  FirebaseFunctions get _cloudFunctions {
    if (!_firebaseEnabled) {
      throw StateError('Firebase Functions are not configured.');
    }
    return _functions ?? FirebaseFunctions.instance;
  }

  Future<PaymentInitialization> initialize(String orderId) async {
    final callable = _cloudFunctions.httpsCallable('initializePaystackPayment');
    final response = await callable.call<Map<String, dynamic>>({
      'orderId': orderId,
    });
    final data = Map<String, dynamic>.from(response.data);
    return PaymentInitialization(
      accessCode: data['accessCode'] as String,
      reference: data['reference'] as String,
    );
  }

  Future<PaymentResult> launch(String accessCode) async {
    if (publicKey.isEmpty) {
      throw StateError(
        'Missing PAYSTACK_PUBLIC_KEY.',
      );
    }
    if (!_isInitialized) {
      _isInitialized = await _paystack.initialize(publicKey, kDebugMode);
    }
    final dynamic response = await _paystack.launch(accessCode);
    final status = (response.status as String?) ?? '';
    final reference = (response.reference as String?) ?? '';
    final message = (response.message as String?) ?? 'Payment completed';
    return PaymentResult(
      isSuccess: status.toLowerCase() == 'success',
      wasCancelled: status.toLowerCase() == 'cancelled',
      reference: reference,
      message: message,
    );
  }

  Future<bool> verify(String reference) async {
    final callable = _cloudFunctions.httpsCallable('verifyPaystackPayment');
    final response = await callable.call<Map<String, dynamic>>({
      'reference': reference,
    });
    final data = Map<String, dynamic>.from(response.data);
    return data['status'] == true || data['status'] == 'success';
  }
}
