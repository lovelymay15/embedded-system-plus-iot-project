import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add this line

  bool isVacant = true;
  double temperature = 0.0;
  double humidity = 0.0;
  int airQuality = 0;
  int paperLevel = 0;
  bool _airQualityAlertShown = false;
  bool _paperLevelAlertShown = false;
  bool _humidityAlertShown = false;

  String _lastAirQualityStatus = 'Good';
  String _lastPaperLevelStatus = 'High';
  String _lastHumidityStatus = 'Normal';

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
  }

  bool _hasAirQualityAlert = false;
  bool _hasPaperLevelAlert = false;
  bool _hasHumidityAlert = false;

  void _setupRealtimeUpdates() {
    _database.child('Sensors').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          // Existing sensor data processing
          isVacant = data['occupancy'] == false;
          temperature = (data['temperature'] is num)
              ? (data['temperature'] as num).toDouble()
              : 0.0;
          humidity = (data['humidity'] is num)
              ? (data['humidity'] as num).toDouble()
              : 0.0;
          airQuality = (data['airQuality'] is num)
              ? (data['airQuality'] as num).toInt()
              : 0;
          paperLevel = (data['paperLevel'] is num)
              ? (data['paperLevel'] as num).toInt()
              : 0;

          // Air Quality Alert Logic
          String currentAirQualityStatus = getAirQualityStatus(airQuality);
          if (currentAirQualityStatus != _lastAirQualityStatus) {
            _airQualityAlertShown = false;
            _lastAirQualityStatus = currentAirQualityStatus;
          }
          _hasAirQualityAlert = currentAirQualityStatus == 'Bad';

          // Paper Level Alert Logic
          String currentPaperLevelStatus = getPaperLevelStatus(paperLevel);
          if (currentPaperLevelStatus != _lastPaperLevelStatus) {
            _paperLevelAlertShown = false;
            _lastPaperLevelStatus = currentPaperLevelStatus;
          }
          _hasPaperLevelAlert = currentPaperLevelStatus == 'Low';

          // Humidity Alert Logic
          String currentHumidityStatus = getHumidityStatus(humidity);
          if (currentHumidityStatus != _lastHumidityStatus) {
            _humidityAlertShown = false;
            _lastHumidityStatus = currentHumidityStatus;
          }
          _hasHumidityAlert = currentHumidityStatus == 'Low';

          // Show alerts
          if (_hasAirQualityAlert && !_airQualityAlertShown) {
            _showAirQualityAlert(
              'The current air quality is poor. Please take necessary precautions.',
            );
            _airQualityAlertShown = true;
          }

          if (_hasPaperLevelAlert && !_paperLevelAlertShown) {
            _showToiletPaperAlert(
              'The toilet paper level is low. Please restock it soon.',
            );
            _paperLevelAlertShown = true;
          }

          if (_hasHumidityAlert && !_humidityAlertShown) {
            _showHumidityAlert(
              'Humidity levels are low. Proper ventilation and hydration are needed.',
            );
            _humidityAlertShown = true;
          }
        });
      }
    });
  }

  // Add a method to reset alert flags when needed
  void _resetAlertFlags() {
    _airQualityAlertShown = false;
    _paperLevelAlertShown = false;
    _humidityAlertShown = false;

    _lastAirQualityStatus = 'Good';
    _lastPaperLevelStatus = 'High';
    _lastHumidityStatus = 'Normal';
  }

  // Method to build notification bar
  Widget _buildNotificationBar() {
    List<Widget> notifications = [];

    if (_hasAirQualityAlert) {
      notifications.add(_buildAirQualityNotification());
    }

    if (_hasPaperLevelAlert) {
      notifications.add(_buildToiletPaperNotification());
    }

    if (_hasHumidityAlert) {
      notifications.add(_buildHumidityNotification());
    }

    return notifications.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.transparent,
            child: Column(
              children: notifications,
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildAirQualityNotification() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.air_rounded, color: Colors.green.shade700, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Quality Alert',
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'The current air quality is poor. Please take necessary precautions.',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityNotification() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop_outlined,
              color: Colors.blue.shade700, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Humidity Alert',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Humidity levels are low. Please ensure proper ventilation and hydration.',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New Humidity Alert Dialog
  void _showHumidityAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blue.shade100, width: 3),
          ),
          backgroundColor: Colors.blue.shade50.withOpacity(0.9),
          title: Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: Colors.blue.shade700, size: 30),
              SizedBox(width: 10),
              Text(
                'Humidity Alert',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.blue.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    setState(() {
      _hasHumidityAlert = true;
    });
  }

  // New method to get humidity status
  String getHumidityStatus(double value) {
    if (value > 90) return 'Low';
    if (value > 70) return 'High';
    return 'Normal';
  }

  Widget _buildToiletPaperNotification() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.document_scanner_outlined,
              color: Colors.red.shade700, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toilet Paper Alert',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'The toilet paper level is low. Please restock it soon.',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Method to display an alert dialog
  void _showAirQualityAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.green.shade100, width: 3),
          ),
          backgroundColor: Colors.green.shade50.withOpacity(0.9),
          title: Row(
            children: [
              Icon(Icons.air_rounded, color: Colors.green.shade700, size: 30),
              SizedBox(width: 10),
              Text(
                'Air Quality Alert',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.green.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    setState(() {
      _hasAirQualityAlert = true;
    });
  }

  void _showToiletPaperAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.red.shade100, width: 3),
          ),
          backgroundColor: Colors.red.shade50.withOpacity(0.9),
          title: Row(
            children: [
              Icon(Icons.document_scanner_outlined,
                  color: Colors.red.shade700, size: 30),
              SizedBox(width: 10),
              Text(
                'Toilet Paper Alert',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.red.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    setState(() {
      _hasPaperLevelAlert = true;
    });
  }

  String getAirQualityStatus(int value) {
    if (value <= 300) return 'Good';
    if (value <= 2000) return 'Moderate';
    return 'Bad';
  }

  Color getAirQualityColor(int value) {
    if (value <= 300) return Colors.green;
    if (value <= 2000) return Colors.orange;
    return Colors.red;
  }

  String getPaperLevelStatus(int value) {
    if (value < 80) return 'Low';
    if (value >= 80 && value <= 700) return 'Moderate';
    return 'High';
  }

  Color getPaperLevelColor(int value) {
    if (value < 80) return Colors.red; // Low status is now red
    if (value >= 80 && value <= 700)
      return Colors.orange; // Moderate status is orange
    return Colors.green; // High status remains green
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // Full width minus padding

    return Scaffold(
      key: _scaffoldKey, // Add this line
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'PureSense',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // Modified this line
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                color: Colors.blue,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Say goodbye to restroom chaos with PureSense! This smart restroom management app tackles common issues like overcrowding, poor air quality, and running low on toilet paper, all while making your life easier. With real-time updates on occupancy, air quality, and toilet paper levels sent straight to your phone, PureSense empowers you to maintain a clean and comfortable restroom effortlessly. Discover the future of hygiene management and enjoy peace of mind knowing that your facilities are always at their best. Join the PureSense revolution and transform the way you manage restrooms today!',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Development Team: 3MW',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('• --Member Name--',
                          style: TextStyle(fontSize: 16, height: 1.5)),
                      Text('• --Member Name--',
                          style: TextStyle(fontSize: 16, height: 1.5)),
                      Text('• --Member Name--',
                          style: TextStyle(fontSize: 16, height: 1.5)),
                      Text('• --Member Name--',
                          style: TextStyle(fontSize: 16, height: 1.5)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // New Notification Bar Added Here
            _buildNotificationBar(),

            // Rest of the existing body content
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Occupancy Card
                  Container(
                    width: cardWidth,
                    height: 180,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/restroom_bg.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'OCCUPANCY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isVacant ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          !isVacant ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                isVacant ? 'VACANT' : 'OCCUPIED',
                                style: TextStyle(
                                  color: isVacant ? Colors.green : Colors.red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Temperature and Humidity Card
                  Container(
                    width: cardWidth,
                    height: 180,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/temp_humid_bg.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Temperature Gauge
                              Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    child: CustomPaint(
                                      painter: GaugePainter(
                                        value: temperature,
                                        maxValue: 50,
                                        color:
                                            Color.fromARGB(255, 222, 225, 82),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${temperature.toStringAsFixed(1)}°C',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Temperature',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Humidity Gauge
                              Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    child: CustomPaint(
                                      painter: GaugePainter(
                                        value: humidity,
                                        maxValue: 100,
                                        color:
                                            Color.fromARGB(255, 238, 43, 215),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${humidity.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Humidity',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
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
                    ),
                  ),
                  SizedBox(height: 16),

                  // Air Quality Card with new design
                  Container(
                    width: cardWidth,
                    height: 180,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/air_quality_bg.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AIR QUALITY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LinearProgressIndicator(
                                        value: airQuality /
                                            2500, // Assuming max is 1000
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          getAirQualityColor(airQuality),
                                        ),
                                        minHeight: 15,
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getAirQualityStatus(airQuality),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'PPM: $airQuality',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Toilet Paper Level Card with new design
                  Container(
                    width: cardWidth,
                    height: 180,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/paper_level_bg.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOILET PAPER LEVEL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 1000 -
                                                  (paperLevel > 1000
                                                      ? 1000
                                                      : paperLevel),
                                              child: Container(),
                                            ),
                                            Expanded(
                                              flex: paperLevel > 1000
                                                  ? 1000
                                                  : paperLevel,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: getPaperLevelColor(
                                                      paperLevel),
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    bottom: Radius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            getPaperLevelStatus(paperLevel),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Gauge Painter for Temperature and Humidity
class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  GaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // Draw background circle
    canvas.drawCircle(center, radius - 5, paint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressAngle = (value / maxValue) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -3.14159 / 2, // Start from top
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
