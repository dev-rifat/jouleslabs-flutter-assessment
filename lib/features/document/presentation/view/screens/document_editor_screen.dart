import '../../bloc/document_editor_bloc.dart';
import '../widgets/ducument_view.dart';
import '/features/document/document_exports.dart';

/// SCREEN FOR DOCUMENT EDITOR
class DocumentEditorScreen extends StatelessWidget {
  final File? initialFile;
  const DocumentEditorScreen({super.key, this.initialFile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = DocumentEditorBloc();
        if (initialFile != null) {
          bloc.add(LoadInitialPdfEvent(initialFile!));
        }
        return bloc;
      },
      child: const DocumentEditorView(),
    );
  }
}
