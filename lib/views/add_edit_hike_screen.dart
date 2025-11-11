import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../viewmodels/hike_viewmodel.dart';

class AddEditHikeScreen extends StatefulWidget {
  final Hike?
  hike;
  const AddEditHikeScreen({super.key, this.hike});

  @override
  AddEditHikeScreenState createState() => AddEditHikeScreenState();
}

class AddEditHikeScreenState extends State<AddEditHikeScreen> {
  final _formKey = GlobalKey<FormState>(); 
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _lengthController;
  late TextEditingController _descriptionController;

  // Values for dropdowns
  String _parkingValue = "Yes";
  String _difficultyValue = "Easy";

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hike?.name ?? '');
    _locationController = TextEditingController(
      text: widget.hike?.location ?? '',
    );
    _dateController = TextEditingController(text: widget.hike?.hikeDate ?? '');
    _lengthController = TextEditingController(
      text: widget.hike?.length.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.hike?.description ?? '',
    );

    _parkingValue = widget.hike?.parkingAvailable ?? 'Yes';
    _difficultyValue = widget.hike?.difficulty ?? 'Easy';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _lengthController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveHike() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = Provider.of<HikeViewModel>(context, listen: false);

    try {
      final hike = Hike(
        id: widget.hike?.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        hikeDate: _dateController.text.trim(),
        parkingAvailable: _parkingValue,
        length: double.parse(_lengthController.text.trim()),
        difficulty: _difficultyValue,
        description: _descriptionController.text.trim(),
      );

      if (widget.hike == null) {
        await viewModel.addHike(hike);
      } else {
        await viewModel.updateHike(hike);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hike saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save hike: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hike == null ? 'Add New Hike' : 'Edit Hike'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hike Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terrain),
                  counterText: "",
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  counterText: "",
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Field
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Hike Date *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Parking Spinner
              DropdownButtonFormField<String>(
                initialValue: _parkingValue,
                decoration: const InputDecoration(
                  labelText: 'Parking Available *',
                  border: OutlineInputBorder(),
                ),
                items: ['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _parkingValue = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Difficulty Spinner
              DropdownButtonFormField<String>(
                initialValue: _difficultyValue,
                decoration: const InputDecoration(
                  labelText: 'Difficulty *',
                  border: OutlineInputBorder(),
                ),
                items: ['Easy', 'Medium', 'Hard'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _difficultyValue = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Length Field
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (in km) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a length';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Length must be greater than 0';
                  }
                  if (double.parse(value) > 2000) {
                    return 'Length seems unreasonably high';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                  counterText: "",
                ),
                maxLines: 3,
                maxLength: 50,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveHike,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.hike == null ? Icons.add : Icons.save),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : (widget.hike == null ? 'Add Hike' : 'Update Hike'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
