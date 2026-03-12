// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$plantSearchResultsHash() =>
    r'd7e2775cfd1293697dbfedee4842656cbd50f97a';

/// See also [plantSearchResults].
@ProviderFor(plantSearchResults)
final plantSearchResultsProvider =
    AutoDisposeFutureProvider<List<Plant>>.internal(
  plantSearchResults,
  name: r'plantSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PlantSearchResultsRef = AutoDisposeFutureProviderRef<List<Plant>>;
String _$plantHash() => r'45f02767a11b74fe7c594f7ddb96133d34a2ebe2';

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

/// See also [plant].
@ProviderFor(plant)
const plantProvider = PlantFamily();

/// See also [plant].
class PlantFamily extends Family<AsyncValue<Plant>> {
  /// See also [plant].
  const PlantFamily();

  /// See also [plant].
  PlantProvider call(
    String id,
  ) {
    return PlantProvider(
      id,
    );
  }

  @override
  PlantProvider getProviderOverride(
    covariant PlantProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'plantProvider';
}

/// See also [plant].
class PlantProvider extends AutoDisposeFutureProvider<Plant> {
  /// See also [plant].
  PlantProvider(
    String id,
  ) : this._internal(
          (ref) => plant(
            ref as PlantRef,
            id,
          ),
          from: plantProvider,
          name: r'plantProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$plantHash,
          dependencies: PlantFamily._dependencies,
          allTransitiveDependencies: PlantFamily._allTransitiveDependencies,
          id: id,
        );

  PlantProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Plant> Function(PlantRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlantProvider._internal(
        (ref) => create(ref as PlantRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Plant> createElement() {
    return _PlantProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlantProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PlantRef on AutoDisposeFutureProviderRef<Plant> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PlantProviderElement extends AutoDisposeFutureProviderElement<Plant>
    with PlantRef {
  _PlantProviderElement(super.provider);

  @override
  String get id => (origin as PlantProvider).id;
}

String _$featuredPlantsHash() => r'd56bdb2bde111cf8660f170e58533760e508613a';

/// See also [featuredPlants].
@ProviderFor(featuredPlants)
final featuredPlantsProvider = AutoDisposeFutureProvider<List<Plant>>.internal(
  featuredPlants,
  name: r'featuredPlantsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredPlantsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FeaturedPlantsRef = AutoDisposeFutureProviderRef<List<Plant>>;
String _$plantSearchQueryHash() => r'30fd590361159b631a87b0f11ad27aeaaff4d0b6';

/// See also [PlantSearchQuery].
@ProviderFor(PlantSearchQuery)
final plantSearchQueryProvider =
    AutoDisposeNotifierProvider<PlantSearchQuery, String>.internal(
  PlantSearchQuery.new,
  name: r'plantSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlantSearchQuery = AutoDisposeNotifier<String>;
String _$recentSearchesHash() => r'f77778ef0ef91a4b5a72f1813db14984d8aa8de7';

/// See also [RecentSearches].
@ProviderFor(RecentSearches)
final recentSearchesProvider =
    AutoDisposeNotifierProvider<RecentSearches, List<String>>.internal(
  RecentSearches.new,
  name: r'recentSearchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentSearchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecentSearches = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
