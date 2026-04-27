import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
import '../../network/api_models/get_all_docs_response_model.dart';
import '../../network/api_models/uploaded_file_model.dart';
import '../../core/helpers/file_downloader.dart';
import 'package:greengears/main.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class UploadedQuotations extends StatefulWidget {
  /// The request ID whose documents should be fetched.
  final String requestId;

  /// When true, wraps content in a Scaffold with AppBar (standalone page).
  /// When false, renders content only — safe to embed inside modals/columns.
  final bool asPage;

  const UploadedQuotations({
    Key? key,
    required this.requestId,
    this.asPage = true,
  }) : super(key: key);

  @override
  State<UploadedQuotations> createState() => _UploadedQuotationsState();
}

class _UploadedQuotationsState extends State<UploadedQuotations> {
  final ApiClient _client = globalApiClient;

  bool _isLoading = true;
  String? _errorMessage;
  List<UploadedFileModel> _docs = [];

  // Tracks which docId groups are currently expanded
  final Set<int> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _client.getAllUploadedDocsFromS3(
        requestId: widget.requestId,
      );
      setState(() {
        _docs = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents. Please try again.';
        _isLoading = false;
      });
      debugPrint('Error loading docs: $e');
    }
  }

  // ---- build ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Standalone page — keep original Scaffold + AppBar
    if (widget.asPage) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Uploaded Documents',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Request ID header ─────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFFEFEFEF),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: Color(0xF5323232), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Your Active Request: ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.requestId,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xF50483DE),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8F5E9)),

            // ── Body ─────────────────────────────────────────────────
            Expanded(child: _buildBody(shrinkWrap: false)),
          ],
        ),
      );
    }

    // Embedded mode — no Scaffold, no AppBar, renders inline
    return _buildBody(shrinkWrap: true);
  }

  /// [shrinkWrap] — pass true when embedded inside a scroll view (modal).
  Widget _buildBody({required bool shrinkWrap}) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF42B347)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadDocs,
                icon: const Icon(Icons.refresh, color: Color(0xFF42B347)),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF42B347),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_outlined,
                  color: Colors.grey[400], size: 64),
              const SizedBox(height: 12),
              Text(
                'No documents found for your request',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group docs by docId so same-type docs are listed together
    final Map<int, List<UploadedFileModel>> grouped = {};
    for (final doc in _docs) {
      grouped.putIfAbsent(doc.docId, () => []).add(doc);
    }

    // Sort groups by docId ascending
    final sortedDocIds = grouped.keys.toList()..sort();

    return ListView.builder(
      // shrinkWrap=true + NeverScrollableScrollPhysics when embedded in a
      // parent scroll view (e.g. modal's SingleChildScrollView).
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: shrinkWrap
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 12),
      itemCount: sortedDocIds.length,
      itemBuilder: (context, groupIndex) {
        final docId = sortedDocIds[groupIndex];
        final files = grouped[docId]!;
        final docEnum = Document.fromDocId(docId);
        final docLabel = docEnum?.docLabel ?? 'Document (ID: $docId)';

        return _buildDocGroup(docLabel, docId, files);
      },
    );
  }

  Widget _buildDocGroup(
      String label, int docId, List<UploadedFileModel> files) {
    final isExpanded = _expandedGroups.contains(docId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group header — tappable expander ──────────────────────
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedGroups.remove(docId);
                } else {
                  _expandedGroups.add(docId);
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0xFF505050),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF98EAFC),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${files.length} file${files.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF428BB3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Files — only rendered when expanded ───────────────────
          if (isExpanded) ...files.map((file) => _buildDocTile(file)),

          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  Widget _buildDocTile(UploadedFileModel file) {
    final displayName = FileDownloader.displayFileName(file.fileName);
    final iconLabel = FileDownloader.fileIcon(file.fileName);
    final iconColor = FileDownloader.fileColor(file.fileName);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // File type badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                iconLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filename — single line with ellipsis
          Expanded(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9A9A9A),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Download button
          GestureDetector(
            onTap: () => FileDownloader.downloadAndOpenFile(
              context: context,
              presignedUrl: file.downloadUrl,
              rawFileName: file.fileName,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFDCDCDC), width: 1),
              ),
              child: const Icon(
                Icons.download,
                color: Color(0xFF9A9A9A),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}