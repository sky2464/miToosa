#!/usr/bin/env dart
// Simple migration helper to migrate a plaintext Hive box to an encrypted box.
// Usage: dart run tools/migrate_hive_encryption.dart [storageDir]

import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:mitoosa/data/player_progress.dart';

Future<void> main(List<String> args) async {
  final storageDir = args.isNotEmpty ? args.first : 'hive_data';
  final boxName = 'player_progress_box';

  stdout.writeln('Initializing Hive at: $storageDir');
  Directory(storageDir).createSync(recursive: true);
  Hive.init(storageDir);
  Hive.registerAdapter(PlayerProgressAdapter());

  Box? plaintextBox;
  try {
    plaintextBox = await Hive.openBox<PlayerProgress>(boxName);
  } catch (e) {
    stdout.writeln('No plaintext box found or failed to open: $e');
  }

  final entries = <String, PlayerProgress>{};
  if (plaintextBox != null && plaintextBox.isNotEmpty) {
    entries.addAll(plaintextBox.toMap().cast<String, PlayerProgress>());
    stdout.writeln('Found ${entries.length} entries in plaintext box.');
    await plaintextBox.close();
  } else {
    stdout.writeln('No entries to migrate.');
    if (plaintextBox != null && plaintextBox.isOpen) await plaintextBox.close();
  }

  // Generate an encryption key and save as base64 locally for developers.
  final key = Hive.generateSecureKey();
  final encoded = base64UrlEncode(key);
  final keyFile = File('$storageDir/hive_encryption_key_base64.txt');
  await keyFile.writeAsString(encoded);
  stdout.writeln(
    'Generated encryption key and wrote to ${keyFile.path} (dev only).',
  );

  // Delete plaintext files (if present) to allow creating encrypted box with same name.
  try {
    await Hive.deleteBoxFromDisk(boxName);
    stdout.writeln('Deleted plaintext box files.');
  } catch (e) {
    stdout.writeln('Failed to delete plaintext box files: $e');
  }

  // Open encrypted box and write migrated entries
  final encryptionKey = base64Url.decode(encoded);
  final encBox = await Hive.openBox<PlayerProgress>(
    boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  if (entries.isNotEmpty) {
    await encBox.putAll(entries);
    stdout.writeln('Migrated ${entries.length} entries into encrypted box.');
  }

  await encBox.close();
  stdout.writeln(
    'Migration complete. Please remove $storageDir/hive_encryption_key_base64.txt from developer machines and store keys securely.',
  );
}
