import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/document_state.dart';
import 'dart:async';
import 'financial_settings_dialog.dart';
import '../utils/currency_converter.dart';

class FinancialNavbar extends StatefulWidget {
  @override
  _FinancialNavbarState createState() => _FinancialNavbarState();
}

class _FinancialNavbarState extends State<FinancialNavbar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  int _currentMetricIndex = 0;
  
  final List<String> _metricTitles = [
    'Projected Revenue',
    'Development Cost',
    'ROI',
    'Break-even'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    
    // Set up timer to rotate between metrics
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentMetricIndex = (_currentMetricIndex + 1) % _metricTitles.length;
      });
      _animationController.reset();
      _animationController.forward();
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context);
    final timeEstimate = documentState.getTimeEstimate();
    final revenueEstimate = documentState.getRevenueEstimate();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 360;
    
    final months = timeEstimate['months'] ?? 0;
    final weeks = timeEstimate['weeks'] ?? 0;
    final totalDays = (months * 30) + (weeks * 7);
    
    final initial = revenueEstimate['initial'] ?? 0.0;
    final monthly = revenueEstimate['monthly'] ?? 0.0;
    final yearly = revenueEstimate['yearlyTotal'] ?? 0.0;
    
    // Calculate metrics using the custom daily rate and region multiplier
    final developmentCost = totalDays * documentState.dailyRate;
    final firstYearProfit = yearly - developmentCost;
    final roi = developmentCost > 0 ? (firstYearProfit / developmentCost) * 100 : 0;
    final monthsToBreakEven = monthly > 0 ? developmentCost / monthly : 0;
    
    // Format all metrics with the selected currency
    final metrics = [
      documentState.formatCurrency(yearly),
      documentState.formatCurrency(developmentCost),
      '${roi.toStringAsFixed(1)}%',
      '${monthsToBreakEven.toStringAsFixed(1)} months'
    ];
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Region and currency indicator - hide on very small screens
          if (!isVerySmallScreen)
            Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(right: BorderSide(color: Colors.grey.shade300))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 2),
                      Text(
                        documentState.selectedRegion,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 9,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.currency_exchange,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 2),
                      Text(
                        documentState.selectedCurrency,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Main metrics display
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.indigo.shade800, Colors.indigo.shade600],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(0.0, 0.5, curve: Curves.easeIn),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricTitles[_currentMetricIndex],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            metrics[_currentMetricIndex],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Client agreement indicator - hide on small screens
          if (!isSmallScreen && documentState.clientAgreed) 
            _buildClientAgreedIndicator(documentState.agreedAmount, isSmallScreen),
          
          // Settings button
          InkWell(
            onTap: () => _openFinancialSettings(context, documentState),
            child: Container(
              width: isSmallScreen ? 50 : 60,
              color: Colors.indigo.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Details button
          InkWell(
            onTap: () {
              // Show detailed financial dialog
              _showDetailedFinancialsDialog(context, revenueEstimate, timeEstimate, documentState);
            },
            child: Container(
              width: isSmallScreen ? 50 : 60,
              color: Colors.amber[700],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClientAgreedIndicator(double amount, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: isSmallScreen ? 14 : 16,
            color: Colors.green,
          ),
          SizedBox(height: 2),
          Consumer<DocumentState>(
            builder: (context, documentState, _) {
              return Text(
                documentState.formatCurrency(amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.green.shade800,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _openFinancialSettings(BuildContext context, DocumentState documentState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedRegion = documentState.selectedRegion;
        String selectedCurrency = documentState.selectedCurrency;
        final dailyRateController = TextEditingController(
          text: documentState.dailyRateInSelectedCurrency.toString(),
        );
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Financial Settings'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Region',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedRegion,
                      onChanged: (newValue) {
                        setState(() {
                          selectedRegion = newValue!;
                        });
                      },
                      items: [
                        'North America',
                        'Europe',
                        'Asia',
                        'Australia',
                        'South America',
                        'Africa',
                        'Middle East',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      'Currency',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    CurrencyConverter.currencyDropdown(
                      value: selectedCurrency,
                      isExpanded: true,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCurrency = newValue;
                            // Update the daily rate to show in the newly selected currency
                            if (selectedCurrency != documentState.selectedCurrency) {
                              final newRate = documentState.convertToSelectedCurrency(
                                documentState.dailyRateInSelectedCurrency, 
                                documentState.selectedCurrency
                              );
                              dailyRateController.text = newRate.toStringAsFixed(2);
                            }
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      'Daily Rate (${CurrencyConverter.currencies[selectedCurrency]?.symbol})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: dailyRateController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(),
                        prefixText: CurrencyConverter.currencies[selectedCurrency]?.symbol,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Parse the daily rate
                    double? newRate;
                    try {
                      newRate = double.parse(dailyRateController.text);
                    } catch (e) {
                      // If parsing fails, show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid daily rate value'))
                      );
                      return;
                    }
                    
                    // Convert rate to USD if not already in USD
                    double usdRate = newRate;
                    if (selectedCurrency != 'USD') {
                      usdRate = CurrencyConverter.convert(newRate, selectedCurrency, 'USD');
                    }
                    
                    // Save settings
                    documentState.saveSettings(
                      region: selectedRegion,
                      rate: usdRate,
                      currency: selectedCurrency,
                    );
                    
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showDetailedFinancialsDialog(
      BuildContext context, 
      Map<String, dynamic> revenueEstimate, 
      Map<String, dynamic> timeEstimate,
      DocumentState documentState) {
    
    final initial = revenueEstimate['initial'] ?? 0.0;
    final monthly = revenueEstimate['monthly'] ?? 0.0;
    final yearly = revenueEstimate['yearlyTotal'] ?? 0.0;
    
    final months = timeEstimate['months'] ?? 0;
    final weeks = timeEstimate['weeks'] ?? 0;
    final totalDays = (months * 30) + (weeks * 7);
    
    // Calculate metrics with custom daily rate
    final developmentCost = totalDays * documentState.dailyRate;
    final firstYearProfit = yearly - developmentCost;
    final roi = developmentCost > 0 ? (firstYearProfit / developmentCost) * 100 : 0;
    final monthsToBreakEven = monthly > 0 ? developmentCost / monthly : 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Financial Overview'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Region info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.public, color: Colors.indigo),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Region: ${documentState.selectedRegion}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                          Text(
                            'Rate Multiplier: ${documentState.regionMultiplier.toStringAsFixed(2)}x',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Currency info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.currency_exchange, color: Colors.blue),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currency: ${documentState.selectedCurrency}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            'Symbol: ${CurrencyConverter.currencies[documentState.selectedCurrency]?.symbol ?? "\$"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Client agreement info
                if (documentState.clientAgreed) Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Agreement',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            'Agreed Amount: ${documentState.formatCurrency(documentState.agreedAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (documentState.clientAgreed) SizedBox(height: 16),
                
                // Financial metrics
                _buildMetricRow('Daily Rate', documentState.formattedDailyRate, Colors.blue),
                _buildMetricRow('Development Days', '$totalDays', Colors.indigo),
                Divider(),
                _buildMetricRow('Initial Revenue', documentState.formatCurrency(initial), Colors.green),
                _buildMetricRow('Monthly Revenue', documentState.formatCurrency(monthly), Colors.blue),
                _buildMetricRow('Yearly Revenue', documentState.formatCurrency(yearly), Colors.purple),
                Divider(),
                _buildMetricRow('Development Cost', documentState.formatCurrency(developmentCost), Colors.red),
                _buildMetricRow('First Year Profit', documentState.formatCurrency(firstYearProfit), 
                    firstYearProfit >= 0 ? Colors.green : Colors.red),
                Divider(),
                _buildMetricRow('ROI', '${roi.toStringAsFixed(1)}%', 
                    roi >= 0 ? Colors.green : Colors.red),
                _buildMetricRow('Months to Break-even', '${monthsToBreakEven.toStringAsFixed(1)}', Colors.amber[700]!),
                Divider(),
                _buildMetricRow('Development Timeline', '$months months, $weeks weeks', Colors.indigo),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _openFinancialSettings(context, documentState),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: Text('Edit Settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
} 