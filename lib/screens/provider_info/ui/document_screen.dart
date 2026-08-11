import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/image_viewer.dart';
import '../model/document_model.dart';
import '../riverpod/document_notifier.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final dynamic profile;

  const DocumentScreen({super.key, this.profile});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  bool _showAddDocumentForm = false;
  String? _selectedDocumentType;
  String _documentPath = '';
  String? _existingDocumentUrl;
  int? _editingDocumentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentProvider.notifier).fetchDocuments();
      ref.read(documentProvider.notifier).fetchDocumentTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentProvider);
    return _showAddDocumentForm ? _buildAddDocumentForm(documentState) : _buildDocumentList(widget.profile, documentState);
  }

  Widget _buildDocumentList(dynamic profile, DocumentState documentState) {
    final documents = documentState.documents;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  // Toolbar row
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: isMobile ? [
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _selectedDocumentType = null;
                                      _documentPath = '';
                                      _existingDocumentUrl = null;
                                      _editingDocumentId = null;
                                      setState(() => _showAddDocumentForm = true);
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Document'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ),
                      ] : [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _selectedDocumentType = null;
                                _documentPath = '';
                                _existingDocumentUrl = null;
                                _editingDocumentId = null;
                                setState(() => _showAddDocumentForm = true);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Table header
                  if (!isMobile) Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(children: [
                      Expanded(child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text('Document Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      SizedBox(width: 90, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ]),
                  ),

                  // Table body
                  Expanded(child: Builder(builder: (context) {
                    if (documentState.isLoading && documents.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (documentState.error != null && documents.isEmpty) {
                      return Center(child: Text('Error: ${documentState.error}', style: const TextStyle(color: Colors.red)));
                    }
                    if (documents.isEmpty) {
                      return const Center(child: Text('No documents added yet.', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.separated(
                      itemCount: documents.length,
                      separatorBuilder: (_, __) => isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final item = documents[index];
                        return _buildRow(item, profile, isMobile);
                      },
                    );
                  })),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
            ref.read(documentProvider.notifier).deleteDocument(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editDocument(DocumentModel doc) {
    _selectedDocumentType = doc.documentName;
    _documentPath = ''; 
    _existingDocumentUrl = doc.providerDocument;
    _editingDocumentId = doc.id;
    setState(() => _showAddDocumentForm = true);
  }

  Widget _buildRow(DocumentModel doc, dynamic profile, bool isMobile) {
    final isVerified = doc.isVerified == 1;

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (profile?.profileImage != null) {
                            ImageViewer.show(context, NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!));
                          }
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profile?.profileImage != null ? NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!) : null,
                          child: profile?.profileImage == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                            Text(profile?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isVerified ? 'Verified' : 'Unverified', style: TextStyle(color: isVerified ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Document Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (doc.providerDocument.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      ImageViewer.show(context, NetworkImage(doc.providerDocument.startsWith('http') ? doc.providerDocument : ApiClient.baseUrl.replaceAll('/api', '') + doc.providerDocument));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        doc.providerDocument.startsWith('http') ? doc.providerDocument : ApiClient.baseUrl.replaceAll('/api', '') + doc.providerDocument,
                        width: 40, height: 40, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(doc.documentName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500))),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _editDocument(doc),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(doc),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (profile?.profileImage != null) {
                    ImageViewer.show(context, NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!));
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile?.profileImage != null ? NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!) : null,
                  child: profile?.profileImage == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text(profile?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 2, child: Row(
          children: [
            if (doc.providerDocument.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  ImageViewer.show(context, NetworkImage(doc.providerDocument.startsWith('http') ? doc.providerDocument : ApiClient.baseUrl.replaceAll('/api', '') + doc.providerDocument));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    doc.providerDocument.startsWith('http') ? doc.providerDocument : ApiClient.baseUrl.replaceAll('/api', '') + doc.providerDocument,
                    width: 32, height: 32, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 32, height: 32, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(doc.documentName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ],
        )),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVerified ? 'Verified' : 'Unverified',
              style: TextStyle(color: isVerified ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Row(children: [
            Tooltip(
              message: 'Edit',
              child: InkWell(
                onTap: () => _editDocument(doc),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Delete',
              child: InkWell(
                onTap: () => _showDeleteDialog(doc),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAddDocumentForm(DocumentState documentState) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final List<String> docTypes = documentState.documentTypes
        .map((e) => e.name)
        .where((e) => e.isNotEmpty)
        .toList();

    Widget documentDropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Document *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF8F9FA),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDocumentType,
              hint: const Text('Select Document'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: docTypes.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedDocumentType = newValue);
              },
            ),
          ),
        ),
      ],
    );

    Widget browseField = _browseField('Upload Document *', path: _documentPath, existingUrl: _existingDocumentUrl, onTap: () async {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() => _documentPath = pickedFile.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() => _documentPath = pickedFile.path);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_editingDocumentId != null ? 'Edit Document' : 'Add New Document', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAddDocumentForm = false),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            documentDropdown,
                            const SizedBox(height: 24),
                            browseField,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: documentDropdown),
                            const SizedBox(width: 16),
                            Expanded(child: browseField),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_selectedDocumentType == null) {
                          Fluttertoast.showToast(msg: 'Please select a document type', backgroundColor: Colors.red, textColor: Colors.white);
                          return;
                        }
                        final selectedDoc = documentState.documentTypes.firstWhere(
                          (e) => e.name == _selectedDocumentType,
                          orElse: () => DocumentTypeModel(id: 0, name: '', status: 0, isRequired: 0),
                        );
                        final documentId = selectedDoc.id.toString();

                        final fields = {
                          'document_id': documentId,
                        };
                        if (widget.profile != null) {
                          fields['provider_id'] = widget.profile!.id.toString();
                        }
                        if (_editingDocumentId != null) {
                          fields['id'] = _editingDocumentId.toString();
                        }
                        final files = {
                          'provider_document': _documentPath.isEmpty ? null : _documentPath,
                        };

                        try {
                          await ref.read(documentProvider.notifier).addDocument(fields: fields, files: files);
                          setState(() {
                            _showAddDocumentForm = false;
                            _selectedDocumentType = null;
                            _documentPath = '';
                          });
                        } catch (e) {
                          // Error handled in notifier
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _browseField(String label, {String? path, String? existingUrl, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: [
              if (label.contains('*')) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(
                      (path != null && path.isNotEmpty) 
                          ? path.split('/').last 
                          : ((existingUrl != null && existingUrl.isNotEmpty) ? 'Existing Document Loaded' : 'Choose Attachments'),
                      style: TextStyle(
                        fontSize: 13, 
                        color: (path != null && path.isNotEmpty) || (existingUrl != null && existingUrl.isNotEmpty) ? AppColors.textSecondary : AppColors.textMuted,
                      )
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.borderLight)),
                    color: Color(0xFFF8F9FA),
                  ),
                  child: const Text('Browse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
        if (existingUrl != null && existingUrl.isNotEmpty && (path == null || path.isEmpty)) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              ImageViewer.show(context, NetworkImage(existingUrl.startsWith('http') ? existingUrl : ApiClient.baseUrl.replaceAll('/api', '') + existingUrl));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                existingUrl.startsWith('http') ? existingUrl : ApiClient.baseUrl.replaceAll('/api', '') + existingUrl,
                height: 100, width: 100, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 100, width: 100, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 30)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
