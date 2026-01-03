import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assessment/features/document/domain/models/signature_model.dart';
import 'package:assessment/features/document/domain/services/signature_service.dart';
import 'package:signature/signature.dart';

class MySignaturesScreen extends StatefulWidget {
  const MySignaturesScreen({super.key});

  @override
  State<MySignaturesScreen> createState() => _MySignaturesScreenState();
}

class _MySignaturesScreenState extends State<MySignaturesScreen> {
  List<SignatureModel> _signatures = [];

  @override
  void initState() {
    super.initState();
    _loadSignatures();
  }

  void _loadSignatures() {
    setState(() {
      _signatures = SignatureService.getSignatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Signatures'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_signatures.isEmpty)
                  _buildAddSignaturePlaceholder()
                else
                  ..._signatures.map((sig) => _buildSignatureItem(sig)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddSignatureDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add New Signature'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSignaturePlaceholder() {
    return GestureDetector(
      onTap: _showAddSignatureDialog,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid, // Note: dashed border would need a custom painter or package
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                '+ Add Signature',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureItem(SignatureModel signature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.pop(context, signature.base64Data),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Center(
                child: Image.memory(
                  base64Decode(signature.base64Data),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    SignatureService.deleteSignature(signature.id);
                    _loadSignatures();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSignatureDialog() {
    final controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Draw Signature',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: controller,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.clear(),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.isNotEmpty) {
                        final bytes = await controller.toPngBytes();
                        if (bytes != null) {
                          final base64String = base64Encode(bytes);
                          SignatureService.addSignature(base64String);
                          if (mounted) {
                            Navigator.pop(context);
                            _loadSignatures();
                          }
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
