import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/viewmodels/app_preferences.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/authentication/models/login_response.dart';
import 'package:delta_compressor_202501017/feature/authentication/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final pagePath = '/home';
  static final pageName = 'home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final appPreferences = AppPreferences();
    final userData = appPreferences.getUserData();
    final customerData = appPreferences.getCustomerData();

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          'Home',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.light,
          ),
        ),
        backgroundColor: AppColors.success,
        actions: [
          IconButton(
            icon: const Icon(Symbols.logout, color: AppColors.light),
            onPressed: () {
              appPreferences.clearLoginData();
              context.go(LoginPage.pagePath);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information Card
            _buildSectionTitle('ข้อมูลผู้ใช้'),
            SizedBox(height: 12.h),
            _buildUserCard(userData),
            SizedBox(height: 24.h),
            
            // Customer Information Card
            _buildSectionTitle('ข้อมูลลูกค้า'),
            SizedBox(height: 12.h),
            _buildCustomerCard(customerData),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.success,
      ),
    );
  }

  Widget _buildUserCard(LoginUserData? userData) {
    if (userData == null) {
      return _buildEmptyCard('ไม่มีข้อมูลผู้ใช้');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Symbols.person,
              label: 'ID',
              value: userData.id.toString(),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Symbols.badge,
              label: 'ชื่อ',
              value: userData.name,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Symbols.mail,
              label: 'อีเมล',
              value: userData.email,
            ),
            if (userData.position != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Symbols.work,
                label: 'ตำแหน่ง',
                value: userData.position!,
              ),
            ],
            if (userData.role != null && userData.role != '-') ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Symbols.admin_panel_settings,
                label: 'บทบาท',
                value: userData.role!,
              ),
            ],
            if (userData.approvedAt != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Symbols.check_circle,
                label: 'อนุมัติเมื่อ',
                value: userData.approvedAt!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(LoginCustomerData? customerData) {
    if (customerData == null) {
      return _buildEmptyCard('ไม่มีข้อมูลลูกค้า');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Symbols.business,
              label: 'Customer ID',
              value: customerData.customerId,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Symbols.store,
              label: 'ชื่อลูกค้า',
              value: customerData.customerName,
            ),
            if (customerData.branchId != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Symbols.location_on,
                label: 'Branch ID',
                value: customerData.branchId.toString(),
              ),
            ],
            if (customerData.branchName != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Symbols.place,
                label: 'ชื่อสาขา',
                value: customerData.branchName!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColors.success,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              AppText(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: AppText(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
