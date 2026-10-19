// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tourRepositoryHash() => r'd047cac17f911f43ba751a90d0773f39ce2cb233';

/// See also [tourRepository].
@ProviderFor(tourRepository)
final tourRepositoryProvider = AutoDisposeProvider<TourRepository>.internal(
  tourRepository,
  name: r'tourRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tourRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TourRepositoryRef = AutoDisposeProviderRef<TourRepository>;
String _$toursHash() => r'43107dc9d7180aba890ee4ec606a5d30b5e9d3bd';

/// See also [tours].
@ProviderFor(tours)
final toursProvider = AutoDisposeStreamProvider<List<TourModel>>.internal(
  tours,
  name: r'toursProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$toursHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ToursRef = AutoDisposeStreamProviderRef<List<TourModel>>;
String _$tourDetailHash() => r'4e195444e5038f6eb080218ba5338fe1b428564f';

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

/// See also [tourDetail].
@ProviderFor(tourDetail)
const tourDetailProvider = TourDetailFamily();

/// See also [tourDetail].
class TourDetailFamily extends Family<AsyncValue<TourModel>> {
  /// See also [tourDetail].
  const TourDetailFamily();

  /// See also [tourDetail].
  TourDetailProvider call(String tourId) {
    return TourDetailProvider(tourId);
  }

  @override
  TourDetailProvider getProviderOverride(
    covariant TourDetailProvider provider,
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
  String? get name => r'tourDetailProvider';
}

/// See also [tourDetail].
class TourDetailProvider extends AutoDisposeStreamProvider<TourModel> {
  /// See also [tourDetail].
  TourDetailProvider(String tourId)
    : this._internal(
        (ref) => tourDetail(ref as TourDetailRef, tourId),
        from: tourDetailProvider,
        name: r'tourDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tourDetailHash,
        dependencies: TourDetailFamily._dependencies,
        allTransitiveDependencies: TourDetailFamily._allTransitiveDependencies,
        tourId: tourId,
      );

  TourDetailProvider._internal(
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
    Stream<TourModel> Function(TourDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TourDetailProvider._internal(
        (ref) => create(ref as TourDetailRef),
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
  AutoDisposeStreamProviderElement<TourModel> createElement() {
    return _TourDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TourDetailProvider && other.tourId == tourId;
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
mixin TourDetailRef on AutoDisposeStreamProviderRef<TourModel> {
  /// The parameter `tourId` of this provider.
  String get tourId;
}

class _TourDetailProviderElement
    extends AutoDisposeStreamProviderElement<TourModel>
    with TourDetailRef {
  _TourDetailProviderElement(super.provider);

  @override
  String get tourId => (origin as TourDetailProvider).tourId;
}

String _$tourControllerHash() => r'6f9abc4efd129d4774cbc1ceb71495e80a61b4dd';

/// See also [TourController].
@ProviderFor(TourController)
final tourControllerProvider = NotifierProvider<TourController, void>.internal(
  TourController.new,
  name: r'tourControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tourControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TourController = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
