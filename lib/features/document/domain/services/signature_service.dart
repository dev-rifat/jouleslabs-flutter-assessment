import 'package:assessment/features/document/domain/models/signature_model.dart';
import 'package:uuid/uuid.dart';

class SignatureService {
  // Simple in-memory storage for this example. 
  // In a real app, this would use SharedPreferences or a database.
  static final List<SignatureModel> _signatures = [];

  static List<SignatureModel> getSignatures() => List.unmodifiable(_signatures);

  static void addSignature(String base64Data) {
    final newSignature = SignatureModel(
      id: const Uuid().v4(),
      base64Data: base64Data,
      createdAt: DateTime.now(),
    );
    _signatures.add(newSignature);
  }

  static void deleteSignature(String id) {
    _signatures.removeWhere((s) => s.id == id);
  }
}
