import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../riverpod/provider_commission_notifier.dart';

class ProviderCommissionScreen extends ConsumerStatefulWidget {
  const ProviderCommissionScreen({super.key});

  @override
  ConsumerState<ProviderCommissionScreen> createState() => _ProviderCommissionScreenState();
}

class _ProviderCommissionScreenState extends ConsumerState<ProviderCommissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerCommissionProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerCommissionProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            Expanded(child: Center(child: Text('Error: ${state.error}')))
          else if (state.commissions.isEmpty)
            const Expanded(child: Center(child: Text('No commissions defined.')))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.commissions.length,
                  itemBuilder: (context, index) {
                    final c = state.commissions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Type: ${c.type}'),
                        trailing: Text(
                          c.type.toLowerCase() == 'percent' ? '${c.commission}%' : '\$${c.commission}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
  }
}
