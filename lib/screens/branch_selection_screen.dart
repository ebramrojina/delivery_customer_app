import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/branch.dart';
import '../providers/cart_provider.dart';
import '../services/menu_repository.dart';
import 'branch_menu_screen.dart';

class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  late Future<List<Branch>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = MenuRepository.loadBranches();
  }

  void _selectBranch(Branch branch) {
    context.read<CartProvider>().selectBranch(branch);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BranchMenuScreen(branch: branch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(s.chooseBranch)),
      body: SafeArea(
        child: FutureBuilder<List<Branch>>(
          future: _branchesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final branches = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    s.selectBranchPrompt,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: branches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(child: Icon(Icons.storefront)),
                          title: Text(
                            branch.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(branch.locationFor(isArabic)),
                          trailing: Icon(isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios, size: 16),
                          onTap: () => _selectBranch(branch),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
