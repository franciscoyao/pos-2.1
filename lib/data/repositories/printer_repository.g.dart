// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(printerRepository)
final printerRepositoryProvider = PrinterRepositoryProvider._();

final class PrinterRepositoryProvider
    extends
        $FunctionalProvider<
          PrinterRepository,
          PrinterRepository,
          PrinterRepository
        >
    with $Provider<PrinterRepository> {
  PrinterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printerRepositoryHash();

  @$internal
  @override
  $ProviderElement<PrinterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrinterRepository create(Ref ref) {
    return printerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrinterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrinterRepository>(value),
    );
  }
}

String _$printerRepositoryHash() => r'07487a4f44c68ed8edf7a48a8267f2c980ce39b0';
