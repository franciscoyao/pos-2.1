// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(menuRepository)
final menuRepositoryProvider = MenuRepositoryProvider._();

final class MenuRepositoryProvider
    extends $FunctionalProvider<MenuRepository, MenuRepository, MenuRepository>
    with $Provider<MenuRepository> {
  MenuRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'menuRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$menuRepositoryHash();

  @$internal
  @override
  $ProviderElement<MenuRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MenuRepository create(Ref ref) {
    return menuRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MenuRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MenuRepository>(value),
    );
  }
}

String _$menuRepositoryHash() => r'67f3da1c8c643f050a2b714c58cb837768becc07';
