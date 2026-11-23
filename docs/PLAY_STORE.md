# Play Store submission

The listing publishes both form factors from one package, `fi.nikosavola.wearforankidroid`: the
phone companion and the Wear OS app. Both bundles must carry the same upload key. This is the
order Play Console asks for things, with the answers for this app.

## Before creating the app

- Build the signed bundles and back up the upload key, as described in [RELEASING.md](RELEASING.md).
- Register the package name and the upload key's SHA-256 fingerprint for Android developer
  verification. The current upload key fingerprint is
  `04:92:A7:BE:3B:C1:21:1B:60:5C:D0:0F:19:DD:FC:6D:F2:84:D4:71:9A:72:09:9F:91:23:9B:DD:B4:DB:63:03`.
- Confirm the privacy policy is live at
  <https://nikosavola.github.io/Wear-for-AnkiDroid/privacy.html>.

## Create the app and upload

1. Play Console: Create app. Name `Wear for AnkiDroid`, default language English (United States),
   type App, free. Accept the developer program policies and US export declarations.
2. Set the package name `fi.nikosavola.wearforankidroid`.
3. Under Form factors, add Wear OS. Phone is already present.
4. Create a release on the Internal testing track and upload both bundles. The phone bundle has
   version code 20 and the wear bundle 21. Opt in to Play App Signing when prompted.
5. Fill the store listing and app content from the sections below, then promote the release.

## Store listing

| Field | Source |
| --- | --- |
| App name | `fastlane/metadata/android/en-US/title.txt` |
| Short description | `fastlane/metadata/android/en-US/short_description.txt` |
| Full description | `fastlane/metadata/android/en-US/full_description.txt` |
| App icon, 512 x 512 | `fastlane/metadata/android/en-US/images/icon.png` |
| Feature graphic, 1024 x 500 | `fastlane/metadata/android/en-US/images/featureGraphic.png` |
| Wear screenshots | `fastlane/metadata/android/en-US/images/wearScreenshots/` |
| Phone screenshots | `fastlane/metadata/android/en-US/images/phoneScreenshots/` |

Play requires at least two screenshots per form factor. The Wear ones are square, which Play asks
for on watches. The phone ones are 1080 x 2160 JPEGs, regenerated with
`scripts/capture-phone-screenshots.sh` on a Pixel 7 emulator. Play caps screenshots at a 2:1 aspect
ratio and wants 24-bit images with no alpha channel.

## App content answers

- Category: Education. Tags: flashcards, study, languages.
- Privacy policy: the GitHub Pages URL above.
- Ads: No.
- In-app purchases: No.
- App access: no login and no paywall. The app needs the free AnkiDroid app, so give reviewers
  instructions: install AnkiDroid, complete its first-run setup, import the demo deck from
  <https://nikosavola.github.io/Wear-for-AnkiDroid/demo/wear-for-ankidroid-demo.apkg>, open Wear for
  AnkiDroid, grant the database permission, and tap Sync.
- Target audience: 13 and older. Flashcards are suitable for all ages, but selecting children
  would put the app under the Families policy for no benefit.
- Data safety: no data collected and no data shared. The app declares no `INTERNET` permission.
  Cards and grades move only between the user's phone and watch through the Wear OS Data Layer,
  which is device to device and never reaches a server. There are no accounts, analytics or ads.
- Content rating: Utility, Productivity, Communication or Other. Answer No to violence, sexuality,
  language, controlled substances, gambling, user-generated content, ads and purchases. Expect an
  Everyone or PEGI 3 rating.
- Government app, financial features, health features, news app: No.
- Data deletion: not applicable, since there are no accounts. Clearing app storage or uninstalling
  removes buffered cards and grades; the privacy policy spells this out.

## Review notes

- The watch app is not standalone. It needs the phone companion on the paired phone and AnkiDroid
  2.24 or newer with a collection.
- Both apps read AnkiDroid through its public `ContentProvider` with the
  `com.ichi2.anki.permission.READ_WRITE_DATABASE` permission. The manifest declares no network
  permission.
- Every screen is dark. The watch app has a tile, a complication and, on Wear OS 7, a home-screen
  widget, so reviewers can check those surfaces without a phone.
- The description and the in-app About dialog both state that the app is unofficial and not
  affiliated with Anki Software, LLC or the AnkiDroid Open Source Team.

## After the first upload

Play notifies the account once the bundles pass the pre-publish checks. Reviews for a Wear OS app
check the watch build on a paired device, so the internal testing track should include a watch
tester. A production release needs the store listing, app content and data safety forms complete on
every form factor.
