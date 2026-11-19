import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDr7V6jVxHc9DpX-hopJakvkMXyKd7p3N0',
      appId: '1:512681588229:ios:954dd961b8097e922e4e6c',
      messagingSenderId: '512681588229',
      projectId: 'anqizni-app',
      storageBucket: 'anqizni-app.firebasestorage.app',
      databaseURL: 'https://firebaseio.com',
      iosBundleId: 'com.aistudio.sakwinch.krmzqt',
    ),
  );
  runApp(const AnqizniIosApp());
}

const Color kRoyalCrimson = Color(0xFFB91C1C);
const Color kObsidianHeader = Color(0xFF0F172A);
const Color kEmeraldOnline = Color(0xFF059669);
const Color kSurfaceMuted = Color(0xFFF1F5F9);

class EgyptianZone {
  final String nameAr;
  final double lat;
  final double lng;
  const EgyptianZone(this.nameAr, this.lat, this.lng);
}

const List<EgyptianZone> kEgyptianZones = [
  EgyptianZone('بولاق الدكرور', 30.0365, 31.1820),
  EgyptianZone('المهندسين', 30.0561, 31.2001),
  EgyptianZone('الشيخ زايد', 30.0444, 30.9850),
  EgyptianZone('التجمع الخامس', 30.0074, 31.4913),
  EgyptianZone('مدينة نصر', 30.0511, 31.3656),
  EgyptianZone('المعادي', 29.9602, 31.2569),
  EgyptianZone('مصر الجديدة', 30.0866, 31.3220),
  EgyptianZone('6 أكتوبر', 29.9285, 30.9188),
];

double calculateRoadDistanceKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180.0;
  final dLng = (lng2 - lng1) * pi / 180.0;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return double.parse((r * c * 1.25).toStringAsFixed(1));
}

class AnqizniIosApp extends StatelessWidget {
  const AnqizniIosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أنقذني × SAK Winch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: kRoyalCrimson),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainPortalScreen(),
      ),
    );
  }
}

class MainPortalScreen extends StatefulWidget {
  const MainPortalScreen({super.key});

  @override
  State<MainPortalScreen> createState() => _MainPortalScreenState();
}

class _MainPortalScreenState extends State<MainPortalScreen> {
  String _role = 'login';
  String _userName = 'عميل VIP';
  final _phoneController = TextEditingController(text: '01012345678');
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kObsidianHeader,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kRoyalCrimson,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('أنقذني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('SAK Winch × أنقذني', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          if (_role != 'login')
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => setState(() => _role = 'login'),
            ),
        ],
      ),
      body: _role == 'login'
          ? _buildLoginView()
          : _role == 'customer'
              ? CustomerIosScreen(customerName: _userName, customerPhone: _phoneController.text)
              : _role == 'captain'
                  ? const CaptainIosScreen()
                  : const AdminIosScreen(),
    );
  }

  Widget _buildLoginView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('تسجيل الدخول للمنصة (iOS)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('اختر بوابة الدخول للطلب أو إدارة الأسطول', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الموبايل',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRoyalCrimson,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.local_shipping_rounded),
                label: const Text('دخول العميل لطلب الإنقاذ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() {
                    _userName = _nameController.text.trim().isEmpty ? 'عميل VIP' : _nameController.text.trim();
                    _role = 'customer';
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _role = 'captain'),
                      child: const Text('بوابة الكابتن'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _role = 'admin'),
                      child: const Text('مركز الإدارة'),
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

class CustomerIosScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  const CustomerIosScreen({super.key, required this.customerName, required this.customerPhone});

  @override
  State<CustomerIosScreen> createState() => _CustomerIosScreenState();
}

class _CustomerIosScreenState extends State<CustomerIosScreen> {
  final DatabaseReference _tripsRef = FirebaseDatabase.instance.ref('trips');
  final MapController _mapController = MapController();

  String _pickupName = 'بولاق الدكرور';
  LatLng _pickupPos = const LatLng(30.0365, 31.1820);
  String _dropoffName = 'الشيخ زايد';
  LatLng _dropoffPos = const LatLng(30.0444, 30.9850);
  String _targetMode = 'pickup';
  String _selectedVehicle = 'سيدان / عادية';
  double _vehicleMult = 1.0;
  String _selectedService = 'إنقاذ فوري';
  double _serviceMult = 1.0;
  String _selectedPayment = 'كاش عند التسليم';
  String? _activeTripId;

  @override
  void initState() {
    super.initState();
    _initGpsLocation();
  }

  Future<void> _initGpsLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        setState(() {
          _pickupName = 'موقعي الحالي (GPS)';
          _pickupPos = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_pickupPos, 13.0);
      }
    } catch (_) {}
  }

  int _calculateLockedPrice() {
    final dist = calculateRoadDistanceKm(_pickupPos.latitude, _pickupPos.longitude, _dropoffPos.latitude, _dropoffPos.longitude);
    final raw = (350 + (dist * 35)) * _vehicleMult * _serviceMult;
    return (raw / 10).round() * 10;
  }

  Future<void> _submitOrder() async {
    final dist = calculateRoadDistanceKm(_pickupPos.latitude, _pickupPos.longitude, _dropoffPos.latitude, _dropoffPos.longitude);
    final price = _calculateLockedPrice();
    final pin = (1000 + Random().nextInt(9000)).toString();
    final newRef = _tripsRef.push();
    final id = newRef.key ?? 'SAK-${DateTime.now().millisecondsSinceEpoch}';

    await newRef.set({
      'id': id,
      'customerName': widget.customerName,
      'customerPhone': widget.customerPhone,
      'pickupZone': _pickupName,
      'pickupLat': _pickupPos.latitude,
      'pickupLng': _pickupPos.longitude,
