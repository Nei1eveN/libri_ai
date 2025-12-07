// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trendingBooksHash() => r'9be46f1df4547c791f716adc022037e04131c8ce';

/// See also [trendingBooks].
@ProviderFor(trendingBooks)
final trendingBooksProvider = AutoDisposeFutureProvider<List<Book>>.internal(
  trendingBooks,
  name: r'trendingBooksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TrendingBooksRef = AutoDisposeFutureProviderRef<List<Book>>;
String _$savedBooksStreamHash() => r'be60a166360afdd58d765b0d6271a18c6a64d841';

/// See also [savedBooksStream].
@ProviderFor(savedBooksStream)
final savedBooksStreamProvider = AutoDisposeStreamProvider<List<Book>>.internal(
  savedBooksStream,
  name: r'savedBooksStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedBooksStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavedBooksStreamRef = AutoDisposeStreamProviderRef<List<Book>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
