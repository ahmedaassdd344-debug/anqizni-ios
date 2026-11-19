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
      'dropoffZone': _dropoffName,
      'dropoffLat': _dropoffPos.latitude,
      'dropoffLng': _dropoffPos.longitude,
      'distanceKm': dist,
      'vehicleCategory': _selectedVehicle,
      'serviceLine': _selectedService,
      'paymentMethod': _selectedPayment,
      'lockedPriceEgp': price,
      'pin': pin,
      'status': 'SEARCHING',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() => _activeTripId = id);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTripId != null) {
      return StreamBuilder<DatabaseEvent>(
        stream: _tripsRef.child(_activeTripId!).onValue,
        builder: (context, snapshot) {
          final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return const Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('حالة الطلب: ${data['status']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kEmeraldOnline)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: kObsidianHeader, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('كود الأمان (PIN):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('${data['pin']}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('المسار: ${data['pickupZone']} ⬅ ${data['dropoffZone']}'),
                    Text('التكلفة: ${data['lockedPriceEgp']} ج.م (${data['paymentMethod']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        await _tripsRef.child(_activeTripId!).remove();
                        setState(() => _activeTripId = null);
                      },
                      child: const Text('إلغاء الطلب / طلب جديد'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final dist = calculateRoadDistanceKm(_pickupPos.latitude, _pickupPos.longitude, _dropoffPos.latitude, _dropoffPos.longitude);
    final lockedPrice = _calculateLockedPrice();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('خريطة التغطية المباشرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('استلام: $_pickupName', overflow: TextOverflow.ellipsis),
                          selected: _targetMode == 'pickup',
                          onSelected: (_) => setState(() => _targetMode = 'pickup'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('تسليم: $_dropoffName', overflow: TextOverflow.ellipsis),
                          selected: _targetMode == 'dropoff',
                          onSelected: (_) => setState(() => _targetMode = 'dropoff'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kEgyptianZones.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, i) {
                        final z = kEgyptianZones[i];
                        return ActionChip(
                          label: Text(z.nameAr),
                          onPressed: () {
                            setState(() {
                              if (_targetMode == 'pickup') {
                                _pickupName = z.nameAr;
                                _pickupPos = LatLng(z.lat, z.lng);
                                _targetMode = 'dropoff';
                              } else {
                                _dropoffName = z.nameAr;
                                _dropoffPos = LatLng(z.lat, z.lng);
                              }
                            });
                            _mapController.move(LatLng(z.lat, z.lng), 12.5);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 240,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _pickupPos,
                          initialZoom: 12.0,
                          onTap: (_, point) {
                            setState(() {
                              if (_targetMode == 'pickup') {
                                _pickupName = 'موقع محدد على الخريطة';
                                _pickupPos = point;
                              } else {
                                _dropoffName = 'وجهة محددة على الخريطة';
                                _dropoffPos = point;
                              }
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://openstreetmap.org{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.aistudio.sakwinch.krmzqt',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(points: [_pickupPos, _dropoffPos], color: kRoyalCrimson, strokeWidth: 4),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(point: _pickupPos, child: const Icon(Icons.location_on, color: kEmeraldOnline, size: 36)),
                              Marker(point: _dropoffPos, child: const Icon(Icons.flag, color: kRoyalCrimson, size: 36)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('المسافة المحسوبة: $dist كم', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر فئة السيارة وخط الخدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('سيدان / عادية'),
                        selected: _selectedVehicle == 'سيدان / عادية',
                        onSelected: (_) => setState(() {
                          _selectedVehicle = 'سيدان / عادية';
                          _vehicleMult = 1.0;
                        }),
                      ),
                      ChoiceChip(
                        label: const Text('دفع رباعي SUV'),
                        selected: _selectedVehicle == 'دفع رباعي SUV',
                        onSelected: (_) => setState(() {
                          _selectedVehicle = 'دفع رباعي SUV';
                          _vehicleMult = 1.25;
                        }),
                      ),
                      ChoiceChip(
                        label: const Text('رياضية منخفضة VIP'),
                        selected: _selectedVehicle == 'رياضية منخفضة VIP',
  
