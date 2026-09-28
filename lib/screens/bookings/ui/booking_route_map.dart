import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';

class BookingRouteMap extends StatefulWidget {
  final String sourceAddress;
  final String destinationAddress;
  final String sourceLabel;
  final String destinationLabel;

  const BookingRouteMap({
    super.key,
    required this.sourceAddress,
    required this.destinationAddress,
    required this.sourceLabel,
    required this.destinationLabel,
  });

  @override
  State<BookingRouteMap> createState() => _BookingRouteMapState();
}

class _BookingRouteMapState extends State<BookingRouteMap> {
  GoogleMapController? mapController;
  LatLng? _sourceLocation;
  LatLng? _destinationLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  String? _errorMessage;

  final String googleApiKey = 'AIzaSyAkfch0HMM9K4rdDiZbj_cHYSHS4lJKhdg';
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': address,
          'key': googleApiKey,
        },
      );
      if (response.data['status'] == 'OK' && response.data['results'].isNotEmpty) {
        final loc = response.data['results'][0]['geometry']['location'];
        return LatLng(loc['lat'], loc['lng']);
      } else {
        debugPrint('Geocode API Error: ${response.data['status']} - ${response.data['error_message']}');
      }
    } catch (e) {
      debugPrint('Geocode exception: $e');
    }
    return null;
  }

  Future<List<LatLng>> _getDirections(LatLng origin, LatLng destination) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': googleApiKey,
        },
      );
      if (response.data['status'] == 'OK' && response.data['routes'].isNotEmpty) {
        final points = response.data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      } else {
        debugPrint('Directions API Error: ${response.data['status']} - ${response.data['error_message']}');
      }
    } catch (e) {
      debugPrint('Directions exception: $e');
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return polyline;
  }

  Future<void> _initializeMap() async {
    try {
      // 1. Geocode Addresses
      _sourceLocation = await _geocodeAddress(widget.sourceAddress);
      _destinationLocation = await _geocodeAddress(widget.destinationAddress);

      if (_sourceLocation == null || _destinationLocation == null) {
        setState(() {
          _errorMessage = "Could not find coordinates for one or both addresses.";
          _isLoading = false;
        });
        return;
      }

      // 2. Set Markers
      _markers.add(Marker(
        markerId: const MarkerId('source'),
        position: _sourceLocation!,
        infoWindow: InfoWindow(title: widget.sourceLabel),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));

      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation!,
        infoWindow: InfoWindow(title: widget.destinationLabel),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));

      // 3. Get Route Polyline
      List<LatLng> polylineCoordinates = await _getDirections(_sourceLocation!, _destinationLocation!);

      if (polylineCoordinates.isNotEmpty) {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ));
      }

      setState(() {
        _isLoading = false;
      });

      // Fit map to markers
      _fitMapToMarkers();

    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load map route: $e";
        _isLoading = false;
      });
    }
  }

  void _fitMapToMarkers() {
    if (mapController != null && _sourceLocation != null && _destinationLocation != null) {
      LatLngBounds bounds;
      if (_sourceLocation!.latitude > _destinationLocation!.latitude &&
          _sourceLocation!.longitude > _destinationLocation!.longitude) {
        bounds = LatLngBounds(southwest: _destinationLocation!, northeast: _sourceLocation!);
      } else if (_sourceLocation!.longitude > _destinationLocation!.longitude) {
        bounds = LatLngBounds(
            southwest: LatLng(_sourceLocation!.latitude, _destinationLocation!.longitude),
            northeast: LatLng(_destinationLocation!.latitude, _sourceLocation!.longitude));
      } else if (_sourceLocation!.latitude > _destinationLocation!.latitude) {
        bounds = LatLngBounds(
            southwest: LatLng(_destinationLocation!.latitude, _sourceLocation!.longitude),
            northeast: LatLng(_sourceLocation!.latitude, _destinationLocation!.longitude));
      } else {
        bounds = LatLngBounds(southwest: _sourceLocation!, northeast: _destinationLocation!);
      }
      
      Future.delayed(const Duration(milliseconds: 500), () {
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(_errorMessage!, style: TextStyle(color: Colors.red[800])),
        ),
      );
    }

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _sourceLocation ?? const LatLng(0, 0),
          zoom: 12,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _fitMapToMarkers();
        },
      ),
    );
  }
}
