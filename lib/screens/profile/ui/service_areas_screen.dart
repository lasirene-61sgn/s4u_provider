import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/api/api_client.dart';

class ServiceAreasScreen extends StatefulWidget {
  const ServiceAreasScreen({super.key});

  @override
  State<ServiceAreasScreen> createState() => _ServiceAreasScreenState();
}

class _ServiceAreasScreenState extends State<ServiceAreasScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _areas = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get(endpoint: '/service-areas/my');
      if (res['status'] == 1 && res['data'] is List) {
        setState(() {
          _areas = res['data'];
        });
      } else {
        setState(() { _error = res['message']; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteArea(int id) async {
    try {
      final res = await _api.delete(endpoint: '/service-areas/$id');
      if (res['status'] == 1) {
        _fetchAreas();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service area removed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showAddDialog() {
    final stateCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '10.0');
    bool isSaving = false;

    InputDecoration inputDeco(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 14),
        filled: true,
        fillColor: AppColors.backgroundPanel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.all(24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgLighterPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Add Service Zone', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: stateCtrl,
                  decoration: inputDeco('State (e.g. California)', Icons.map_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityCtrl,
                  decoration: inputDeco('City (e.g. Los Angeles)', Icons.location_city_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pincodeCtrl,
                  decoration: inputDeco('Pincode / ZIP Code', Icons.pin_drop_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: radiusCtrl,
                  keyboardType: TextInputType.number,
                  decoration: inputDeco('Coverage Radius (KM)', Icons.radar_outlined),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 0,
              ),
              onPressed: isSaving ? null : () async {
                if (stateCtrl.text.isEmpty || cityCtrl.text.isEmpty || pincodeCtrl.text.isEmpty) return;
                setDlgState(() => isSaving = true);
                try {
                  final res = await _api.post(
                    endpoint: '/service-areas',
                    body: {
                      'state': stateCtrl.text,
                      'city': cityCtrl.text,
                      'pincode': pincodeCtrl.text,
                      'radiusKm': double.tryParse(radiusCtrl.text) ?? 10.0,
                      'status': 'ACTIVE',
                    }
                  );
                  if (res['status'] == 1) {
                    Navigator.pop(ctx);
                    _fetchAreas();
                  }
                } catch (e) {
                  // ignore
                } finally {
                  setDlgState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('Save Zone', style: TextStyle(fontWeight: FontWeight.bold))
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Service Areas & Coverage', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Service Zones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Area'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _areas.isEmpty
                    ? const Center(child: Text('No service zones configured. Add one so customers can find you!'))
                    : ListView.builder(
                        itemCount: _areas.length,
                        itemBuilder: (context, idx) {
                          final area = _areas[idx];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.borderLight),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.bgLighterPurple,
                                child: const Icon(Icons.map_outlined, color: AppColors.primary),
                              ),
                              title: Text("${area['city']}, ${area['state']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              subtitle: Text("Pincode: ${area['pincode']} • Radius: ${area['radiusKm']} km", style: const TextStyle(color: AppColors.textMuted)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteArea(area['id']),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
