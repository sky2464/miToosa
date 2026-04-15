// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GameplayViewModel)
final gameplayViewModelProvider = GameplayViewModelFamily._();

final class GameplayViewModelProvider
    extends $NotifierProvider<GameplayViewModel, GameplayState> {
  GameplayViewModelProvider._(
      {required GameplayViewModelFamily super.from,
      required GameplayLevel super.argument})
      : super(
          retry: null,
          name: r'gameplayViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gameplayViewModelHash();

  @override
  String toString() {
    return r'gameplayViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameplayViewModel create() => GameplayViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameplayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameplayState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GameplayViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameplayViewModelHash() => r'743dc79ac32339d5887c09f59c4f4aa58b4a5bc5';

final class GameplayViewModelFamily extends $Family
    with
        $ClassFamilyOverride<GameplayViewModel, GameplayState, GameplayState,
            GameplayState, GameplayLevel> {
  GameplayViewModelFamily._()
      : super(
          retry: null,
          name: r'gameplayViewModelProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GameplayViewModelProvider call(
    GameplayLevel level,
  ) =>
      GameplayViewModelProvider._(argument: level, from: this);

  @override
  String toString() => r'gameplayViewModelProvider';
}

abstract class _$GameplayViewModel extends $Notifier<GameplayState> {
  late final _$args = ref.$arg as GameplayLevel;
  GameplayLevel get level => _$args;

  GameplayState build(
    GameplayLevel level,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GameplayState, GameplayState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<GameplayState, GameplayState>,
        GameplayState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
