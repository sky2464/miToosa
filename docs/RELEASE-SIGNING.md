# Android Release Signing

This project requires a secure keystore for Android release builds. The signing configuration is loaded from `android/key.properties`, which must be excluded from source control.

## Setup

1. Copy the signing template:
   ```bash
   cp android/key.properties.template android/key.properties
   ```
2. Fill in your values:
   - `storeFile` — path to the release keystore file.
   - `storePassword` — keystore password.
   - `keyAlias` — key alias inside the keystore.
   - `keyPassword` — key password.

3. Ensure the file is ignored by Git. The `.gitignore` file now excludes `android/key.properties` and common keystore artifacts.

## Build

Use the normal Gradle release build command:

```bash
cd android
./gradlew assembleRelease
```

If the file is missing or fields are empty, the build will fail with a clear error message.

## Security

- Never commit `android/key.properties` or keystore binaries to version control.
- Store release credentials securely, such as in a secrets manager or CI secret store.
