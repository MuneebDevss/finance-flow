import 'package:finance/Core/DeviceUtils/device_utils.dart';
import 'package:finance/Core/HelpingFunctions/custom_clipper.dart';
import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:finance/Features/Debts/Domain/debt_repo.dart';
import 'package:finance/Features/Debts/Presentation/Screens/add_debt.dart';
import 'package:finance/Features/Debts/Presentation/Screens/payment_screen.dart';
import 'package:finance/Features/Debts/Presentation/widgets/debt_card.dart';
import 'package:finance/Features/Debts/Presentation/widgets/debt_statistics.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// screens/debt_list_screen.dart
class DebtListScreen extends StatefulWidget {

  const DebtListScreen({super.key});

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  final DebtRepository _repository = DebtRepository();
  List<Debt> filteredDebts=[];
  bool isFirsTime=true;
  @override
  void initState() {
    _repository.fetchPreferedAmount(false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>_repository.fetchPreferedAmount(true),
      child: Scaffold(
        bottomNavigationBar: bottomNavigationWidget(3),
        appBar: AppBar(
          
          leading: Icon(Icons.trending_down_outlined),
          title: Text('Debt Management'),
          elevation: 0,
        ),
        body: Obx((){
          if(_repository.isLoading.isTrue) {
            return Center(child: CircularProgressIndicator());
          }
      
          return StreamBuilder<List<Debt>>(
            stream: _repository.getDebts(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }
          
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final debts = snapshot.data!;
              if(isFirsTime) {
                filteredDebts=debts;
                isFirsTime=false;
              }
              if (debts.isEmpty) {
                return _buildEmptyState(context,_repository.preferedAmount);
              }
          
          
              final totalDebt = filteredDebts.fold<double>(
                0, 
                (sum, debt) => sum + debt.remainingBalance
              );
          
              return CustomScrollView(
                slivers: [
                  
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: TDeviceUtils.getScreenWidth(context),
                          height: TDeviceUtils.getScreenHeight(context)/5,
                          
                          padding: EdgeInsets.only(left: 16,right: 16,top: 32,bottom: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Outstanding Debt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${totalDebt.toStringAsFixed(2)} ${_repository.preferedAmount}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${filteredDebts.length} Active ${filteredDebts.length == 1 ? 'Debt' : 'debts'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddEditDebtScreen()),
                                    ),
                                    icon: Icon(Icons.add),
                                    label: Text('Add Debt'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFC63C51),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: Color(0xFFC63C51)
                                      ),
                                      shape: RoundedRectangleBorder(
                                        
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Sizes.spaceBtwItems,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => PaymentScreen(debts: filteredDebts,)),
                                    ),
                                    icon: Icon(Icons.payment),
                                    label: Text('Pay Debt'),
                                    style: ElevatedButton.styleFrom(
                                      
                                      backgroundColor: Colors.teal,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: DebtStatisticsCard(debts: debts, preferedAmount: _repository.preferedAmount,),
                  ),
                  
                  SliverPadding(
                    padding: EdgeInsets.only(top:16,left: 16),
                    sliver: SliverToBoxAdapter(
                    child: Text("Debts:",style: Theme.of(context).textTheme.headlineSmall,),
                  ),
                  ),
                   SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Debt',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          if(value.isEmpty){
                            filteredDebts=debts;
                          }
                          else
                          {
                            filteredDebts=filteredDebts.where((debt)=>debt.name.contains(value)).toList();
                            
                          }
                          setState(() {
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    // Sorting Icons
                    IconButton(
                      icon: Icon(Icons.sort),
                      onPressed: () {
                        filteredDebts.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
                        setState(() {
                          
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        filteredDebts.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
                        setState(() {
                          
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
      
            // Descriptive text
            // SliverPadding(
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            //   sliver: SliverToBoxAdapter(
            //     child: Text(
            //       "Effortlessly and Effectively Manage Your Debts",
            //       style: Theme.of(context).textTheme.bodyMedium,
            //     ),
            //   ),
            // ),
            if(filteredDebts.isEmpty) 
                       SliverToBoxAdapter(
                         child: Column(
                           children: [
                             Center(
                                                 child: Padding(
                                                   padding: const EdgeInsets.all(8.0),
                                                   child: Column(
                                                                               children: [
                                                                                 Icon(Icons.trending_down_outlined),
                                                                                 Text("No debts Found.")
                                                                               ],
                                                   ),
                                                 ),
                                               ),
                           ],
                         ),
                       ),
                    
            // List of Debts
            if(filteredDebts.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    
                    return DebtCard(
                      debt: filteredDebts[index],
                      preferedAmount: _repository.preferedAmount,
                    );
                  },
                  childCount: filteredDebts.length,
                ),
              ),
            ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}



Widget _buildEmptyState(BuildContext context,String preferedAmount) {
  
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ClipPath(
            clipper: BottomShapeClipper(),
            child: Container(
              padding: EdgeInsets.only(left:  16,right:  16,top: 32),
                  
                width: TDeviceUtils.getScreenWidth(context),
                            height: TDeviceUtils.getScreenHeight(context)/5,
                          
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Outstanding Debt',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0.00 $preferedAmount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0 Active Debts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddEditDebtScreen()),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Add Debt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF000B58),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
  margin: EdgeInsets.all(16),
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: Color(0xFF49243E)
    ),
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Start Your Debt Management Journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(maxWidth: 320),
            child: Text(
              'Take control of your financial future by tracking and managing your debts in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
          SizedBox(height: 32),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 280),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditDebtScreen()),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Your First Debt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Add help or tutorial action here
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    SizedBox(width: 8),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
        ),
        
      ],
    );
  }
  


