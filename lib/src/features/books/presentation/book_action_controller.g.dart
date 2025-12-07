// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookActionControllerHash() =>
    r'3b04a26dcd9c404b35976f53a37a6e27a4312617';

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

abstract class _$BookActionController
    extends BuildlessAutoDisposeAsyncNotifier<bool> {
  late final Book book;

  FutureOr<bool> build(
    Book book,
  );
}

/// See also [BookActionController].
@ProviderFor(BookActionController)
const bookActionControllerProvider = BookActionControllerFamily();

/// See also [BookActionController].
class BookActionControllerFamily extends Family<AsyncValue<bool>> {
  /// See also [BookActionController].
  const BookActionControllerFamily();

  /// See also [BookActionController].
  BookActionControllerProvider call(
    Book book,
  ) {
    return BookActionControllerProvider(
      book,
    );
  }

  @override
  BookActionControllerProvider getProviderOverride(
    covariant BookActionControllerProvider provider,
  ) {
    return call(
      provider.book,
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
  String? get name => r'bookActionControllerProvider';
}

/// See also [BookActionController].
class BookActionControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<BookActionController, bool> {
  /// See also [BookActionController].
  BookActionControllerProvider(
    Book book,
  ) : this._internal(
          () => BookActionController()..book = book,
          from: bookActionControllerProvider,
          name: r'bookActionControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookActionControllerHash,
          dependencies: BookActionControllerFamily._dependencies,
          allTransitiveDependencies:
              BookActionControllerFamily._allTransitiveDependencies,
          book: book,
        );

  BookActionControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.book,
  }) : super.internal();

  final Book book;

  @override
  FutureOr<bool> runNotifierBuild(
    covariant BookActionController notifier,
  ) {
    return notifier.build(
      book,
    );
  }

  @override
  Override overrideWith(BookActionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookActionControllerProvider._internal(
        () => create()..book = book,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        book: book,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<BookActionController, bool>
      createElement() {
    return _BookActionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookActionControllerProvider && other.book == book;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, book.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookActionControllerRef on AutoDisposeAsyncNotifierProviderRef<bool> {
  /// The parameter `book` of this provider.
  Book get book;
}

class _BookActionControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BookActionController, bool>
    with BookActionControllerRef {
  _BookActionControllerProviderElement(super.provider);

  @override
  Book get book => (origin as BookActionControllerProvider).book;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
