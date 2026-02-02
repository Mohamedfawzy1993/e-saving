import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({Key? key}) : super(key: key);

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _contributionController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await groupProvider.joinGroup(
      _inviteCodeController.text.trim().toUpperCase(),
      authProvider.currentUser!.id,
      double.parse(_contributionController.text),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the group!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        // Refresh dashboard
        await groupProvider.loadUserGroups(authProvider.currentUser!.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(groupProvider.error ?? 'Failed to join group'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Group'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return const LoadingWidget(message: 'Joining group...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_add,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Join a Saving Group',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the invite code shared by the group admin to join an existing saving group.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _inviteCodeController,
                    label: 'Invite Code',
                    hint: 'Enter 6-character invite code',
                    prefixIcon: Icons.vpn_key,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invite code is required';
                      }
                      if (value.length != 6) {
                        return 'Invite code must be 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Auto-uppercase the invite code
                      final upperValue = value.toUpperCase();
                      if (upperValue != value) {
                        _inviteCodeController.value = _inviteCodeController.value.copyWith(
                          text: upperValue,
                          selection: TextSelection.collapsed(offset: upperValue.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contributionController,
                    label: 'Your Contribution Amount',
                    hint: 'Enter your contribution amount',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contribution amount is required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.blue.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'How it works',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Each member contributes their set amount every cycle\n'
                            '• One member collects all contributions each cycle\n'
                            '• Collection rotates among all members\n'
                            '• You can only see your own contribution amount\n'
                            '• The schedule shows when you or others will collect',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Join Group',
                    onPressed: _joinGroup,
                    isLoading: groupProvider.isLoading,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/create-group');
                      },
                      child: const Text('Want to create your own group instead?'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}