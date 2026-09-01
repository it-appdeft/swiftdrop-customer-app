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
        if (controller.isLoading.value && controller.order.value == null) return const OrderTrackingShimmer();
        if (controller.hasError.value && controller.order.value == null) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadOrder(controller.orderId),
          );
        }

        final order = controller.order.value;
        if (order == null) return const OrderTrackingShimmer();

        final restaurantName = order.displayRestaurantName;
        final restaurantAddress = order.restaurantAddressLine;

        // Extract delivery code strictly from order.deliveryCode (do NOT show if null or empty)
        final rawCode = order.deliveryCode?.trim();
        final deliveryCode = (rawCode != null && rawCode.isNotEmpty && rawCode.toLowerCase() != 'null')
            ? rawCode
            : null;

        final isAwaitingConfirmation = order.isPending && order.isDriverUnassigned;
        final isOutForDelivery = order.isOutForDelivery || order.isDriverOnTheWay;
        final isDriverReached = order.isDriverReachedCustomer;

        // Delivery code is ONLY shown if backend provided a non-null delivery code
        final showDeliveryCode = deliveryCode != null && deliveryCode.isNotEmpty;
        final showDeliveryPartner = order.isDriverAssigned || order.isDriverReachedRestaurant || isOutForDelivery || isDriverReached;

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
                      if (showDeliveryCode && deliveryCode != null) ...[
                        _DeliveryCodeSection(
                          code: deliveryCode,
                          isHighlighted: isDriverReached,
                        ),
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
                        specialInstructions: order.specialInstructions,
                        subtotal: order.subtotalAmount,
                        deliveryFee: order.deliveryFee,
                        vatAmount: order.vatAmount,
                        discountAmount: order.discountAmount,
                        totalAmount: order.totalAmount,
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
                                  ? (order.paymentMethod!.toLowerCase().contains('card')
                                      ? 'Card Payment'
                                      : order.paymentMethod!)
                                  : (order.isPending ? 'Pending' : 'Paid'),
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
    String statusTitle = 'Order Placed';
    String statusSubtitle = 'Waiting for restaurant confirmation';
    double progress = 0.20;

    final String ordStatus = (order is OrderModel)
        ? order.effectiveOrderStatus.toLowerCase()
        : (order?.status ?? '').toString().toLowerCase();

    final String delStatus = (order is OrderModel)
        ? order.effectiveDeliveryStatus.toLowerCase()
        : '';

    final bool isCancelled = (order is OrderModel)
        ? order.isCancelled
        : (ordStatus == 'cancelled' || ordStatus == 'canceled' || ordStatus == 'rejected' || ordStatus == 'failed');

    final bool isDelivered = (order is OrderModel)
        ? order.isDelivered
        : (ordStatus == 'delivered' || ordStatus == 'completed' || delStatus == 'delivered');

    if (isCancelled) {
      statusTitle = 'Order Cancelled';
      statusSubtitle = (order is OrderModel && order.effectiveCancellationReason.isNotEmpty)
          ? order.effectiveCancellationReason
          : 'Your request has been processed';
      progress = 1.0;
    } else if (isDelivered) {
      statusTitle = 'Order Delivered';
      statusSubtitle = 'Enjoy your meal!';
      progress = 1.0;
    } else if (delStatus == 'reached_customer' || delStatus == 'driver_reached' || delStatus == 'arrived' || delStatus == 'driver_arrived') {
      statusTitle = 'Driver Reached Your Location';
      statusSubtitle = 'Please share the delivery code with driver';
      progress = 0.95;
    } else if (delStatus == 'on_the_way' || delStatus == 'picked_up' || delStatus == 'in_transit' || ordStatus == 'out_for_delivery' || ordStatus == 'out_of_delivery') {
      statusTitle = 'Out For Delivery';
      final est = (order is OrderModel && order.etaMinutes != null && order.etaMinutes! > 0)
          ? order.etaMinutes!
          : ((order is OrderModel && order.estimatedTime > 0) ? order.estimatedTime : 15);
      statusSubtitle = 'Arriving in $est mins';
      progress = 0.85;
    } else if (delStatus == 'reached_restaurant' || delStatus == 'arrived_at_restaurant' || delStatus == 'at_restaurant' || delStatus == 'reached_resturant') {
      statusTitle = 'Driver at Restaurant';
      statusSubtitle = 'Picking up your order';
      progress = 0.75;
    } else if (ordStatus == 'ready' || ordStatus == 'ready_for_pickup' || ordStatus == 'ready_to_pickup' || ordStatus == 'food_ready') {
      statusTitle = 'Order Ready';
      statusSubtitle = 'Waiting for delivery partner to pickup';
      progress = 0.70;
    } else if (ordStatus == 'preparing' || ordStatus == 'kitchen' || ordStatus == 'in_kitchen' || ordStatus == 'in_progress' || ordStatus == 'food_preparing') {
      statusTitle = 'Preparing Your Order';
      final est = (order is OrderModel && order.etaMinutes != null && order.etaMinutes! > 0)
          ? order.etaMinutes!
          : ((order is OrderModel && order.estimatedTime > 0) ? order.estimatedTime : 19);
      statusSubtitle = 'Arriving in $est mins';
      progress = 0.55;
    } else if (ordStatus == 'accepted' || ordStatus == 'confirmed' || ordStatus == 'order_accepted') {
      statusTitle = 'Order Accepted';
      statusSubtitle = 'Food preparation will begin shortly';
      progress = 0.35;
    } else {
      statusTitle = 'Order Placed';
      statusSubtitle = 'Food preparation will begin shortly';
      progress = 0.20;
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final hasSubtitle = statusSubtitle.isNotEmpty;
    final expandedHeight = topPadding + (hasSubtitle ? 160.0 : 140.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () {
          AppUtils.haptic();
          Get.back();
        },
      ),
      title: Text(
        restaurantName.isNotEmpty ? restaurantName : 'The Marble Grill',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 18),
          ),
          onPressed: () {
            AppUtils.haptic();
            Get.find<OrderTrackingController>().refreshTracking();
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding + 50, 16, 16),
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
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Stack(
                children: [
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 5,
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
  final bool isHighlighted;

  const _DeliveryCodeSection({required this.code, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.success.withValues(alpha: 0.1) : AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? Border.all(color: AppColors.success, width: 1.2) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHighlighted) ...[
                  const Icon(Icons.pin_outlined, size: 18, color: AppColors.success),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Delivery Code',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isHighlighted ? AppColors.success : const Color(0xFF0B243A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isHighlighted)
                        Text(
                          'Share with delivery partner',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.success,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: code.split('').map((digit) {
              return Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isHighlighted ? AppColors.success : const Color(0xFFE1E2E3),
                  ),
                ),
                child: Text(
                  digit,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted ? AppColors.success : const Color(0xFF0B243A),
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

    String statusText = 'Assigned';
    if (order.isDriverReachedCustomer) {
      statusText = 'Reached your location';
    } else if (order.isDriverOnTheWay) {
      statusText = 'On the way to your location';
    } else if (order.isDriverReachedRestaurant) {
      statusText = 'At restaurant picking up';
    } else if (order.isDriverAssigned) {
      statusText = 'Heading to restaurant';
    }

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
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: order.isDriverReachedCustomer
                              ? AppColors.success
                              : const Color(0xFF868AA5),
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
  final String? specialInstructions;
  final double subtotal;
  final double deliveryFee;
  final double vatAmount;
  final double discountAmount;
  final double totalAmount;

  const _OrderDetailsCard({
    required this.restaurantName,
    required this.restaurantAddress,
    required this.orderNumber,
    required this.items,
    this.specialInstructions,
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.vatAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
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
                    if (restaurantAddress.isNotEmpty)
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
            final hasModifiers = item is OrderItem && item.modifiers.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0B243A),
                          ),
                        ),
                        if (hasModifiers) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.modifiers.join(', '),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF868AA5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(item is OrderItem && item.subtotal > 0 ? item.subtotal : (item.price * item.quantity)),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (specialInstructions != null && specialInstructions!.trim().isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFE1E2E3)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_alt_outlined, size: 18, color: Color(0xFF868AA5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Special Instructions',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialInstructions!.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF868AA5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (subtotal > 0 || vatAmount > 0 || deliveryFee > 0 || discountAmount > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFE1E2E3)),
            ),
            _buildBillRow('Item Subtotal', subtotal > 0 ? subtotal : (totalAmount - vatAmount - deliveryFee)),
            if (deliveryFee > 0) ...[
              const SizedBox(height: 8),
              _buildBillRow('Delivery Fee', deliveryFee),
            ],
            if (vatAmount > 0) ...[
              const SizedBox(height: 8),
              _buildBillRow('Taxes & Charges (VAT)', vatAmount),
            ],
            if (discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildBillRow('Discount', -discountAmount, isDiscount: true),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFE1E2E3)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B243A),
                  ),
                ),
                Text(
                  AppUtils.formatCurrency(totalAmount),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF868AA5),
          ),
        ),
        Text(
          isDiscount ? '-${AppUtils.formatCurrency(amount.abs())}' : AppUtils.formatCurrency(amount),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDiscount ? const Color(0xFF00B36F) : const Color(0xFF0B243A),
          ),
        ),
      ],
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
    if (order is OrderModel && order.cancellable == false) {
      return const SizedBox.shrink();
    }
    final st = order.status.toString().toLowerCase();
    if (st != 'pending' && st != 'placed') {
      return const SizedBox.shrink();
    }

    final cancelTargetId = (order is OrderModel && order.id.isNotEmpty)
        ? order.id
        : ((order is OrderModel && order.uuid != null && order.uuid!.isNotEmpty)
            ? order.uuid!
            : order.id.toString());

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancellationDialog(context, cancelTargetId),
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
