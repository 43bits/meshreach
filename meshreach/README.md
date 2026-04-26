# MeshReach

**Team: Hashbrownie**

> *When the internet goes down, the most vulnerable shouldn't be the most silent.*

![MeshReach Overview](\lib\assets\Flow.png)

---

## 🔗 Offline Mesh Communication — Built for All

MeshReach is a fully offline, peer-to-peer mesh communication app for Android. It requires **no internet, no cell towers, no SIM card, and no servers**. Devices communicate directly using WiFi Direct and Bluetooth, creating a resilient mesh network where every phone becomes a relay node.

Built for **accessibility and disaster resilience**, MeshReach specifically addresses the needs of individuals with physical, sensory, or cognitive disabilities — the people who are most vulnerable when infrastructure fails.

---

## 📋 Table of Contents

- [Problem Statement](#problem-statement)
- [System Flowchart](#system-flowchart)
- [Tech Stack](#tech-stack)
- [Accessibility Features](#accessibility-features)
- [Screens](#screens)
- [Team](#team)

---

## ❌ Problem Statement

| Problem | MeshReach Solution |
|---|---|
| ❌ Internet fails in disasters | ✅ Works fully offline |
| ❌ Cell towers go down | ✅ Device-to-device via WiFi Direct |
| ❌ Deaf users can't use voice SOS | ✅ Sign language SOS clip relay |
| ❌ Disabled users need simpler interfaces | ✅ Adaptive accessibility profiles |
| ❌ Standard apps need connectivity | ✅ No infrastructure required |

---

## 🔄 System Flowchart

```
App Launch → Permissions → MeshManager (Advertising + Discovery)
                                        ↓
                    BLE Peer Discovery → WiFi Direct Connection Request
                                        ↓
                    Connection Accepted → Peer Added to Mesh
                                        ↓
                                   USER ACTIONS

Send:  Text → Encrypt → Broadcast → Relay → Store → ACK
SOS:   SOS  → Get GPS → Encrypt  → Broadcast → Alert
```

Each message is assigned a **UUID + TTL**, encrypted with AES-256-GCM, flood-broadcast across all peers, relayed (TTL-1) until TTL=0 or duplicate UUID is detected, and stored in SQLite with an ACK confirmation sent back to the sender.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **UI** | Flutter + FlutterFlow Designer (Nothing OS aesthetic) |
| **Networking** | `nearby_connections` (WiFi Direct + BLE) |
| **Security** | AES-256-GCM + PBKDF2-HMAC-SHA256 (`encrypt` package) |
| **Database** | Raw SQLite — 3 tables: `messages`, `peers`, `ack` |
| **Map** | MapLibre GL — offline vector maps with live peer dots |
| **Location** | Geolocator — GPS coordinates for map + SOS |
| **State** | ChangeNotifier + StreamController for real-time UI |
| **Architecture** | MVVM — Services → MeshManager → Screens |

---

## ♿ Accessibility Features

MeshReach was designed starting from the disabled user's failure point — not as an afterthought:

- **Haptic SOS Mode** — 3 taps trigger SOS, no screen interaction needed (deafblind users)
- **Sign Language SOS Clip** — 5-second video compressed and relayed across mesh
- **AI Message Simplifier** — Gemini simplifies complex messages to Grade 3 reading level
- **Adaptive UI Profiles** — Motor-impaired, Low Vision, and Cognitive modes
- **Caregiver Relay Protocol** — Passive safety ping when elderly user enters mesh range
- **High Contrast Nothing OS UI** — Minimal cognitive load, DM Mono monospace font

---

## 📱 Screens

| Screen | Description |
|---|---|
| **Status & Peer List** | Live list of discovered mesh nodes with signal strength and connection status |
| **Chat Screen** | Encrypted P2P messaging with support for text, voice, location, and file bubbles |
| **Mesh Map Screen** | Full-screen offline MapLibre map with live peer location dots |
| **SOS Screen & Overlay** | One-tap emergency broadcast with full-screen alert overlay across all mesh nodes |

---

## 👤 Team

**Solo Developer — Chandrakant**
Advanced Flutter/Android Developer passionate about building offline-first, accessible technology for real-world impact.

---

## 📄 License

This project is open source. See [LICENSE](./LICENSE) for details.