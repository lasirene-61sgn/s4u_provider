import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/api/api_client.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _slots = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get(endpoint: '/provider-availability/my');
      if (res['status'] == 1 && res['data'] is List) {
        setState(() {
          _slots = res['data'];
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

  Future<void> _deleteSlot(int id) async {
    try {
      final res = await _api.delete(endpoint: '/provider-availability/$id');
      if (res['status'] == 1) {
        _fetchSlots();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Availability slot removed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showAddDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
    final capacityCtrl = TextEditingController(text: '3');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Add Capacity Slot', style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date
              ListTile(
                title: const Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text("${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setDlgState(() => selectedDate = picked);
                  }
                },
              ),
              const Divider(),
              // Start Time
              ListTile(
                title: const Text('Start Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(startTime.format(context), style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: startTime);
                  if (picked != null) {
                    setDlgState(() => startTime = picked);
                  }
                },
              ),
              const Divider(),
              // End Time
              ListTile(
                title: const Text('End Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(endTime.format(context), style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: endTime);
                  if (picked != null) {
                    setDlgState(() => endTime = picked);
                  }
                },
              ),
              const Divider(),
              TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Simultaneous Capacity (e.g. max bookings)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: isSaving ? null : () async {
                setDlgState(() => isSaving = true);
                try {
                  final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                  final startStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00";
                  final endStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00";
                  final res = await _api.post(
                    endpoint: '/provider-availability',
                    body: {
                      'date': dateStr,
                      'startTime': startStr,
                      'endTime': endStr,
                      'capacity': int.tryParse(capacityCtrl.text) ?? 1,
                      'bookedSlots': 0,
                    }
                  );
                  if (res['status'] == 1) {
                    Navigator.pop(ctx);
                    _fetchSlots();
                  }
                } catch (e) {
                  // ignore
                } finally {
                  setDlgState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('Add Slot')
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
        title: const Text('Availability Planner', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                const Text('Capacity Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Schedule Slot'),
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
                  : _slots.isEmpty
                    ? const Center(child: Text('No availability configured. Schedule slots so customers can select bookable dates!'))
                    : ListView.builder(
                        itemCount: _slots.length,
                        itemBuilder: (context, idx) {
                          final slot = _slots[idx];
                          final booked = slot['bookedSlots'] ?? 0;
                          final cap = slot['capacity'] ?? 1;
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
                                child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                              ),
                              title: Text(slot['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              subtitle: Text("Hours: ${slot['startTime']} - ${slot['endTime']} • Bookings: $booked / $cap capacity", style: const TextStyle(color: AppColors.textMuted)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteSlot(slot['id']),
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
