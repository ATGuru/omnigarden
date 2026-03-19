// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gardensHash() => r'27096dbf0326a2bbc551a8f8568b33b0f87d0e5b';

/// See also [gardens].
@ProviderFor(gardens)
final gardensProvider = AutoDisposeFutureProvider<List<Garden>>.internal(
  gardens,
  name: r'gardensProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gardensHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GardensRef = AutoDisposeFutureProviderRef<List<Garden>>;
String _$journalEntriesHash() => r'4ef74fda3b3d720abcd34bc1454a6bc639b928a6';

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

/// See also [journalEntries].
@ProviderFor(journalEntries)
const journalEntriesProvider = JournalEntriesFamily();

/// See also [journalEntries].
class JournalEntriesFamily extends Family<AsyncValue<List<JournalEntry>>> {
  /// See also [journalEntries].
  const JournalEntriesFamily();

  /// See also [journalEntries].
  JournalEntriesProvider call(
    String gardenId,
  ) {
    return JournalEntriesProvider(
      gardenId,
    );
  }

  @override
  JournalEntriesProvider getProviderOverride(
    covariant JournalEntriesProvider provider,
  ) {
    return call(
      provider.gardenId,
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
  String? get name => r'journalEntriesProvider';
}

/// See also [journalEntries].
class JournalEntriesProvider
    extends AutoDisposeFutureProvider<List<JournalEntry>> {
  /// See also [journalEntries].
  JournalEntriesProvider(
    String gardenId,
  ) : this._internal(
          (ref) => journalEntries(
            ref as JournalEntriesRef,
            gardenId,
          ),
          from: journalEntriesProvider,
          name: r'journalEntriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$journalEntriesHash,
          dependencies: JournalEntriesFamily._dependencies,
          allTransitiveDependencies:
              JournalEntriesFamily._allTransitiveDependencies,
          gardenId: gardenId,
        );

  JournalEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gardenId,
  }) : super.internal();

  final String gardenId;

  @override
  Override overrideWith(
    FutureOr<List<JournalEntry>> Function(JournalEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JournalEntriesProvider._internal(
        (ref) => create(ref as JournalEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gardenId: gardenId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<JournalEntry>> createElement() {
    return _JournalEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JournalEntriesProvider && other.gardenId == gardenId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gardenId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin JournalEntriesRef on AutoDisposeFutureProviderRef<List<JournalEntry>> {
  /// The parameter `gardenId` of this provider.
  String get gardenId;
}

class _JournalEntriesProviderElement
    extends AutoDisposeFutureProviderElement<List<JournalEntry>>
    with JournalEntriesRef {
  _JournalEntriesProviderElement(super.provider);

  @override
  String get gardenId => (origin as JournalEntriesProvider).gardenId;
}

String _$gardenPlantIdsHash() => r'a1475991d9653ee202c47f553882d7cc7d5aae75';

/// See also [gardenPlantIds].
@ProviderFor(gardenPlantIds)
const gardenPlantIdsProvider = GardenPlantIdsFamily();

/// See also [gardenPlantIds].
class GardenPlantIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [gardenPlantIds].
  const GardenPlantIdsFamily();

  /// See also [gardenPlantIds].
  GardenPlantIdsProvider call(
    String gardenId,
  ) {
    return GardenPlantIdsProvider(
      gardenId,
    );
  }

  @override
  GardenPlantIdsProvider getProviderOverride(
    covariant GardenPlantIdsProvider provider,
  ) {
    return call(
      provider.gardenId,
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
  String? get name => r'gardenPlantIdsProvider';
}

/// See also [gardenPlantIds].
class GardenPlantIdsProvider extends AutoDisposeFutureProvider<List<String>> {
  /// See also [gardenPlantIds].
  GardenPlantIdsProvider(
    String gardenId,
  ) : this._internal(
          (ref) => gardenPlantIds(
            ref as GardenPlantIdsRef,
            gardenId,
          ),
          from: gardenPlantIdsProvider,
          name: r'gardenPlantIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gardenPlantIdsHash,
          dependencies: GardenPlantIdsFamily._dependencies,
          allTransitiveDependencies:
              GardenPlantIdsFamily._allTransitiveDependencies,
          gardenId: gardenId,
        );

  GardenPlantIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gardenId,
  }) : super.internal();

  final String gardenId;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(GardenPlantIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GardenPlantIdsProvider._internal(
        (ref) => create(ref as GardenPlantIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gardenId: gardenId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _GardenPlantIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GardenPlantIdsProvider && other.gardenId == gardenId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gardenId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GardenPlantIdsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `gardenId` of this provider.
  String get gardenId;
}

class _GardenPlantIdsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with GardenPlantIdsRef {
  _GardenPlantIdsProviderElement(super.provider);

  @override
  String get gardenId => (origin as GardenPlantIdsProvider).gardenId;
}

String _$gardenNotifierHash() => r'ad46d3cd501a68d7f7cd66991e6204c8b25fc4b7';

/// See also [GardenNotifier].
@ProviderFor(GardenNotifier)
final gardenNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GardenNotifier, List<Garden>>.internal(
  GardenNotifier.new,
  name: r'gardenNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gardenNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GardenNotifier = AutoDisposeAsyncNotifier<List<Garden>>;
String _$journalNotifierHash() => r'8930a4ae938139cc31da4b940388f8131a9a9508';

abstract class _$JournalNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<JournalEntry>> {
  late final String gardenId;

  FutureOr<List<JournalEntry>> build(
    String gardenId,
  );
}

/// See also [JournalNotifier].
@ProviderFor(JournalNotifier)
const journalNotifierProvider = JournalNotifierFamily();

/// See also [JournalNotifier].
class JournalNotifierFamily extends Family<AsyncValue<List<JournalEntry>>> {
  /// See also [JournalNotifier].
  const JournalNotifierFamily();

  /// See also [JournalNotifier].
  JournalNotifierProvider call(
    String gardenId,
  ) {
    return JournalNotifierProvider(
      gardenId,
    );
  }

  @override
  JournalNotifierProvider getProviderOverride(
    covariant JournalNotifierProvider provider,
  ) {
    return call(
      provider.gardenId,
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
  String? get name => r'journalNotifierProvider';
}

/// See also [JournalNotifier].
class JournalNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    JournalNotifier, List<JournalEntry>> {
  /// See also [JournalNotifier].
  JournalNotifierProvider(
    String gardenId,
  ) : this._internal(
          () => JournalNotifier()..gardenId = gardenId,
          from: journalNotifierProvider,
          name: r'journalNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$journalNotifierHash,
          dependencies: JournalNotifierFamily._dependencies,
          allTransitiveDependencies:
              JournalNotifierFamily._allTransitiveDependencies,
          gardenId: gardenId,
        );

  JournalNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gardenId,
  }) : super.internal();

  final String gardenId;

  @override
  FutureOr<List<JournalEntry>> runNotifierBuild(
    covariant JournalNotifier notifier,
  ) {
    return notifier.build(
      gardenId,
    );
  }

  @override
  Override overrideWith(JournalNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: JournalNotifierProvider._internal(
        () => create()..gardenId = gardenId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gardenId: gardenId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<JournalNotifier, List<JournalEntry>>
      createElement() {
    return _JournalNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JournalNotifierProvider && other.gardenId == gardenId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gardenId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin JournalNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<JournalEntry>> {
  /// The parameter `gardenId` of this provider.
  String get gardenId;
}

class _JournalNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<JournalNotifier,
        List<JournalEntry>> with JournalNotifierRef {
  _JournalNotifierProviderElement(super.provider);

  @override
  String get gardenId => (origin as JournalNotifierProvider).gardenId;
}

String _$gardenPlantNotifierHash() =>
    r'9c212b0c609d1a39ab1200ab6e790bcfb7cd16c6';

abstract class _$GardenPlantNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<String>> {
  late final String gardenId;

  FutureOr<List<String>> build(
    String gardenId,
  );
}

/// See also [GardenPlantNotifier].
@ProviderFor(GardenPlantNotifier)
const gardenPlantNotifierProvider = GardenPlantNotifierFamily();

/// See also [GardenPlantNotifier].
class GardenPlantNotifierFamily extends Family<AsyncValue<List<String>>> {
  /// See also [GardenPlantNotifier].
  const GardenPlantNotifierFamily();

  /// See also [GardenPlantNotifier].
  GardenPlantNotifierProvider call(
    String gardenId,
  ) {
    return GardenPlantNotifierProvider(
      gardenId,
    );
  }

  @override
  GardenPlantNotifierProvider getProviderOverride(
    covariant GardenPlantNotifierProvider provider,
  ) {
    return call(
      provider.gardenId,
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
  String? get name => r'gardenPlantNotifierProvider';
}

/// See also [GardenPlantNotifier].
class GardenPlantNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    GardenPlantNotifier, List<String>> {
  /// See also [GardenPlantNotifier].
  GardenPlantNotifierProvider(
    String gardenId,
  ) : this._internal(
          () => GardenPlantNotifier()..gardenId = gardenId,
          from: gardenPlantNotifierProvider,
          name: r'gardenPlantNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gardenPlantNotifierHash,
          dependencies: GardenPlantNotifierFamily._dependencies,
          allTransitiveDependencies:
              GardenPlantNotifierFamily._allTransitiveDependencies,
          gardenId: gardenId,
        );

  GardenPlantNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gardenId,
  }) : super.internal();

  final String gardenId;

  @override
  FutureOr<List<String>> runNotifierBuild(
    covariant GardenPlantNotifier notifier,
  ) {
    return notifier.build(
      gardenId,
    );
  }

  @override
  Override overrideWith(GardenPlantNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GardenPlantNotifierProvider._internal(
        () => create()..gardenId = gardenId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gardenId: gardenId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GardenPlantNotifier, List<String>>
      createElement() {
    return _GardenPlantNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GardenPlantNotifierProvider && other.gardenId == gardenId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gardenId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GardenPlantNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<String>> {
  /// The parameter `gardenId` of this provider.
  String get gardenId;
}

class _GardenPlantNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GardenPlantNotifier,
        List<String>> with GardenPlantNotifierRef {
  _GardenPlantNotifierProviderElement(super.provider);

  @override
  String get gardenId => (origin as GardenPlantNotifierProvider).gardenId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
