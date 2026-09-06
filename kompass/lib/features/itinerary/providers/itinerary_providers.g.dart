// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itineraryRepositoryHash() =>
    r'2cea40d894da126563fead5426c6e3896ef394d3';

/// See also [itineraryRepository].
@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider =
    AutoDisposeProvider<ItineraryRepository>.internal(
      itineraryRepository,
      name: r'itineraryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itineraryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryRepositoryRef = AutoDisposeProviderRef<ItineraryRepository>;
String _$tourItinerariesHash() => r'ca52d3338319905bfc2e3dd88061940d93e9739f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [tourItineraries].
@ProviderFor(tourItineraries)
const tourItinerariesProvider = TourItinerariesFamily();

/// See also [tourItineraries].
class TourItinerariesFamily extends Family<AsyncValue<List<ItineraryModel>>> {
  /// See also [tourItineraries].
  const TourItinerariesFamily();

  /// See also [tourItineraries].
  TourItinerariesProvider call(String tourId) {
    return TourItinerariesProvider(tourId);
  }

  @override
  TourItinerariesProvider getProviderOverride(
    covariant TourItinerariesProvider provider,
  ) {
    return call(provider.tourId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tourItinerariesProvider';
}

/// See also [tourItineraries].
class TourItinerariesProvider
    extends AutoDisposeStreamProvider<List<ItineraryModel>> {
  /// See also [tourItineraries].
  TourItinerariesProvider(String tourId)
    : this._internal(
        (ref) => tourItineraries(ref as TourItinerariesRef, tourId),
        from: tourItinerariesProvider,
        name: r'tourItinerariesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tourItinerariesHash,
        dependencies: TourItinerariesFamily._dependencies,
        allTransitiveDependencies:
            TourItinerariesFamily._allTransitiveDependencies,
        tourId: tourId,
      );

  TourItinerariesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tourId,
  }) : super.internal();

  final String tourId;

  @override
  Override overrideWith(
    Stream<List<ItineraryModel>> Function(TourItinerariesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TourItinerariesProvider._internal(
        (ref) => create(ref as TourItinerariesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tourId: tourId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ItineraryModel>> createElement() {
    return _TourItinerariesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TourItinerariesProvider && other.tourId == tourId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tourId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TourItinerariesRef on AutoDisposeStreamProviderRef<List<ItineraryModel>> {
  /// The parameter `tourId` of this provider.
  String get tourId;
}

class _TourItinerariesProviderElement
    extends AutoDisposeStreamProviderElement<List<ItineraryModel>>
    with TourItinerariesRef {
  _TourItinerariesProviderElement(super.provider);

  @override
  String get tourId => (origin as TourItinerariesProvider).tourId;
}

String _$itineraryControllerHash() =>
    r'465d646ad4d3c0be6b82fba8b7860a30f5d0ba73';

/// See also [ItineraryController].
@ProviderFor(ItineraryController)
final itineraryControllerProvider =
    AutoDisposeAsyncNotifierProvider<ItineraryController, void>.internal(
      ItineraryController.new,
      name: r'itineraryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itineraryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ItineraryController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
