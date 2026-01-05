// import 'package:assessment/core/utils/app_color.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:assessment/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:assessment/features/document/presentation/screens/document_editor_screen.dart';
// import 'dart:io';
//
// import '../../../document/presentation/screens/documets/ducument_editors.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   Future<void> _pickDocument(BuildContext context) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'docx'],
//     );
//
//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       if (context.mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PdfSignApp(e),
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColor.backgroundColor,
//
//         title: const Text('My Documents'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => context.read<AuthBloc>().add(LoggedOut()),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.description, size: 80, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'No documents yet',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//
//             ElevatedButton.icon(
//               onPressed: () => _pickDocument(context),
//
//               icon: const Icon(Icons.add, color: AppColor.normalTextColor),
//               label: Text(
//                 'Add Document',
//                 style: TextStyle(color: AppColor.normalTextColor),
//               ),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(200, 50),
//                 backgroundColor: AppColor.backgroundColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
