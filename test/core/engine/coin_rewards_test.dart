import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';
import 'package:mitoosa/data/player_progress.dart';

void main() {
  group('ProgressionEngine — computeCoinReward', () {
    test('0 stars → base 10 coins only', () {
      expect(ProgressionEngine.computeCoinReward(stars: 0, isFirstClear: false), 10);
    });

    test('3 stars → base 10 + 3×5 = 25 coins', () {
      expect(ProgressionEngine.computeCoinReward(stars: 3, isFirstClear: false), 25);
    });

    test('5 stars → base 10 + 5×5 = 35 coins', () {
      expect(ProgressionEngine.computeCoinReward(stars: 5, isFirstClear: false), 35);
    });

    test('first clear bonus adds 20 coins', () {
      expect(ProgressionEngine.computeCoinReward(stars: 5, isFirstClear: true), 55);
    });

    test('first clear with 0 stars → 10 + 0 + 20 = 30 coins', () {
      expect(ProgressionEngine.computeCoinReward(stars: 0, isFirstClear: true), 30);
    });

    test('1 star replay → 10 + 5 = 15 coins', () {
      expect(ProgressionEngine.computeCoinReward(stars: 1, isFirstClear: false), 15);
    });
  });

  group('PlayerProgress — coin operations', () {
    late PlayerProgress progress;

    setUp(() {
      progress = PlayerProgress.fresh(playerId: 'test-player');
    });

    test('fresh player starts with 0 coins', () {
      expect(progress.coins, 0);
    });

    test('addCoins increases balance', () {
      progress.addCoins(25);
      expect(progress.coins, 25);
    });

    test('addCoins accumulates', () {
      progress.addCoins(10);
      progress.addCoins(15);
      expect(progress.coins, 25);
    });

    test('addCoins rejects negative amounts', () {
      expect(() => progress.addCoins(-5), throwsA(isA<AssertionError>()));
    });

    test('spendCoins deducts from balance', () {
      progress.addCoins(50);
      final success = progress.spendCoins(20);
      expect(success, isTrue);
      expect(progress.coins, 30);
    });

    test('spendCoins fails when insufficient balance', () {
      progress.addCoins(10);
      final success = progress.spendCoins(20);
      expect(success, isFalse);
      expect(progress.coins, 10); // unchanged
    });

    test('spendCoins rejects zero and negative amounts', () {
      progress.addCoins(50);
      expect(() => progress.spendCoins(0), throwsA(isA<AssertionError>()));
      expect(() => progress.spendCoins(-5), throwsA(isA<AssertionError>()));
    });
  });

  group('CurrencyTier', () {
    test('silver tier has correct thresholds', () {
      expect(CurrencyTier.silver.displayName, 'Silver');
      expect(CurrencyTier.silver.minCoins, 0);
    });

    test('gold tier has correct thresholds', () {
      expect(CurrencyTier.gold.displayName, 'Gold');
      expect(CurrencyTier.gold.minCoins, 1000);
    });

    test('diamond tier has correct thresholds', () {
      expect(CurrencyTier.diamond.displayName, 'Diamond');
      expect(CurrencyTier.diamond.minCoins, 5000);
    });

    test('tierForCoins returns silver for 0 coins', () {
      expect(CurrencyTier.tierForCoins(0), CurrencyTier.silver);
    });

    test('tierForCoins returns silver for 999 coins', () {
      expect(CurrencyTier.tierForCoins(999), CurrencyTier.silver);
    });

    test('tierForCoins returns gold for 1000 coins', () {
      expect(CurrencyTier.tierForCoins(1000), CurrencyTier.gold);
    });

    test('tierForCoins returns gold for 4999 coins', () {
      expect(CurrencyTier.tierForCoins(4999), CurrencyTier.gold);
    });

    test('tierForCoins returns diamond for 5000 coins', () {
      expect(CurrencyTier.tierForCoins(5000), CurrencyTier.diamond);
    });

    test('tierForCoins returns diamond for very large values', () {
      expect(CurrencyTier.tierForCoins(999999), CurrencyTier.diamond);
    });
  });
}
