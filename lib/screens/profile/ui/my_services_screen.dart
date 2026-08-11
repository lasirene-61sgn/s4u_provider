import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/api/api_client.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _myServices = [];
  List<dynamic> _platformServices = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res1 = await _api.get(endpoint: '/provider-services/my');
      final res2 = await _api.get(endpoint: '/services');
      if (res1['status'] == 1 && res2['status'] == 1) {
        setState(() {
          _myServices = res1['data'] ?? [];
          _platformServices = res2['data'] ?? [];
        });
      } else {
        setState(() { _error = 'Failed to fetch data'; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteServiceMapping(int id) async {
    try {
      final res = await _api.delete(endpoint: '/provider-services/$id');
      if (res['status'] == 1) {
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service pricing mapping removed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showAddDialog() {
    int? selectedServiceId;
    final priceCtrl = TextEditingController();
    final discCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '2 hours');
    bool isSaving = false;

    // Filter services that aren't already mapped
    final mappedIds = _myServices.map((e) => e['service']?['id'] as int?).toSet();
    final availableServices = _platformServices.where((e) => !mappedIds.contains(e['id'] as int?)).toList();

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
                child: const Icon(Icons.add_task_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Add Service Pricing', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (availableServices.isEmpty)
                  const Text('All platform services are already mapped to your pricing.')
                else ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedServiceId,
                    hint: const Text('Select Platform Service'),
                    decoration: inputDeco('Select Service', Icons.handyman_outlined),
                    items: availableServices.map((s) {
                      return DropdownMenuItem<int>(
                        value: s['id'],
                        child: Text(s['serviceName'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDlgState(() => selectedServiceId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: inputDeco('Standard Price (\$)', Icons.attach_money_rounded),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: discCtrl,
                    keyboardType: TextInputType.number,
                    decoration: inputDeco('Discounted Price (\$)', Icons.discount_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durCtrl,
                    decoration: inputDeco('Duration (e.g. 2 hours)', Icons.schedule_rounded),
                  ),
                  const SizedBox(height: 8),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ),
            if (availableServices.isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 0,
                ),
                onPressed: (isSaving || selectedServiceId == null) ? null : () async {
                  if (priceCtrl.text.isEmpty) return;
                  setDlgState(() => isSaving = true);
                  try {
                    final res = await _api.post(
                      endpoint: '/provider-services',
                      body: {
                        'serviceId': selectedServiceId,
                        'price': double.tryParse(priceCtrl.text) ?? 0.0,
                        'discountPrice': double.tryParse(discCtrl.text) ?? 0.0,
                        'duration': durCtrl.text,
                        'status': 'ACTIVE',
                      }
                    );
                    if (res['status'] == 1) {
                      Navigator.pop(ctx);
                      _fetchData();
                    }
                  } catch (e) {
                    // ignore
                  } finally {
                    setDlgState(() => isSaving = false);
                  }
                },
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold))
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
        title: const Text('Services & Pricing', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                const Text('Offered Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service'),
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
                  : _myServices.isEmpty
                    ? const Center(child: Text('No custom pricing configured. Configure some services to start receiving bookings!'))
                    : ListView.builder(
                        itemCount: _myServices.length,
                        itemBuilder: (context, idx) {
                          final mapped = _myServices[idx];
                          final srv = mapped['service'];
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
                                child: const Icon(Icons.handyman_outlined, color: AppColors.primary),
                              ),
                              title: Text(srv?['serviceName'] ?? 'Custom Service', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              subtitle: Text("Price: \$${mapped['price']} • Discounted: \$${mapped['discountPrice']} • Duration: ${mapped['duration']}", style: const TextStyle(color: AppColors.textMuted)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteServiceMapping(mapped['id']),
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
