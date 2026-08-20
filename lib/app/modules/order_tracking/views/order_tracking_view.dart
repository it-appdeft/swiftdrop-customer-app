import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_customer_app/app/widgets/shimmer_widgets.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../../../data/models/order_model.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_image.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/error_state_widget.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) return const OrderTrackingShimmer();
        if (controller.hasError.value) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadOrder(
              Get.parameters['orderId'] ?? Get.arguments?['orderId'] ?? '',
            ),
          );
        }

        final order = controller.order.value;
        if (order == null) return const OrderTrackingShimmer();

        final restaurantName = order.displayRestaurantName;
        final restaurantAddress = order.restaurantAddressLine;

        // Extract 4-digit delivery pin from order number or delivery_code
        final cleanNumber = order.orderNumber.replaceAll(RegExp(r'\D'), '');
        final deliveryCode = cleanNumber.length >= 4
            ? cleanNumber.substring(cleanNumber.length - 4)
            : (order.orderNumber.length >= 4
                ? order.orderNumber.substring(order.orderNumber.length - 4)
                : '');

        final status = order.status.toString().toLowerCase();
        final isAwaitingConfirmation = status == 'placed' || status == 'pending';
        final isOrderPlaced = status == 'accepted' || status == 'confirmed';
        final isPreparing = status == 'preparing';
        final isOutForDelivery = status == 'picked_up' || status == 'out_for_delivery' || status == 'on_the_way';
        final isDriverReached = status == 'driver_reached' || status == 'arrived';

        // Visibility rules based on UI flow
        final showDeliveryCode = deliveryCode.isNotEmpty && (isPreparing || isOutForDelivery || isDriverReached);
        final showDeliveryPartner = isPreparing || isOutForDelivery || isDriverReached;

        return NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _SliverTrackingHeader(order: order, restaurantName: restaurantName),
            ];
          },
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const _MapSection(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (showDeliveryCode) ...[
                        _DeliveryCodeSection(code: deliveryCode),
                        const SizedBox(height: 16),
                      ],
                      if (showDeliveryPartner) ...[
                        _DeliveryPartnerSection(order: order),
                        const SizedBox(height: 16),
                      ],
                      _DeliveryAddressCard(address: order.deliveryAddress),
                      const SizedBox(height: 16),
                      _OrderDetailsCard(
                        restaurantName: restaurantName,
                        restaurantAddress: restaurantAddress,
                        orderNumber: order.orderNumber,
                        items: order.items,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Total Paid',
                              value: AppUtils.formatCurrency(order.totalAmount),
                              valueColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Payment',
                              value: order.paymentMethod?.trim().isNotEmpty == true
                                  ? order.paymentMethod!
                                  : 'Online',
                              icon: Icons.credit_card,
                              isPayment: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SupportButton(),
                      if (isAwaitingConfirmation) ...[
                        const SizedBox(height: 24),
                        _CancelButton(order: order),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SliverTrackingHeader extends StatelessWidget {
  final dynamic order;
  final String restaurantName;

  const _SliverTrackingHeader({required this.order, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    String statusTitle = 'Awaiting Confirmation';
    String statusSubtitle = '';
    double progress = 0.15;

    switch (order.status.toString().toLowerCase()) {
      case 'placed':
      case 'pending':
        statusTitle = 'Awaiting Confirmation';
        statusSubtitle = '';
        progress = 0.15;
        break;
      case 'accepted':
      case 'confirmed':
        statusTitle = 'Order Placed';
        statusSubtitle = 'Food preparation will begin shorty';
        progress = 0.35;
        break;
      case 'preparing':
        statusTitle = 'Preparing Your Order';
        statusSubtitle = 'Arriving in ${order.estimatedTime} mins';
        progress = 0.60;
        break;
      case 'picked_up':
      case 'out_for_delivery':
      case 'on_the_way':
        statusTitle = 'Out For Delivery';
        statusSubtitle = 'Arriving in ${order.estimatedTime} mins';
        progress = 0.80;
        break;
      case 'driver_reached':
      case 'arrived':
        statusTitle = 'Driver Reached Your Location';
        statusSubtitle = 'Please share the delivery code';
        progress = 0.95;
        break;
      case 'delivered':
        statusTitle = 'Order Delivered';
        statusSubtitle = 'Enjoy your meal!';
        progress = 1.0;
        break;
      case 'cancelled':
        statusTitle = 'Order Cancelled';
        statusSubtitle = order.effectiveCancellationReason.isNotEmpty
            ? order.effectiveCancellationReason
            : 'Your request has been processed';
        progress = 1.0;
        break;
      default:
        statusTitle = 'Awaiting Confirmation';
        statusSubtitle = '';
        progress = 0.15;
        break;
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final hasSubtitle = statusSubtitle.isNotEmpty;
    final expandedHeight = topPadding + (hasSubtitle ? 160.0 : 140.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      floating: true,
      snap: true,
      elevation: 2,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () {
          AppUtils.haptic();
          Get.back();
        },
      ),
      title: Text(
        restaurantName,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Assets.images.reloadButton.image(width: 28, height: 28),
          onPressed: () {
            AppUtils.haptic();
            Get.find<OrderTrackingController>().refreshTracking();
          },
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding + 52, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                statusTitle,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasSubtitle) ...[
                const SizedBox(height: 4),
                Text(
                  statusSubtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapSection extends GetView<OrderTrackingController> {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Obx(() {
        if (!controller.hasMapData.value) {
          return _MapUnavailable(
            isLoading: controller.isLoading.value,
          );
        }

        final order = controller.order.value;
        final isFinished = order != null && !order.isActive;

        return Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: controller.initialCamera,
                markers: controller.markers.value,
                polylines: controller.polylines.value,
                onMapCreated: controller.onMapCreated,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer()),
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: false,
                padding: const EdgeInsets.only(bottom: 8),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: _MapRoundButton(
                icon: Icons.my_location,
                onTap: controller.recenter,
              ),
            ),
            if (isFinished)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.isCancelled
                        ? const Color(0xFFDC3545)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.isCancelled ? 'Order cancelled' : 'Delivered',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _MapRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AppUtils.haptic();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.lightSurfaceNavy),
        ),
      ),
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  final bool isLoading;

  const _MapUnavailable({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.offWhite,
      alignment: Alignment.center,
      child: isLoading
          ? const AppLoader()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.images.locationIcon.image(width: 28, height: 28),
                const SizedBox(height: 12),
                Text(
                  'Live map is not available for this order',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF868AA5),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DeliveryCodeSection extends StatelessWidget {
  final String code;

  const _DeliveryCodeSection({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Delivery Code',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF0B243A),
            ),
          ),
          Row(
            children: code.split('').map((digit) {
              return Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE1E2E3)),
                ),
                child: Text(
                  digit,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF868AA5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPartnerSection extends StatelessWidget {
  final OrderModel order;

  const _DeliveryPartnerSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final partnerName = order.driverName?.trim() ?? '';
    final isAssigning = partnerName.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isAssigning
          ? Row(
              children: [
                Assets.images.assigningPartner.image(width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.isActive
                        ? 'Assigning a delivery partner...'
                        : 'No delivery partner assigned',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: AppImage(
                      path: order.driverImage,
                      width: 48,
                      height: 48,
                      fallback:
                          Assets.images.deliveryPartner.image(width: 48, height: 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                      Text(
                        '230 Order delivered',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF868AA5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.driverRating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          order.driverRating!.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF0B243A),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  final String address;

  const _DeliveryAddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.locationIcon.image(width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0B243A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF868AA5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final String restaurantName;
  final String restaurantAddress;
  final String orderNumber;
  final List<dynamic> items;

  const _OrderDetailsCard({
    required this.restaurantName,
    required this.restaurantAddress,
    required this.orderNumber,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.images.storeImage.image(width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0B243A),
                      ),
                    ),
                    Text(
                      restaurantAddress,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF868AA5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE1E2E3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Text(
                '#$orderNumber',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B243A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF868AA5),
                      ),
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(item.price),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final bool isPayment;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.isPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF868AA5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isPayment ? 16 : 20,
                  color: const Color(0xFF0B243A),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: isPayment ? 14 : 18,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF0B243A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(AppRoutes.helpCenter);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Assets.images.goToSupport.image(width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              'Go to Support',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0B243A),
              ),
            ),
            const Spacer(),
            Assets.images.rightArrow.image(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

class _CancelButton extends GetView<OrderTrackingController> {
  final dynamic order;

  const _CancelButton({required this.order});

  @override
  Widget build(BuildContext context) {
    final st = order.status.toString().toLowerCase();
    if (st != 'pending' && st != 'placed') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancellationDialog(context, order.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC3545),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Cancel Order',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context, String orderId) {
    String selectedReason = '';
    final customReasonController = TextEditingController();
    bool isSubmitting = false;

    // Fetch dynamic options from API
    controller.fetchCancellationReasons().then((reasonsList) {
      if (reasonsList.isNotEmpty && selectedReason.isEmpty) {
        selectedReason = reasonsList.first;
      }
    });

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 28,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cancel This Order?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B243A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select a reason for cancellation. Reason is required.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF868AA5),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.isFetchingReasons.value &&
                        controller.cancellationReasons.isEmpty) {
                      return _buildReasonsShimmer();
                    }

                    final dynamicReasons = controller.cancellationReasons.isNotEmpty
                        ? controller.cancellationReasons.toList()
                        : [
                            'Ordered by mistake',
                            'Want to change items',
                            'Delivery time too long',
                            'Found a better option',
                            'Other',
                          ];

                    if (selectedReason.isEmpty && dynamicReasons.isNotEmpty) {
                      selectedReason = dynamicReasons.first;
                    }

                    final isOtherSelected = selectedReason == 'Other';

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...dynamicReasons.map((reason) {
                          final isSelected = selectedReason == reason;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  AppUtils.haptic();
                                  setSheetState(() => selectedReason = reason);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.06)
                                        : const Color(0xFFF8F9FB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reason,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: const Color(0xFF0B243A),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : const Color(0xFFE1E2E3),
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isSelected && reason == 'Other') ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TextField(
                                    controller: customReasonController,
                                    onChanged: (_) => setSheetState(() {}),
                                    maxLines: 3,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF0B243A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Please enter your reason here...',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFFA0A5BA),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FB),
                                      contentPadding: const EdgeInsets.all(12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              AppUtils.haptic();
                              final reasonToSubmit = isOtherSelected
                                  ? customReasonController.text.trim()
                                  : selectedReason;

                              if (reasonToSubmit.isEmpty) {
                                AppUtils.showError(
                                    'Please enter a cancellation reason');
                                return;
                              }

                              _showConfirmationDialog(
                                context,
                                orderId,
                                reasonToSubmit,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD94D52),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Cancel Order',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      AppUtils.haptic();
                      Get.back();
                    },
                    child: Text(
                      'Keep order',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String orderId, String reasonToSubmit) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD94D52).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD94D52),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel Order?',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B243A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this order? This action cannot be undone.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF868AA5),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AppUtils.haptic();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE1E2E3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keep Order',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        AppUtils.haptic();
                        // 1. Close confirmation dialog
                        Get.back();
                        // 2. Close bottom sheet
                        if (Get.isBottomSheetOpen ?? false) {
                          Get.back();
                        }
                        // 3. Trigger cancellation API & refresh tracking
                        await controller.cancelOrder(
                          orderId,
                          reason: reasonToSubmit,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD94D52),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildReasonsShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppShimmer(
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              AppShimmer.circle(size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
