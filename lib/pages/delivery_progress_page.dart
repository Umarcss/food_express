import 'package:flutter/material.dart';
import 'package:food_express/components/my_reciept.dart';
import 'package:food_express/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:food_express/pages/driver_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:food_express/services/notification_service.dart';

class DeliveryProgressPage extends StatefulWidget {
  const DeliveryProgressPage({super.key});

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentStep = 0;
  String _deliveryInstructions = "Leave at the door";
  bool _hasRated = false;
  bool _isContactlessDelivery = false;
  bool _isLeaveAtDoor = false;
  String? _deliveryPhoto;
  DateTime? _estimatedArrivalTime;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _driverLocation = const LatLng(0, 0); // Initial driver location
  LatLng _deliveryLocation = const LatLng(0, 0); // Initial delivery location
  final List<DeliveryStep> _deliverySteps = [
    DeliveryStep(
      title: "Order Confirmed",
      description: "Your order has been confirmed",
      icon: Icons.check_circle,
      isCompleted: true,
    ),
    DeliveryStep(
      title: "Preparing Order",
      description: "Restaurant is preparing your food",
      icon: Icons.restaurant,
      isCompleted: false,
    ),
    DeliveryStep(
      title: "On the Way",
      description: "Driver is on the way to deliver",
      icon: Icons.delivery_dining,
      isCompleted: false,
    ),
    DeliveryStep(
      title: "Delivered",
      description: "Enjoy your meal!",
      icon: Icons.home,
      isCompleted: false,
    ),
  ];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
    _initializeDelivery();
    _simulateDeliveryProgress();
  }

  void _initializeDelivery() async {
    // Get current location for delivery address
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _deliveryLocation = LatLng(position.latitude, position.longitude);
        _driverLocation = LatLng(
          position.latitude + 0.01, // Simulated driver location
          position.longitude + 0.01,
        );
        _updateMarkers();
      });
    } catch (e) {
      print('Error getting location: $e');
    }

    // Set estimated arrival time
    setState(() {
      _estimatedArrivalTime = DateTime.now().add(const Duration(minutes: 30));
    });
  }

  void _updateMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
        Marker(
          markerId: const MarkerId('delivery'),
          position: _deliveryLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Delivery Location'),
        ),
      };
    });
  }

  void _simulateDeliveryProgress() async {
    // Simulate delivery progress
    for (int i = 1; i < _deliverySteps.length; i++) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _currentStep = i;
        _deliverySteps[i - 1].isCompleted = true;
      });

      // Send notifications for status changes
      _sendStatusNotification(i);

      // Show rating dialog when delivery is completed
      if (i == _deliverySteps.length - 1 && !_hasRated) {
        _showRatingDialog(context);
      }
    }
  }

  void _sendStatusNotification(int step) {
    String title;
    String body;
    String status;

    switch (step) {
      case 1:
        title = 'Order Confirmed';
        body = 'Your order has been confirmed and is being prepared';
        status = 'confirmed';
        break;
      case 2:
        title = 'Order is Ready';
        body = 'Your order is ready and the driver is on the way';
        status = 'preparing';
        break;
      case 3:
        title = 'Driver is Arriving';
        body = 'Your driver is on the way to deliver your order';
        status = 'on_way';
        break;
      case 4:
        title = 'Order Delivered';
        body = 'Your order has been delivered. Enjoy your meal!';
        status = 'delivered';
        break;
      default:
        return;
    }

    // Send push notification
    _notificationService.showOrderStatusNotification(
      title: title,
      body: body,
      status: status,
    );

    // Send email notification
    _notificationService.sendEmailNotification(
      email: 'dawendoski@gmail.com', // Replace with actual user email
      subject: title,
      body: body,
    );

    // Send SMS notification
    _notificationService.sendSMSNotification(
      phoneNumber: '+2349162836212', // Replace with actual user phone
      message: '$title: $body',
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery in Progress"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showDeliveryOptionsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentStep = 0;
                for (var step in _deliverySteps) {
                  step.isCompleted = false;
                }
                _deliverySteps[0].isCompleted = true;
              });
              _simulateDeliveryProgress();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Map View (Mockup)
                if (_currentStep >= 2) // Show map when driver is on the way
                  Container(
                    height: 200,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Mockup map background
                          Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Map View',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Driver and delivery location markers
                          Positioned(
                            left: 50,
                            top: 50,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 50,
                            bottom: 50,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ETA Display
                if (_currentStep >= 2 && _estimatedArrivalTime != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated arrival: ${_formatTime(_estimatedArrivalTime!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                // Delivery status timeline
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (int i = 0; i < _deliverySteps.length; i++)
                        _buildDeliveryStep(i),
                    ],
                  ),
                ),

                // Order receipt
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MyReciept(),
                      if (_isContactlessDelivery || _isLeaveAtDoor)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isContactlessDelivery
                                      ? 'Contactless delivery requested'
                                      : 'Leave at door requested',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDeliveryStep(int index) {
    final step = _deliverySteps[index];
    final isActive = index == _currentStep;
    final isCompleted = step.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Step icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : isActive
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              color: isCompleted || isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),

          const SizedBox(width: 16),

          // Step details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  step.description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Status indicator or Cancel button
          if (isActive && index < 2) // Show cancel button for first two steps
            TextButton.icon(
              onPressed: () => _showCancelConfirmation(context),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            )
          else if (isActive &&
              index <
                  _deliverySteps.length -
                      1) // Show "In Progress" for steps before delivery
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "In Progress",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          // Profile picture of driver
          CircleAvatar(
            radius: 25,
            backgroundImage: const NetworkImage('https://picsum.photos/200'),
            child: IconButton(
              onPressed: () {
                _showDriverDetails(context);
              },
              icon: const Icon(Icons.person),
            ),
          ),

          const SizedBox(width: 10),

          // Driver details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Abba umar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "4.8",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              // Message button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverProfilePage(
                          driverName: "Abba umar",
                          driverPhone: "+2349162836212",
                          driverImage: "https://picsum.photos/200",
                          driverRating: "4.8",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message),
                ),
              ),

              const SizedBox(width: 10),

              // Call button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: '+1234567890',
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not launch phone call'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDriverDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Driver Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Abba Umar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vehicle: Toyota Camry",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "License Plate: ABC123",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Message Driver"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Message sent!"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Driver"),
        content: const Text("Would you like to call the driver?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Calling driver..."),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Call"),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text(
            "Are you sure you want to cancel this order? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, Keep Order"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Order cancelled successfully"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Yes, Cancel Order"),
          ),
        ],
      ),
    );
  }

  void _showDeliveryOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Delivery Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contactless Delivery Option
              SwitchListTile(
                title: const Text("Contactless Delivery"),
                subtitle: const Text("Driver will maintain social distance"),
                value: _isContactlessDelivery,
                onChanged: (value) {
                  setState(() {
                    _isContactlessDelivery = value;
                    if (value) _isLeaveAtDoor = false;
                  });
                },
              ),
              // Leave at Door Option
              SwitchListTile(
                title: const Text("Leave at Door"),
                subtitle:
                    const Text("Driver will leave the order at your door"),
                value: _isLeaveAtDoor,
                onChanged: (value) {
                  setState(() {
                    _isLeaveAtDoor = value;
                    if (value) _isContactlessDelivery = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Delivery Instructions
              TextField(
                controller: TextEditingController(text: _deliveryInstructions),
                decoration: const InputDecoration(
                  labelText: "Delivery Instructions",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _deliveryInstructions = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Delivery options updated"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showRatingDialog(BuildContext context) {
    double rating = 0;
    String comment = '';

    showDialog(
      context: context,
      barrierDismissible: false, // User must rate to close dialog
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Rate Your Delivery"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How was your delivery experience?"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Add a comment (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => comment = value,
              ),
            ],
          ),
          actions: [
            if (rating > 0) // Only show submit button if rating is given
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasRated = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Thank you for your feedback!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Submit Rating"),
              ),
          ],
        ),
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
