// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tableRepository)
final tableRepositoryProvider = TableRepositoryProvider._();

final class TableRepositoryProvider
    extends
        $FunctionalProvider<TableRepository, TableRepository, TableRepository>
    with $Provider<TableRepository> {
  TableRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableRepositoryHash();

  @$internal
  @override
  $ProviderElement<TableRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TableRepository create(Ref ref) {
    return tableRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TableRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TableRepository>(value),
    );
  }
}

String _$tableRepositoryHash() => r'1aadedaee87755a58501b124a95fd1cab6db830a';
