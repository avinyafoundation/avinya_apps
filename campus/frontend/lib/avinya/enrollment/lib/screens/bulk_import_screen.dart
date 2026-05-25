import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../data/import_student_row.dart';
import '../services/bulk_import_processor.dart';
import '../services/excel_parser_service.dart';
import '../services/lookup_resolver_service.dart';
import '../widgets/import_preview_table.dart';

enum _ImportStage { upload, resolving, preview, importing, done }

//Bulk import screen with multiple stages: upload, resolving, preview, importing, done

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({Key? key}) : super(key: key);

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen>
    with SingleTickerProviderStateMixin {
  _ImportStage _stage = _ImportStage.upload;

  final LookupResolverService _resolver = LookupResolverService();
  final BulkImportProcessor _processor = BulkImportProcessor();

  List<ImportStudentRow> _rows = [];
  List<ImportRowResult> _importResults = [];

  int _progressCurrent = 0;
  int _progressTotal = 0;
  String _progressMessage = '';

  late TabController _tabController;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── File picking ────────────────────────────────────────────────────────

   static const String _templateGoogleDriveFileId = '1feZnBOAcJyQFoe1R9TcmfCYeYafxF2aB';

  void _downloadTemplate() {
    final downloadUrl =
        'https://drive.google.com/uc?export=download&id=$_templateGoogleDriveFileId';

    // Opens the Google Drive direct download URL in a new browser tab.
    // The browser will immediately prompt the user to save the file.
    html.AnchorElement(href: downloadUrl)
      ..setAttribute('download', 'student_import_template.xlsx')
      ..setAttribute('target', '_blank')
      ..click();
  }

  Future<void> _pickFile() async {
    setState(() => _parseError = null);

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
        allowMultiple: false,
      );
    } catch (e) {
      setState(() => _parseError = 'File picker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    print('[BulkImport] Picked: ${file.name}, size: ${file.size} bytes');

    final Uint8List? bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      setState(() => _parseError = 'Could not read file bytes. Try again.');
      return;
    }

    if (bytes.length < 4 ||
        bytes[0] != 80 ||
        bytes[1] != 75 ||
        bytes[2] != 3 ||
        bytes[3] != 4) {
      setState(() => _parseError = 'File is not a valid .xlsx file.\n'
          'Please resave as Excel Workbook (.xlsx) and try again.');
      return;
    }

    print('[BulkImport] Valid xlsx. Parsing ${bytes.length} bytes...');
    await _parseAndResolve(bytes);
  }

  Future<void> _parseAndResolve(Uint8List bytes) async {
    List<ImportStudentRow> parsed;
    try {
      parsed = ExcelParserService.parse(bytes);
    } on FormatException catch (e) {
      setState(() => _parseError = e.message);
      return;
    } catch (e) {
      setState(() => _parseError = 'Parse error: $e');
      return;
    }

    setState(() {
      _stage = _ImportStage.resolving;
      _progressCurrent = 0;
      _progressTotal = parsed.length;
      _progressMessage = 'Loading reference data...';
    });

    await _resolver.initialize();

    setState(() => _progressMessage = 'Resolving row data...');
    await _resolver.resolveAll(parsed, onProgress: (current, total) {
      if (mounted) {
        setState(() {
          _progressCurrent = current;
          _progressTotal = total;
          _progressMessage = 'Resolving row $current of $total...';
        });
      }
    });

    setState(() {
      _rows = parsed;
      _stage = _ImportStage.preview;
    });
  }

  // ── Import ──────────────────────────────────────────────────────────────

  Future<void> _startImport() async {
    final readyCount = _rows.where((r) => r.isReady).length;
    if (readyCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No ready rows to import. Fix errors first.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Import'),
        content: Text('Import $readyCount ready student(s)?\n'
            '${_rows.length - readyCount} row(s) with errors will be skipped.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _stage = _ImportStage.importing;
      _progressCurrent = 0;
      _progressTotal = readyCount;
      _progressMessage = 'Starting import...';
    });

    final results = await _processor.process(
      context,
      _rows,
      onProgress: (current, total, lastResult) {
        if (mounted) {
          setState(() {
            _progressCurrent = current;
            _progressTotal = total;
            _progressMessage =
                '[$current/$total] ${lastResult.name ?? lastResult.nic} — ${lastResult.status}';
          });
        }
      },
    );

    setState(() {
      _importResults = results;
      _stage = _ImportStage.done;
    });
  }

  // ── Counts ──────────────────────────────────────────────────────────────

  int get _readyCount => _rows.where((r) => r.isReady).length;
  int get _errorCount => _rows.where((r) => r.status == RowStatus.error).length;
  int get _reviewCount =>
      _rows.where((r) => r.status == RowStatus.needsReview).length;
  int get _successCount =>
      _importResults.where((r) => r.status == 'success').length;
  int get _skippedCount =>
      _importResults.where((r) => r.status == 'skipped').length;
  int get _failedCount =>
      _importResults.where((r) => r.status == 'failed').length;

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Bulk Student Import'),
      //   backgroundColor: Colors.lightBlueAccent,
      //   foregroundColor: Colors.white,
      //   // Actions moved OUT of AppBar to avoid overflow
      //   // They are rendered inside each stage's body instead
      // ),
      body: Column(
        children: [
          // ── Toolbar row below AppBar ─────────────────────────────────
          if (_stage == _ImportStage.preview) _buildPreviewToolbar(),
          // ── Main content ─────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // Separate toolbar row — no overflow possible since it scrolls
  Widget _buildPreviewToolbar() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Status chips
          _chip('✅ $_readyCount Ready', Colors.green),
          const SizedBox(width: 8),
          _chip('🟡 $_reviewCount Review', Colors.orange),
          const SizedBox(width: 8),
          _chip('🔴 $_errorCount Error', Colors.red),
          const Spacer(),
          // Re-upload button
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file, size: 16),
            label: const Text('Re-upload'),
          ),
          const SizedBox(width: 8),
          // Import button
          ElevatedButton.icon(
            onPressed: _readyCount > 0 ? _startImport : null,
            icon: const Icon(Icons.cloud_upload, size: 16),
            label: Text('Import $_readyCount Rows'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _ImportStage.upload:
        return _buildUploadStage();
      case _ImportStage.resolving:
        return _buildLoadingStage('Preparing data...');
      case _ImportStage.preview:
        return _buildPreviewStage();
      case _ImportStage.importing:
        return _buildLoadingStage('Importing students...');
      case _ImportStage.done:
        return _buildDoneStage();
    }
  }

  // ── Upload stage ────────────────────────────────────────────────────────

  Widget _buildUploadStage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 80, color: Colors.lightBlueAccent.shade100),
            const SizedBox(height: 24),
            const Text('Upload Student Excel File',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Upload an .xlsx file using the provided template.\n'
              'Rows with errors can be fixed in the preview before importing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Choose Excel File (.xlsx)'),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download),
              label: const Text('Download Template'),
            ),
            if (_parseError != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _parseError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Loading stage ───────────────────────────────────────────────────────

  Widget _buildLoadingStage(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(color: Colors.lightBlueAccent, size: 60),
            const SizedBox(height: 24),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_progressTotal > 0) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: LinearProgressIndicator(
                  value: _progressCurrent / _progressTotal,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation(Colors.lightBlueAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(_progressMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Preview stage ───────────────────────────────────────────────────────

  Widget _buildPreviewStage() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ImportPreviewTable(
        rows: _rows,
        resolver: _resolver,
        onRowChanged: () => setState(() {}),
      ),
    );
  }

  // ── Done stage ──────────────────────────────────────────────────────────

  Widget _buildDoneStage() {
    return Column(
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                  child:
                      _summaryTile('✅ Imported', _successCount, Colors.green)),
              Expanded(
                  child:
                      _summaryTile('⚠️ Skipped', _skippedCount, Colors.orange)),
              Expanded(
                  child: _summaryTile('❌ Failed', _failedCount, Colors.red)),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          tabs: [
            Tab(text: '✅ Imported ($_successCount)'),
            Tab(text: '⚠️ Skipped ($_skippedCount)'),
            Tab(text: '❌ Failed ($_failedCount)'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildResultList('success', Colors.green.shade50),
              _buildResultList('skipped', Colors.orange.shade50),
              _buildResultList('failed', Colors.red.shade50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultList(String status, Color rowColor) {
    final filtered = _importResults.where((r) => r.status == status).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No records in this category.'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final r = filtered[index];
        return Container(
          color: index.isEven ? rowColor : Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Text('${r.rowIndex}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            title: Text(r.name ?? r.nic ?? 'Row ${r.rowIndex}'),
            subtitle: r.message != null
                ? Text(r.message!,
                    style: TextStyle(color: Colors.red.shade400, fontSize: 12))
                : null,
            trailing: Text(r.nic ?? '',
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12, color: Colors.grey)),
          ),
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _summaryTile(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
