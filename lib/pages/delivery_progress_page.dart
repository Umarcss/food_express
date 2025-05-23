import 'package:flutter/material.dart';
import 'package:food_express/components/my_reciept.dart';
import 'package:food_express/models/restaurant.dart';
import 'package:provider/provider.dart';

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
    _simulateDeliveryProgress();
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
    }
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
          child: Column(
            children: [
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

          // Status indicator
          if (isActive)
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              shape: BoxShape.circle,
            ),
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
                "Abba Umar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Text(
                "Driver",
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.7),
                ),
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
                    _showMessageDialog(context);
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
                  onPressed: () {
                    _showCallDialog(context);
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
