import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_express/components/glass_surface.dart';
import 'package:food_express/components/my_reciept.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/models/order.dart';
import 'package:food_express/pages/driver_profile_page.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:food_express/providers/order_provider.dart';
import 'package:food_express/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryProgressPage extends StatefulWidget {
  const DeliveryProgressPage({super.key});

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  final LocationService _locationService = LocationService();
  LatLng? _deliveryLocation;
  LatLng? _driverLocation;
  int _currentStep = 0;
  Timer? _timer;
  String? _locationError;
  final Set<int> _announcedSteps = {};

  final List<String> _steps = const [
    'Order confirmed',
    'Kitchen preparing',
    'Driver assigned',
    'On the way',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderProvider>().currentOrder;
    _currentStep = _stepForStatus(order?.status);
    _announcedSteps.addAll(List.generate(_currentStep + 1, (index) => index));
    _initializeMap();
    _simulateProgress();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _locationError =
              'Location permission is needed for live delivery tracking.';
          _deliveryLocation = const LatLng(9.0765, 7.3986);
          _driverLocation = const LatLng(9.0815, 7.4050);
        });
        return;
      }
      setState(() {
        _deliveryLocation = LatLng(position.latitude, position.longitude);
        _driverLocation =
            LatLng(position.latitude + 0.01, position.longitude + 0.01);
      });
    } catch (error) {
      debugPrint('Location error: $error');
      if (!mounted) return;
      setState(() {
        _locationError = 'Unable to load your location right now.';
        _deliveryLocation = const LatLng(9.0765, 7.3986);
        _driverLocation = const LatLng(9.0815, 7.4050);
      });
    }
  }

  void _simulateProgress() {
    if (_currentStep >= _steps.length - 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _steps.length - 1) _currentStep++;
        if (_deliveryLocation != null && _driverLocation != null) {
          _driverLocation = LatLng(
            (_driverLocation!.latitude + _deliveryLocation!.latitude) / 2,
            (_driverLocation!.longitude + _deliveryLocation!.longitude) / 2,
          );
        }
      });
      _syncOrderForStep(_currentStep);
      if (_currentStep == _steps.length - 1) timer.cancel();
    });
  }

  int _stepForStatus(OrderStatus? status) {
    return switch (status) {
      OrderStatus.pending || OrderStatus.confirmed => 0,
      OrderStatus.preparing => 1,
      OrderStatus.onTheWay => 3,
      OrderStatus.delivered => 4,
      OrderStatus.cancelled || null => 0,
    };
  }

  void _syncOrderForStep(int step) {
    if (_announcedSteps.contains(step)) return;
    _announcedSteps.add(step);
    final orders = context.read<OrderProvider>();
    final notifications = context.read<NotificationProvider>();
    final status = switch (step) {
      0 => OrderStatus.confirmed,
      1 => OrderStatus.preparing,
      2 => OrderStatus.preparing,
      3 => OrderStatus.onTheWay,
      _ => OrderStatus.delivered,
    };
    orders.updateCurrentOrderStatus(status);
    final orderId = orders.currentOrder?.id;
    final body = switch (step) {
      1 => 'The kitchen has started preparing your meal.',
      2 => 'Abba Umar has been assigned to your delivery.',
      3 => 'Your driver is on the way to your address.',
      4 => 'Your demo order has been delivered. Enjoy your meal.',
      _ => 'Your order is confirmed.',
    };
    if (step > 0) {
      notifications.addDemoNotification(
        title: _steps[step],
        body: body,
        data: {'orderId': orderId},
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().currentOrder;
    final driver = order?.driver ?? const {};
    final driverName = driver['name'] as String? ?? 'Abba Umar';
    final driverPhone = driver['phone'] as String? ?? '+2349162836212';
    final driverRating = driver['rating'] as String? ?? '4.8';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Delivery'),
        actions: [
          IconButton(
            tooltip: 'Driver profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverProfilePage(
                  driverName: driverName,
                  driverPhone: driverPhone,
                  driverImage: 'https://picsum.photos/200',
                  driverRating: driverRating,
                ),
              ),
            ),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap()),
          DraggableScrollableSheet(
            minChildSize: 0.34,
            initialChildSize: 0.42,
            maxChildSize: 0.82,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.mutedText.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _steps[_currentStep],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Estimated arrival: ${DateTime.now().add(const Duration(minutes: 24)).hour.toString().padLeft(2, '0')}:${DateTime.now().add(const Duration(minutes: 24)).minute.toString().padLeft(2, '0')}',
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _locationError!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    for (var i = 0; i < _steps.length; i++)
                      _TimelineStep(
                        label: _steps[i],
                        isActive: i == _currentStep,
                        isDone: i < _currentStep,
                      ),
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.gold,
                            child: Icon(
                              Icons.delivery_dining,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(driverName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text('$driverRating rating'),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final uri = Uri(scheme: 'tel', path: driverPhone);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.call),
                          ),
                        ],
                      ),
                    ),
                    if (order == null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Demo order receipt'),
                      const MyReceipt(),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_deliveryLocation == null || _driverLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return _SimulatedDeliveryMap(
        deliveryLocation: _deliveryLocation!,
        driverLocation: _driverLocation!,
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _deliveryLocation!,
        zoom: 14,
      ),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('delivery'),
          position: _deliveryLocation!,
          infoWindow: const InfoWindow(title: 'Delivery address'),
        ),
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      },
    );
  }
}

class _SimulatedDeliveryMap extends StatelessWidget {
  final LatLng deliveryLocation;
  final LatLng driverLocation;

  const _SimulatedDeliveryMap({
    required this.deliveryLocation,
    required this.driverLocation,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5E6),
            Color(0xFFF9CFAE),
            Color(0xFF9ED8C3),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          Positioned(
            left: 42,
            top: 120,
            child: _MapMarker(
              icon: Icons.home_rounded,
              label: 'You',
              color: AppColors.success,
              coordinate: deliveryLocation,
            ),
          ),
          Positioned(
            right: 58,
            top: 84,
            child: _MapMarker(
              icon: Icons.delivery_dining,
              label: 'Driver',
              color: AppColors.tomato,
              coordinate: driverLocation,
            ),
          ),
          Positioned(
            top: 96,
            left: 96,
            right: 112,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.tomato.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          Positioned(
            top: 86,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: SafeArea(
              child: GlassSurface(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: AppColors.tomato),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Simulated web map. Real Google Maps runs on mobile.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final LatLng coordinate;

  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
    required this.coordinate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '$label marker at ${coordinate.latitude.toStringAsFixed(3)}, ${coordinate.longitude.toStringAsFixed(3)}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: AppShadows.tight(color),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          GlassSurface(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    final minorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    for (var y = 70.0; y < size.height; y += 92) {
      canvas.drawLine(
          Offset(-20, y), Offset(size.width + 20, y + 40), minorRoadPaint);
    }
    for (var x = -40.0; x < size.width; x += 110) {
      canvas.drawLine(
          Offset(x, -20), Offset(x + 90, size.height + 20), minorRoadPaint);
    }

    final route = Path()
      ..moveTo(70, 150)
      ..cubicTo(
          size.width * 0.3, 80, size.width * 0.58, 168, size.width - 84, 112);
    canvas.drawPath(route, roadPaint);

    final parkPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.16, 140, 84),
        const Radius.circular(18),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _TimelineStep({
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone || isActive ? AppColors.tomato : AppColors.mutedText;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryStep {
  final String title;
  final String description;
  final IconData icon;
  bool isCompleted;

  DeliveryStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
  });
}
