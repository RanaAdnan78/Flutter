import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../profile/profile_screen.dart';
import '../invoice/invoice_list_screen.dart';
import '../company/company_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const InvoiceListScreen(),
    const CompanyListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoices'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Companies'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context, listen: false).currentUserModel?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: userId == null 
        ? const Center(child: Text('Please login'))
        : FutureBuilder<List<InvoiceModel>>(
            // FutureBuilder to get all invoices - For MVP, aggregating over all companies.
            // A more complex app would use Cloud Functions for aggregations.
            future: _getAllInvoices(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allInvoices = snapshot.data ?? [];
              final totalRevenue = allInvoices.fold(0.0, (sum, inv) => sum + inv.total);
              final invoiceCount = allInvoices.length;
              
              // Top 5 recent
              final recentInvoices = allInvoices.toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final displayRecent = recentInvoices.take(5).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Revenue', FormatHelpers.formatCurrency(totalRevenue), Icons.account_balance_wallet, AppColors.success)),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(child: _buildStatCard('Total Invoices', '$invoiceCount', Icons.receipt, AppColors.primary)),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.paddingL),
                    Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    if (displayRecent.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('No recent activity. Start by adding a company and an invoice!'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayRecent.length,
                        itemBuilder: (context, index) {
                          final inv = displayRecent[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.receipt, color: AppColors.white)),
                              title: Text('Invoice #${inv.invoiceNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(inv.buyerBusinessName),
                              trailing: Text(FormatHelpers.formatCurrency(inv.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: AppConstants.paddingS),
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<List<InvoiceModel>> _getAllInvoices(String userId) async {
    try {
      // First get all companies
      final companiesStream = _firestore.getCompaniesStream(userId);
      final companies = await companiesStream.first;
      
      List<InvoiceModel> allInvoices = [];
      
      // Get invoices for each company
      for (var company in companies) {
        final invoicesStream = _firestore.getInvoicesStream(userId, company.id);
        final invoices = await invoicesStream.first;
        allInvoices.addAll(invoices);
      }
      return allInvoices;
    // ignore: empty_catches
    } catch (e) {
      // Firebase probably not initialized properly yet, return empty
    }
    return [];
  }
}
