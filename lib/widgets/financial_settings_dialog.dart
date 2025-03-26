import 'package:flutter/material.dart';
import '../state/document_state.dart';
import '../utils/currency_converter.dart';

class FinancialSettingsDialog extends StatefulWidget {
  final DocumentState documentState;

  const FinancialSettingsDialog({
    Key? key,
    required this.documentState,
  }) : super(key: key);

  @override
  _FinancialSettingsDialogState createState() => _FinancialSettingsDialogState();
}

class _FinancialSettingsDialogState extends State<FinancialSettingsDialog> {
  late String _selectedRegion;
  late String _selectedCurrency;
  late double _customDailyRate;
  late bool _clientAgreed;
  late double _agreedAmount;
  
  final _rateController = TextEditingController();
  final _agreedAmountController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.documentState.selectedRegion;
    _selectedCurrency = widget.documentState.selectedCurrency;
    _customDailyRate = widget.documentState.dailyRateInSelectedCurrency;
    _clientAgreed = widget.documentState.clientAgreed;
    _agreedAmount = widget.documentState.agreedAmount;
    
    _rateController.text = _customDailyRate.toStringAsFixed(2);
    _agreedAmountController.text = _agreedAmount.toStringAsFixed(2);
  }
  
  @override
  void dispose() {
    _rateController.dispose();
    _agreedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = CurrencyConverter.currencies[_selectedCurrency]?.symbol ?? '\$';
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, color: Colors.indigo),
                  SizedBox(width: 12),
                  Text(
                    'Financial Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Region Selection
              Text(
                'Project Region',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRegion,
                    items: [
                      'North America',
                      'Europe',
                      'Asia',
                      'Australia',
                      'South America',
                      'Africa',
                      'Middle East',
                    ].map((region) {
                      final multiplier = region == 'North America' ? 1.0 :
                                         region == 'Europe' ? 1.2 :
                                         region == 'Asia' ? 0.8 :
                                         region == 'Australia' ? 1.15 :
                                         region == 'South America' ? 0.75 :
                                         region == 'Africa' ? 0.7 :
                                         region == 'Middle East' ? 1.1 : 1.0;
                                          
                      return DropdownMenuItem(
                        value: region,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(region),
                            Text(
                              'x${multiplier.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Currency Selection
              Text(
                'Currency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: CurrencyConverter.currencyDropdown(
                    value: _selectedCurrency,
                    isExpanded: true,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          // Convert the rate from the old currency to the new one
                          if (_selectedCurrency != newValue) {
                            double rateInUsd = _customDailyRate;
                            if (_selectedCurrency != 'USD') {
                              rateInUsd = CurrencyConverter.convert(
                                _customDailyRate, 
                                _selectedCurrency, 
                                'USD'
                              );
                            }
                            
                            double newRate = rateInUsd;
                            if (newValue != 'USD') {
                              newRate = CurrencyConverter.convert(
                                rateInUsd, 
                                'USD', 
                                newValue
                              );
                            }
                            
                            _customDailyRate = newRate;
                            _rateController.text = _customDailyRate.toStringAsFixed(2);
                            
                            // Also convert agreed amount
                            if (_clientAgreed) {
                              double amountInUsd = _agreedAmount;
                              if (_selectedCurrency != 'USD') {
                                amountInUsd = CurrencyConverter.convert(
                                  _agreedAmount, 
                                  _selectedCurrency, 
                                  'USD'
                                );
                              }
                              
                              double newAmount = amountInUsd;
                              if (newValue != 'USD') {
                                newAmount = CurrencyConverter.convert(
                                  amountInUsd, 
                                  'USD', 
                                  newValue
                                );
                              }
                              
                              _agreedAmount = newAmount;
                              _agreedAmountController.text = _agreedAmount.toStringAsFixed(2);
                            }
                          }
                          
                          _selectedCurrency = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Custom Daily Rate
              Text(
                'Daily Rate (Base)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter daily rate',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _customDailyRate = double.tryParse(value) ?? _customDailyRate;
                  }
                },
              ),
              SizedBox(height: 12),
              Text(
                'Effective Daily Rate: ${CurrencyConverter.format(_customDailyRate * widget.documentState.regionMultiplier, _selectedCurrency)}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 24),
              
              // Client Agreement
              Row(
                children: [
                  Checkbox(
                    value: _clientAgreed,
                    onChanged: (value) {
                      setState(() {
                        _clientAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Client has agreed to the project',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              if (_clientAgreed) ...[
                Text(
                  'Agreed Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _agreedAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: currencySymbol,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Enter agreed amount',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _agreedAmount = double.tryParse(value) ?? _agreedAmount;
                    }
                  },
                ),
                SizedBox(height: 16),
              ],
              
              Divider(),
              SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    try {
      // Convert the rate to USD if needed
      double usdRate = _customDailyRate;
      if (_selectedCurrency != 'USD') {
        usdRate = CurrencyConverter.convert(_customDailyRate, _selectedCurrency, 'USD');
      }
      
      // Convert agreed amount to USD if needed
      double usdAgreedAmount = _agreedAmount;
      if (_selectedCurrency != 'USD' && _clientAgreed) {
        usdAgreedAmount = CurrencyConverter.convert(_agreedAmount, _selectedCurrency, 'USD');
      }
      
      // Update settings in DocumentState
      widget.documentState.saveSettings(
        region: _selectedRegion,
        rate: usdRate,
        currency: _selectedCurrency,
      );
      
      // Update client agreement
      if (_clientAgreed != widget.documentState.clientAgreed || 
          (widget.documentState.clientAgreed && widget.documentState.agreedAmount != usdAgreedAmount)) {
        // Set client agreement - implement this method if needed
        // widget.documentState.setClientAgreement(_clientAgreed, usdAgreedAmount);
      }
      
      // Close the dialog
      Navigator.pop(context, true);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings updated successfully'))
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: $e'))
      );
    }
  }
}

Future<bool?> showFinancialSettingsDialog(BuildContext context, DocumentState documentState) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => FinancialSettingsDialog(documentState: documentState),
  );
} 