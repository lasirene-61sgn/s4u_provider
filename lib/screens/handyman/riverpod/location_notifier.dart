import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/location_model.dart';

class LocationState {
  final List<Country> countries;
  final List<StateModel> states;
  final List<City> cities;
  final bool isLoading;

  LocationState({
    this.countries = const [],
    this.states = const [],
    this.cities = const [],
    this.isLoading = false,
  });

  LocationState copyWith({
    List<Country>? countries,
    List<StateModel>? states,
    List<City>? cities,
    bool? isLoading,
  }) {
    return LocationState(
      countries: countries ?? this.countries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  final ApiClient _api = ApiClient();

  @override
  LocationState build() {
    Future.microtask(() => fetchCountries());
    return LocationState();
  }

  Future<void> fetchCountries() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _api.post(endpoint: '/country-list');
      print('country-list res: $res');
      if (res is List) {
        final countries = res.map((e) => Country.fromJson(e)).toList();
        state = state.copyWith(countries: countries);
      } else if (res is Map && res['data'] is List) {
        final countries = (res['data'] as List).map((e) => Country.fromJson(e)).toList();
        state = state.copyWith(countries: countries);
      }
    } catch (e) {
      print('Failed to fetch countries: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchStates(int countryId) async {
    state = state.copyWith(isLoading: true, states: [], cities: []);
    try {
      final res = await _api.post(endpoint: '/state-list', body: {'country_id': countryId});
      print('state-list res: $res');
      if (res is List) {
        final states = res.map((e) => StateModel.fromJson(e)).toList();
        state = state.copyWith(states: states);
      } else if (res is Map && res['data'] is List) {
        final states = (res['data'] as List).map((e) => StateModel.fromJson(e)).toList();
        state = state.copyWith(states: states);
      }
    } catch (e) {
      print('Failed to fetch states: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchCities(int stateId) async {
    state = state.copyWith(isLoading: true, cities: []);
    try {
      final res = await _api.post(endpoint: '/city-list', body: {'state_id': stateId});
      print('city-list res: $res');
      if (res is List) {
        final cities = res.map((e) => City.fromJson(e)).toList();
        state = state.copyWith(cities: cities);
      } else if (res is Map && res['data'] is List) {
        final cities = (res['data'] as List).map((e) => City.fromJson(e)).toList();
        state = state.copyWith(cities: cities);
      }
    } catch (e) {
      print('Failed to fetch cities: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});
