import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../data/models/group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contributionController = TextEditingController();
  final _customDurationController = TextEditingController();

  CycleType _selectedCycleType = CycleType.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contributionController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    setState(() {
      _endDate = date;
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    int cycleDuration;
    switch (_selectedCycleType) {
      case CycleType.weekly:
        cycleDuration = 7;
        break;
      case CycleType.monthly:
        cycleDuration = 30;
        break;
      case CycleType.custom:
        cycleDuration = int.tryParse(_customDurationController.text) ?? 30;
        break;
    }

    final success = await groupProvider.createGroup(
      name: _nameController.text.trim(),
      adminId: authProvider.currentUser!.id,
      cycleType: _selectedCycleType,
      cycleDuration: cycleDuration,
      startDate: _startDate,
      contributionAmount: double.parse(_contributionController.text),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      endDate: _endDate,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        // Refresh dashboard
        await groupProvider.loadUserGroups(authProvider.currentUser!.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(groupProvider.error ?? 'Failed to create group'),
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
        title: const Text('Create Group'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return const LoadingWidget(message: 'Creating group...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Group Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Group Name',
                    hint: 'Enter group name',
                    prefixIcon: Icons.group,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Group name is required';
                      }
                      if (value.length < 3) {
                        return 'Group name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    hint: 'Enter group description',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Saving Cycle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RadioListTile<CycleType>(
                            title: const Text('Weekly'),
                            subtitle: const Text('Collection every 7 days'),
                            value: CycleType.weekly,
                            groupValue: _selectedCycleType,
                            onChanged: (value) {
                              setState(() {
                                _selectedCycleType = value!;
                              });
                            },
                          ),
                          RadioListTile<CycleType>(
                            title: const Text('Monthly'),
                            subtitle: const Text('Collection every 30 days'),
                            value: CycleType.monthly,
                            groupValue: _selectedCycleType,
                            onChanged: (value) {
                              setState(() {
                                _selectedCycleType = value!;
                              });
                            },
                          ),
                          RadioListTile<CycleType>(
                            title: const Text('Custom'),
                            subtitle: const Text('Set custom duration'),
                            value: CycleType.custom,
                            groupValue: _selectedCycleType,
                            onChanged: (value) {
                              setState(() {
                                _selectedCycleType = value!;
                              });
                            },
                          ),
                          if (_selectedCycleType == CycleType.custom) ...[
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _customDurationController,
                              label: 'Duration (Days)',
                              hint: 'Enter number of days',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_selectedCycleType == CycleType.custom) {
                                  if (value == null || value.isEmpty) {
                                    return 'Duration is required';
                                  }
                                  final days = int.tryParse(value);
                                  if (days == null || days < 1 || days > 365) {
                                    return 'Duration must be between 1 and 365 days';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contribution & Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contributionController,
                    label: 'Your Contribution Amount',
                    hint: 'Enter amount',
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
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectStartDate,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'End Date (Optional)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectEndDate,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Text(
                                    _endDate != null
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'Select end date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _endDate != null ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_endDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _endDate = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Create Group',
                    onPressed: _createGroup,
                    isLoading: groupProvider.isLoading,
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