# The Game Consent App by Hawke Robinson

- Author: Hawke Robinson "The Grandfather of Therapeutic [Role-Playing] Gaming" (<https://hawkerobinson.com>)
- Official website: <www.gameconsent.com>
- Version 0.1.x
- Package variants:
  - Basic Free version: com.gameconsent.basic
  - Standard version: com.gameconsent.standard
  - Pro version: com.gameconsent.pro
  - Enterprise version: com.gameconsent.enterprise

The Game Consent App is a tool for players, facilitators, and game masters to receive pre-session, real-time during sessions, and post-session feedback from their players. While other functionality is available, the primary purpose of The Game Consent App is to allow players to inform the Game Master (GM) (or other facilitator types) about their comfort level during a game session, in real-time.

In the basic free version of this app, the default rating system is a simple green-yellow-red "traffic light" notification. In more advanced versions of the app, other scales are available.

This tool is useful for all ages and gaming use cases. While capable of supporting a wide range of circumstances, this app evolved because it is especially useful for more "risky" or "mature" games that deal with "challenging" topics, where you want to be considerate of people's sensitivities so that the facilitator/GM can adapt rapidly to the players' current comfort level, as needed, helping improve the game "safety" as much as possible for the participants.

It is highly recommended that all facilitators list, in advance, all of the potential issues that may come up in the game, for example, detailed gore, torture, etc., so that prospective players can make an informed decision about whether they wish to join the game or not.

- The Main Official Game Consent App Website is [https://www.gameconsent.com](https://www.gameconsent.com)
- The Policies page is [https://www.gameconsent.com/disclaimers/policies](https://www.gameconsent.com/disclaimers/policies)
- Contact, Issues, & Support page is [https://www.gameconsent.com/support](https://www.gameconsent.com/support)
- The project's Github repository is here: [https://github.com/RPG-Research/gameconsent](https://github.com/RPG-Research/gameconsent)

The app indicator screen is in the shape of a traffic light, default selection is green, other options are yellow and green. Each "light" is in the shape of d20 die.

There are 4 versions available (or in development) for the app.

- Free P2P $0 - Android, & iOS only. (Pure Flutter).
- Standard P2P - Android, iOS, Windows, MacOS, Linux. (Pure Flutter).
- Pro - Android, iOS, Windows, MacOS, Linux, GameConsent.app Website, various wearable devices. (Flutter + Python + PostGreSQL).
- Enterprise - Android, iOS, Windows, MacOS, Linux, GameConsent.app, various wearable device, self-hostable web server. (Flutter + Python + PostGreSQL).

## 4 Versions of the Game Consent App by hawke Robinson

All versions include:

- No ads in any of the app versions!
- We respect your privacy! No data harvesting - only exception is optionally the Pro or Enterprise versions, to enhance the added features (opt-in).
- Opt-in contact list.

### Free (P2P Bluetooth-only version) (get this into Google store ASAP to save my dev account)

- P2P Bluetooth-only based.
- Everyone has to allow Bluetooth connection to each other.
- No central server, but one person has to be the "GM" the rest all connect to.
- Pure Flutter, no centralized server.

### Core features (available in all versions)

- P2P Bluetooth - select one of 2 modes:
  - Host
  - Player - all players join the host. (is P2P the best name for this?)
- "Traffic Light" ratings: Yellow - Red - traffic light ratings.
- All Players are anonymous - GM does not know who is submitting their rating. The GM only know that someone in the group has submitted something.
- End-of-session feedback questionnaire, 2 parts - 1 for the GM/game session, the other for the app itself, with upsell opportunity
- Completely private, no data harvesting.
- No account registration.
- No game/session saving.
- Support Platforms (through Flutter/Dart):
  - Android
  - iOS

### Standard ($5 USD per account: P2P Bluetooth + Wifi/Cellular/Internet)

All Core features, plus can use Wifi/Cellular/Internet to connect P2P to each other (locally or anywhere online depending on firewalls, etc.).

- Added Wifi/Cellular/Internet support in addition to Bluetooth (Internet-based version might now always work due to firewalls, provider rules, etc.)
- Central "directory" server to find each other, but all session information is P2P (doesn't go through directory server), using unique keys no personally identifiable information, not required to register for an account (optionally available to register an account).
- Additional platform support (through Flutter/Dart):
  - Android
  - iOS
  - Linux
  - MacOS
  - Windows
- Ability for Host and Players to save game/session/settings for quick next-session resumption

### Pro ($10 USD per account = Bluetooth + Wifi + Central Server)

As per Standard, plus:

- Optional centralized data server (gameconsent.app's server, encrypted data though)
- Additional platform support:
  - Android
  - iOS
  - Linux
  - MacOS
  - Web (GameConsent's web servers, encrypted data)(no install, but requires registered/paid Pro or Enterprise account login)
  - Wearable devices (watches)
  - Windows

Enterprise Edition ($20 USD per account = Pro + Enterprise features (plus any custom development/integration costs, if requested))

- Additional platform support:
  - Access & Identity Management (AIM) integration capabilities
  - Android
  - Autoscaling infrastructure (Ansible/Terraform, Kubernetes, etc.)
  - Blockchain (optional) support
  - Brain-Computer Interface devices
  - iOS
  - Linux
  - MacOS
  - Multiple Facilitators/Game Masters, with different GM/Facilitator sub-roles (Rules GM, Narrator GM, etc.).
  - GameConsent's Centralized Web & Data Server (optional) (GameConsent's web servers, encrypted data)(no install, but requires registered/paid Pro or Enterprise account login)
  - Self-hostable Web & Data Servers (optional)
  - Wearable devices (watches)
  - Windows
  - xR (Augmented Reality (AR), Modified Reality (MR), Virtual Reality (VR), etc.)

## Developer Notes

- Currently pre-alpha 1
- Build version: 0.0.1+005251106
- Application is primarily written in Dart/Flutter
- Current Flutter version 3.32.x / Dart 3.8.x
- TODO

### Flutter Directory Structure

lib/
├── core/
│   ├── constants/
│   ├── enums/
│   ├── exceptions/
│   └── utils/
├── features/
│   ├── bluetooth_connection/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── consent_rating/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── session_feedback/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart

### Flutter/Dart Libraries

- TODO

## License(s)

- Free versions are AGPL
- Standard, Pro, and Enterprise are copyright (c) 2021-2025 W.A. Hawkes-Robinson (some of these likely will be made open source down the road).

### AGPL License

- TODO
