import 'package:flutter/widgets.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository = PaymentRepository();

  final bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;

  Future<Map<String, dynamic>> paymentGateway({
    required String adminCode, 
    required String email
  }) async {
    _isInitializing = true;
    notifyListeners();

    try {
      final result = await _paymentRepository.initializePayment(adminCode: adminCode, email: email);
      return result.fold((l) => throw l, (r) => r);
    } catch (error) {
      rethrow;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }
}
