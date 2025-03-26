import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/document_state.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/financial_navbar.dart';
import '../utils/currency_converter.dart';

class ProjectEstimatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final documentState = Provider.of<DocumentState>(context, listen: false);
    final revenueEstimate = documentState.getRevenueEstimate();
    final timeEstimate = documentState.getTimeEstimate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Estimates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Development Timeline'),
            SizedBox(height: 16),
            _buildTimelineCard(timeEstimate),
            SizedBox(height: 24),
            _buildSectionHeader('Revenue Projections'),
            SizedBox(height: 16),
            _buildRevenueCard(revenueEstimate, context),
            SizedBox(height: 24),
            _buildSectionHeader('Key Performance Indicators'),
            SizedBox(height: 16),
            _buildKPIGrid(revenueEstimate, timeEstimate, context),
            SizedBox(height: 24),
            _buildSectionHeader('Optimization Strategies'),
            SizedBox(height: 16),
            _buildOptimizationCard(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        Container(
          width: 50,
          height: 4,
          margin: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.amber[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> timeEstimate) {
    final months = timeEstimate['months'] ?? 0;
    final weeks = timeEstimate['weeks'] ?? 0;
    final totalDays = (months * 30) + (weeks * 7);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo[700]!, Colors.indigo[900]!],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeMetric(months.toString(), 'Months'),
                _buildTimeMetric(weeks.toString(), 'Weeks'),
                _buildTimeMetric(totalDays.toString(), 'Days'),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Implementation Phases',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            _buildTimelinePhase('Planning & Analysis', '${(totalDays * 0.2).round()} days', 0.2),
            _buildTimelinePhase('Design & Architecture', '${(totalDays * 0.25).round()} days', 0.25),
            _buildTimelinePhase('Development', '${(totalDays * 0.35).round()} days', 0.35),
            _buildTimelinePhase('Testing & QA', '${(totalDays * 0.15).round()} days', 0.15),
            _buildTimelinePhase('Deployment', '${(totalDays * 0.05).round()} days', 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelinePhase(String phase, String duration, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              phase,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              duration,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildRevenueCard(Map<String, dynamic> revenueEstimate, BuildContext context) {
    final initial = revenueEstimate['initial'] ?? 0.0;
    final monthly = revenueEstimate['monthly'] ?? 0.0;
    final yearly = revenueEstimate['yearlyTotal'] ?? 0.0;
    final documentState = Provider.of<DocumentState>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRevenueMetric('Initial Setup', documentState.formatCurrency(initial), Colors.green[700]!),
                _buildRevenueMetric('Monthly', documentState.formatCurrency(monthly), Colors.blue[700]!),
                _buildRevenueMetric('Year Total', documentState.formatCurrency(yearly), Colors.purple[700]!),
              ],
            ),
            SizedBox(height: 20),
            _buildRevenueChart(revenueEstimate),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> revenueEstimate) {
    final monthly = revenueEstimate['monthly'] ?? 0.0;
    
    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projected Annual Revenue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                double height = (index == 0) 
                    ? 0.3 // First month includes setup fee
                    : 0.2 + (index * 0.05); // Gradual increase in revenue
                
                if (height > 1.0) height = 1.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 140 * height,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1 + (index * 0.075)),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'M${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(Map<String, dynamic> revenueEstimate, Map<String, dynamic> timeEstimate, BuildContext context) {
    final monthly = revenueEstimate['monthly'] ?? 0.0;
    final initial = revenueEstimate['initial'] ?? 0.0;
    final yearly = revenueEstimate['yearlyTotal'] ?? 0.0;
    final months = timeEstimate['months'] ?? 0;
    final weeks = timeEstimate['weeks'] ?? 0;
    final totalDays = (months * 30) + (weeks * 7);
    final documentState = Provider.of<DocumentState>(context, listen: false);
    
    // Calculate ROI and other metrics using the documentState daily rate
    final developmentCost = totalDays * documentState.dailyRate;
    final firstYearProfit = yearly - developmentCost;
    final roi = developmentCost > 0 ? (firstYearProfit / developmentCost) * 100 : 0;
    final monthsToBreakEven = monthly > 0 ? developmentCost / monthly : 0;
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildKPICard('Return on Investment', '${roi.toStringAsFixed(1)}%', Icons.trending_up, Colors.green),
        _buildKPICard('Break-even Point', '${monthsToBreakEven.toStringAsFixed(1)} months', Icons.balance, Colors.amber),
        _buildKPICard('Dev Cost', documentState.formatCurrency(developmentCost), Icons.code, Colors.indigo),
        _buildKPICard('First Year Profit', documentState.formatCurrency(firstYearProfit), Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color[700],
              size: 36,
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCard() {
    final optimizationTips = [
      {'tip': 'Use agile methodology to reduce development time by up to 30%', 'icon': Icons.speed},
      {'tip': 'Implement a subscription model to increase revenue predictability', 'icon': Icons.repeat},
      {'tip': 'Focus on retention strategies to improve CLV by 25%', 'icon': Icons.people},
      {'tip': 'Integrate analytics to identify revenue optimization opportunities', 'icon': Icons.insights},
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Optimization Strategies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            ...optimizationTips.map((tip) => _buildOptimizationTip(tip['tip'] as String, tip['icon'] as IconData)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTip(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[700],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 