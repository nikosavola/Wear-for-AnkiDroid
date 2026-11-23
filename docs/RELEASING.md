# Releasing

Two things can ship from this repository: the `ankidroid-provider` library and the two app APKs.

## Provider library

`.github/workflows/publish.yml` publishes `fi.nikosavola:ankidroid-provider` to this repository's
GitHub Packages registry on any `v*` tag. It runs the library's unit tests before publishing, and
takes the artifact version from the tag without the leading `v`.

1. Tag the commit and push the tag:

   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

2. `publish.yml` publishes `fi.nikosavola:ankidroid-provider:X.Y.Z`.

3. GitHub Packages never allows an existing version to be overwritten. If a publish fails halfway,
   delete that version from the package page, then either re-push a new tag or run the workflow
   manually with the `version` input set to the same tag.

4. The same tag builds on [JitPack](https://jitpack.io) on demand, without a token, now that the
   repository is public. The README's dependency snippet shows the coordinates.

No `v*` tag has been pushed yet, so the version in the README is still the next one to cut.

## App bundles

Both apps ship in one Play listing with two form factors, share the application id, and are signed
with one upload key. The key is local-only: `wearforankidroid-upload.jks` at the repository root,
with its passwords in `keystore.properties`. `.gitignore` excludes both. `signingConfigs` in each
module reads that file when it exists and leaves release builds unsigned otherwise, which is why CI
still builds unsigned APKs as an R8 check.

1. Generate the key once, if it does not exist yet:

   ```bash
   keytool -genkeypair -keystore wearforankidroid-upload.jks -alias wearforankidroid \
     -keyalg RSA -keysize 4096 -validity 10000
   ```

2. Write `keystore.properties`:

   ```properties
   storeFile=wearforankidroid-upload.jks
   storePassword=<password>
   keyAlias=wearforankidroid
   keyPassword=<password>
   ```

3. Back up the keystore and its password somewhere outside this machine. Play App Signing lets you
   reset a lost upload key, but the backup saves the support round-trip.

4. Build and sign both bundles:

   ```bash
   ./gradlew :phone:bundleRelease :wear:bundleRelease
   ```

   Outputs are `phone/build/outputs/bundle/release/phone-release.aab` and
   `wear/build/outputs/bundle/release/wear-release.aab`.

5. Check that both bundles carry the same certificate, which Play requires for one listing:

   ```bash
   keytool -printcert -jarfile phone/build/outputs/bundle/release/phone-release.aab | grep SHA256
   keytool -printcert -jarfile wear/build/outputs/bundle/release/wear-release.aab | grep SHA256
   ```

6. Upload both bundles to the same Play release, and opt in to Play App Signing on the first upload.
   The upload key's SHA-256 fingerprint is needed for Android developer verification as well as
   Play App Signing. Registering the application id and fingerprint does not require a public
   listing.

There is no GitHub release workflow for the apps yet. One would decode the keystore from repository
secrets, run the two bundle tasks, verify the certificates match, and attach the bundles plus the R8
`mapping.txt` files to a GitHub Release.


## Version numbers

- Application id: `fi.nikosavola.wearforankidroid`, shared by both apps.
- `versionCode` is `release * 10 + form factor`, where the phone is 0 and the watch is 1. Bump the
  release number in both build files at the same time.
- `versionName` is an independent literal in each app module. Bump both by hand.
- A release workflow should fail the tag push if either `versionName` does not match the tag.
