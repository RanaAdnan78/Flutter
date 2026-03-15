import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/company_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class CompanyFormScreen extends StatefulWidget {
  final CompanyModel? company; // Null if adding new, passed if editing

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _regNoController;
  late TextEditingController _ntnController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String _selectedProvince = 'Punjab';
  final List<String> _provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Jammu & Kashmir',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.company?.businessName ?? '',
    );
    _regNoController = TextEditingController(
      text: widget.company?.registrationNo ?? '',
    );
    _ntnController = TextEditingController(text: widget.company?.ntn ?? '');
    _addressController = TextEditingController(
      text: widget.company?.address ?? '',
    );
    _phoneController = TextEditingController(text: widget.company?.phone ?? '');
    _emailController = TextEditingController(text: widget.company?.email ?? '');
    if (widget.company != null &&
        _provinces.contains(widget.company!.province)) {
      _selectedProvince = widget.company!.province;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _ntnController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final userId = auth.currentUserModel?.uid;

      if (userId == null) throw Exception('User not logged in');

      final now = DateTime.now();

      final companyData = CompanyModel(
        id:
            widget.company?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        businessName: _nameController.text.trim(),
        registrationNo: _regNoController.text.trim(),
        ntn: _ntnController.text.trim(),
        province: _selectedProvince,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        createdAt: widget.company?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.company == null) {
        await _firestore.addCompany(companyData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await _firestore.updateCompany(companyData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company == null ? 'Add Company' : 'Edit Company'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            Text(
              'Business Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Business Name *',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (v) =>
                  ValidationHelpers.validateEmpty(v, 'Business Name'),
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _regNoController,
              decoration: const InputDecoration(
                labelText: 'Registration Number *',
              ),
              validator: (v) =>
                  ValidationHelpers.validateEmpty(v, 'Registration Number'),
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _ntnController,
              decoration: const InputDecoration(
                labelText: 'NTN (National Tax Number) *',
              ),
              validator: (v) => ValidationHelpers.validateEmpty(v, 'NTN'),
            ),
            const SizedBox(height: AppConstants.paddingM),

            DropdownButtonFormField<String>(
              initialValue: _selectedProvince,
              decoration: const InputDecoration(labelText: 'Province *'),
              items: _provinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedProvince = val);
              },
            ),

            const SizedBox(height: AppConstants.paddingL),
            Text(
              'Contact Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: ValidationHelpers.validatePhone,
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: ValidationHelpers.validateEmail,
            ),
            const SizedBox(height: AppConstants.paddingM),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address *',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (v) => ValidationHelpers.validateEmpty(v, 'Address'),
            ),

            const SizedBox(height: AppConstants.paddingXL),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCompany,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: AppColors.white),
                    )
                  : Text(
                      widget.company == null
                          ? 'SAVE COMPANY'
                          : 'UPDATE COMPANY',
                    ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
          ],
        ),
      ),
    );
  }
}
