# KOMPASS — Technical Requirements Document (TRD)

## 1. Introduction
**Purpose:** This Technical Requirements Document (TRD) outlines the architectural, technical, and algorithmic specifications for KOMPASS, an intelligent tour coordination and management mobile application.
**Scope:** The document covers the end-to-end system across its three-phase development lifecycle.
**Intended Audience:** Software developers, system architects, QA engineers, and project stakeholders.
**Conventions:** Code blocks are used for schema definitions and text diagrams. Notes and warnings use GitHub-style alerts.

## 2. System Overview
KOMPASS addresses the fragmentation of tour management tools by integrating communication, location tracking, digital attendance, and AI-driven insights into a single platform. The development is structured in three phases:
- **Phase 1 (Core Platform):** Foundational tour management, user authentication, basic messaging, QR attendance, and basic GPS tracking.
- **Phase 2 (Advanced & Offline):** Custom hybrid geofencing (circular & polygonal), BitChat-inspired offline Bluetooth mesh communication, and WebRTC group voice.
- **Phase 3 (AI & Predictions):** Predictive models for crowd density, dynamic ETA, lost participant trajectories, multilingual AI assistance, and health/weather risk alerts.

## 3. Technology Stack

| Component | Technology | Phases |
|-----------|------------|--------|
| Frontend | Flutter, Dart | 1, 2, 3 |
| Backend Core | Firebase (Auth, Firestore, Storage, Cloud Messaging) | 1, 2, 3 |
| Server-Side Logic | Firebase Cloud Functions | 3 |
| Maps & Location | OpenStreetMap, flutter_map, Geolocator | 1, 2, 3 |
| Routing (Optional) | Mapbox / Google Maps API | 3 |
| Voice Communication| WebRTC, STUN/TURN, Firestore Signaling | 2 |
| Offline Network | Bluetooth Low Energy (BLE) Mesh | 2 |
| Local Storage | Hive | 1, 2, 3 |
| State Management | Riverpod | 1, 2, 3 |
| AI / ML (On-Device) | TensorFlow Lite, DistilBERT | 3 |
| AI / ML (Cloud) | Gemini API, LSTM / STGCN | 3 |
| External APIs | OpenWeatherMap | 3 |
| Version Control | Git & GitHub | 1, 2, 3 |

## 4. System Architecture

### 4.1 High-Level Architecture
```text
                    KOMPASS Mobile App
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
   Firebase Auth     Cloud Firestore   Firebase Storage
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
                Firebase Cloud Messaging
                            │
                   Alerts & Notifications

       ┌──────────────┐     ┌─────────────────┐
       │  Mobile App  │────►│ WebRTC Signaling│
       └──────────────┘     └────────┬────────┘
                                     │
                                     ▼
                              STUN / TURN
                                Server
                                     │
                                     ▼
                           Voice Communication

       ┌──────────────┐
       │ GPS Location │
       └───────┬──────┘
               │
               ▼
       ┌────────────────┐
       │ OpenStreetMap  │
       └───────┬────────┘
               │
               ▼
       ┌─────────────────────────┐
       │ Hybrid Geofencing Engine│
       │       [Phase 2]         │
       └───────────┬─────────────┘
                   ▼
          Haversine + Ray Casting
                   │
                   ▼
       ┌──────────────────────────────┐
       │ Offline Bluetooth Mesh       │
       │           [Phase 2]          │
       └──────────────────────────────┘

       ┌──────────────────────────────────────────────┐
       │          AI & Prediction Layer [Phase 3]      │
       │  ┌─────────────┐  ┌───────────────────────┐  │
       │  │ Crowd Density│  │ Dynamic ETA & Routing │  │
       │  └──────┬───────┘  └───────────┬───────────┘  │
       │  ┌──────┴───────┐  ┌──────────┴────────────┐ │
       │  │ Lost Partici-│  │ Health & Weather Risk  │ │
       │  │ pant Traject-│  │ Prediction             │ │
       │  └──────────────┘  └───────────────────────┘  │
       │  ┌──────────────────────────────────────────┐ │
       │  │  Multilingual AI Assistant & Chatbot     │ │
       │  └──────────────────────────────────────────┘ │
       │  ┌──────────────────────────────────────────┐ │
       │  │  TFLite On-Device  │  Cloud Functions    │ │
       │  └──────────────────────────────────────────┘ │
       └──────────────────────────────────────────────┘
```

### 4.2 Client Architecture (Flutter App)
The client follows a layered architecture to separate concerns:
- **Presentation Layer:** Flutter UI widgets and screens.
- **Business Logic Layer:** Riverpod providers managing state and use-case execution.
- **Data Layer:** Repositories abstracting data sources (Firestore, Hive, REST APIs).
- **Services Layer:** Background services (Geolocator, BLE scanning, WebRTC signaling).
```text
[ UI Widgets ] <--> [ Riverpod Providers ] <--> [ Repositories ] <--> [ Data Sources / Services ]
```

### 4.3 Backend Architecture (Firebase)
- **Cloud Firestore:** NoSQL database for real-time synchronization. Uses subcollections for tour-specific data (e.g., `Tours/{tourId}/Messages`).
- **Security Rules:** Enforce RBAC (Role-Based Access Control) ensuring guides and participants can only access data relevant to their assigned tours.
- **Cloud Functions:** Server-side logic for scheduled tasks, AI inference routing (Phase 3), and complex aggregations.

### 4.4 Communication Architecture
- **Firebase Cloud Messaging:** Push notifications for offline or backgrounded clients.
- **WebRTC Signaling:** Firestore acts as the signaling server for SDP offer/answer exchange and ICE candidates.
- **STUN/TURN:** Traverses NAT to establish direct peer-to-peer voice connections, with TURN as a relay fallback.
- **Bluetooth Mesh:** A custom multi-hop BLE topology where nodes (smartphones) relay messages using a store-and-forward mechanism.

### 4.5 AI/ML Architecture (Phase 3)
- **On-Device (TFLite):** Lightweight models (DistilBERT) for offline intent classification and trajectory prediction. Reduces latency and preserves battery.
- **Cloud Inference (Functions + Gemini):** Heavy models (LSTM/STGCN) for crowd prediction and complex conversational AI.
- **Pipeline:** Historical data trained offline (Python/TensorFlow) -> Model converted to TFLite -> Deployed via app updates or Firebase ML.

## 5. Data Model

### 5.1 Cloud Firestore Collections

**Users**
```json
{
  "userId": "String",
  "name": "String",
  "email": "String",
  "role": "String (Admin, Guide, Participant)",
  "profileImage": "String (URL)",
  "createdAt": "Timestamp"
}
```

**Tours**
```json
{
  "tourId": "String",
  "name": "String",
  "description": "String",
  "startDate": "Timestamp",
  "endDate": "Timestamp",
  "guideId": "String (Ref -> Users)",
  "status": "String",
  "createdAt": "Timestamp"
}
```

**Participants**
```json
{
  "tourId": "String (Ref)",
  "userId": "String (Ref)",
  "role": "String",
  "status": "String",
  "joinedAt": "Timestamp"
}
```

**Attendance**
```json
{
  "attendanceId": "String",
  "tourId": "String",
  "userId": "String",
  "timestamp": "Timestamp",
  "location": "GeoPoint",
  "method": "String (QR, Manual)",
  "status": "String"
}
```

**Messages**
```json
{
  "messageId": "String",
  "tourId": "String",
  "senderId": "String",
  "message": "String",
  "timestamp": "Timestamp"
}
```

**Locations**
```json
{
  "locationId": "String",
  "tourId": "String",
  "userId": "String",
  "latitude": "Number",
  "longitude": "Number",
  "timestamp": "Timestamp"
}
```

**Announcements**
```json
{
  "announcementId": "String",
  "tourId": "String",
  "title": "String",
  "message": "String",
  "createdBy": "String",
  "timestamp": "Timestamp"
}
```

**Geofences** (Phase 2)
```json
{
  "geofenceId": "String",
  "tourId": "String",
  "type": "String (Circular, Polygon)",
  "center": "GeoPoint (optional)",
  "radius": "Number (optional)",
  "polygon": "Array<GeoPoint> (optional)",
  "status": "String"
}
```

**Phase 3 Collections**
- **CrowdPredictions:** `tourId`, `locationId`, `predictedDensity` (Number), `timestamp`
- **WeatherAlerts:** `tourId`, `riskLevel` (String), `description` (String), `timestamp`
- **ChatbotSessions:** `userId`, `history` (Array<Map>), `lastInteraction` (Timestamp)
- **ETAPredictions:** `tourId`, `destinationId`, `estimatedArrival` (Timestamp)

> [!TIP]
> Use composite indexes for querying `Locations` by `tourId` and sorting by `timestamp` for real-time map updates.

### 5.2 Local Storage (Hive)
Hive is used for fast, synchronous, key-value local storage:
- **Offline Caching:** Tour itineraries, downloaded maps, and basic user profiles.
- **Mesh Message Queue:** Pending messages intended for Bluetooth relay when internet is unavailable.

### 5.3 Data Flow Diagrams

**Location Sharing & Geofence Checking**
```text
[Device GPS] -> [Geolocator Service] -> [Local Geofence Engine]
                                           |
                                      (Exit detected?)
                                           |--> Yes --> [Consecutive Validation] -> [Firestore & FCM Alert to Guide]
                                           |
                                           |--> No  --> [Sync to Firestore `Locations` Collection]
```

**Mesh Message Relay**
```text
[Sender Device] -> (Internet Down?) -> Yes -> [Save to Hive Queue] -> [Broadcast via BLE] 
                                                                           |
                                                    [Nearby Device B Receives BLE Packet]
                                                                           |
                                          (Is B the recipient?) --> Yes --> [Show Message]
                                                                --> No  --> [Forward via BLE (TTL-1)]
```

## 6. Module Specifications

### Phase 1 Modules
1. **Authentication:** User registration/login via Firebase Auth.
2. **User Management:** Profile and role management.
3. **Tour Management:** Tour lifecycle (create, schedule, assign).
4. **Itinerary:** Manages schedule, checkpoints, and meeting points.
5. **Attendance:** QR-code and manual scanning, synced to Firestore.
6. **Communication:** Basic messaging via Firestore real-time listeners.
7. **Location Tracking:** Periodic GPS updates; map rendering.
8. **Notification:** Integrates FCM for push alerts.
9. **Emergency:** Basic SOS triggering and guide notification.
10. **Reports:** Export attendance and tour logs.

### Phase 2 Modules
11. **Hybrid Geofencing:** Client-side evaluation using Haversine/Ray Casting.
12. **Advanced Communication:** Group chat, history sync.
13. **WebRTC Voice:** SDP signaling and peer-to-peer audio.
14. **Offline Mesh:** BLE discovery, message packetization, routing.
15. **Offline Sync:** Syncs Hive queue with Firestore upon reconnection.
16. **Advanced Safety:** Boundary exit alerts and advanced SOS.
17. **Advanced Reports:** Analytics on mesh reliability and geofence accuracy.

### Phase 3 Modules
18. **Crowd Density Prediction:** Predicts crowding using historical data and STGCN models.
19. **Dynamic ETA:** Integrates Mapbox/OSM APIs for traffic-aware travel times.
20. **Lost Participant Prediction:** Uses Kalman filters to predict trajectory of disconnected users.
21. **AI Assistant:** Multilingual chatbot (Gemini + DistilBERT).
22. **Health & Weather Risk:** Analyzes OpenWeatherMap data against itinerary exertion levels.

## 7. Algorithm Specifications

### 7.1 Haversine Distance Algorithm
**Purpose:** Calculate great-circle distance for circular geofencing.
```javascript
// Pseudocode
function haversine(lat1, lon1, lat2, lon2) {
    R = 6371e3; // Earth radius in meters
    φ1 = lat1 * Math.PI/180;
    φ2 = lat2 * Math.PI/180;
    Δφ = (lat2-lat1) * Math.PI/180;
    Δλ = (lon2-lon1) * Math.PI/180;

    a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
        Math.cos(φ1) * Math.cos(φ2) *
        Math.sin(Δλ/2) * Math.sin(Δλ/2);
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c; // Distance in meters
}
```

### 7.2 Ray Casting Point-in-Polygon Algorithm
**Purpose:** Check if a GPS coordinate is inside an irregular polygon.
```javascript
// Pseudocode
function isPointInPolygon(point, polygon) {
    let isInside = false;
    let j = polygon.length - 1;
    for (let i = 0; i < polygon.length; i++) {
        if ((polygon[i].lat > point.lat) != (polygon[j].lat > point.lat) &&
            point.lon < (polygon[j].lon - polygon[i].lon) * (point.lat - polygon[i].lat) / (polygon[j].lat - polygon[i].lat) + polygon[i].lon) {
            isInside = !isInside;
        }
        j = i;
    }
    return isInside;
}
```

### 7.3 Bounding Box Pre-filtering
**Logic:** Before running Ray Casting, check if the point is within the min/max lat/lon bounds of the polygon.

### 7.4 Consecutive Exit Validation
**Logic:** Maintain a state machine. If device leaves geofence, increment `exitCounter`. If it re-enters, reset to 0. Only trigger alert if `exitCounter >= 3` (based on polling rate).

### 7.5 Bluetooth Mesh Routing
**Logic:** 
- Each message has a unique `msgId`.
- Nodes keep a cache of recently seen `msgId`s to drop duplicates.
- Packet format: `[msgId, senderId, targetId, TTL, payload]`.
- TTL decrements on each hop. Store-and-forward until TTL=0 or internet restored.

### 7.6 Kalman Filter (Lost Participant Prediction)
**Concept:** Estimates state (position, velocity) recursively.
- **State variables:** `[x, y, vx, vy]` (latitude, longitude, velocity lat, velocity lon).
- **Prediction step:** Extrapolate next position based on last known velocity and heading.

### 7.7 LSTM / STGCN (Crowd Density Prediction)
**Concept:** Time-series and spatial relationships of past tours.
- Training: Python/TensorFlow.
- Input: Historic tour times, dates, public holidays, weather.
- Output: Density score (0.0 to 1.0).

## 8. API Specifications

### 8.1 Firebase Cloud Functions
- `predictCrowdDensity(tourId, locationId)`: Returns JSON with predicted density.
- `triggerWeatherAlert(tourId)`: Scheduled function checking external APIs.

### 8.2 External API Integrations
- **OpenStreetMap:** Static maps and basic routing.
- **OpenWeatherMap:** `GET /data/2.5/weather?lat={lat}&lon={lon}`
- **Gemini API:** `POST /v1/models/gemini-pro:generateContent` for AI Chatbot.

### 8.3 Internal Service Interfaces
```dart
abstract class LocationRepository {
  Stream<Position> getLocationStream();
  Future<void> updateLocation(String userId, GeoPoint point);
}

abstract class MeshService {
  Future<void> startAdvertising();
  Future<void> startScanning();
  Future<void> sendMessage(MeshPacket packet);
}
```

## 9. Security Architecture

### 9.1 Authentication & Authorization
Uses Firebase Auth JWTs. RBAC is enforced both on client UI (hiding tabs) and server-side (Security Rules).

### 9.2 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Tours/{tourId} {
      allow read: if request.auth != null && (resource.data.guideId == request.auth.uid || request.auth.uid in get(/databases/$(database)/documents/Participants/$(tourId)).data.users);
      allow write: if request.auth != null && resource.data.guideId == request.auth.uid;
    }
  }
}
```

### 9.3 Data Privacy
- Explicit consent screen for location tracking.
- Location data retained only for active tours; archived/purged post-tour.

### 9.4 Bluetooth Mesh Security
- AES-256 encryption on mesh payloads.
- Secret key exchanged during tour join via secure internet connection, used for offline BLE decryption.

## 10. Performance Requirements
- **App Launch:** < 3 seconds.
- **Location Polling:** Adaptive (e.g., 5s when moving, 60s when stationary) to minimize battery drain.
- **Firestore Latency:** < 200ms read/write.
- **WebRTC Setup:** < 3 seconds to establish P2P.
- **BLE Mesh Latency:** Target < 2s per hop.
- **TFLite Inference:** < 50ms on modern devices.
- **Concurrent Users:** Capacity to scale via Firestore sharding.

## 11. Testing Strategy

### 11.1 Unit Testing
- Algorithms: Haversine, Ray Casting boundary conditions.
- State: Riverpod providers and logic flows.

### 11.2 Integration Testing
- Firebase Auth flows.
- WebRTC signaling exchange.

### 11.3 Performance Testing
- Battery consumption profiling using Android Profiler / iOS Instruments during background GPS and BLE scanning.

### 11.4 Field Testing
- Physical walks to test geofence triggers and GPS drift.
- BLE mesh range testing in outdoor environments.

### 11.5 AI Model Testing
- Backtesting crowd density model against historical Hajj/tourism dataset.

## 12. Deployment Architecture
- **CI/CD:** GitHub Actions to run Flutter tests and build APK/IPA.
- **Distribution:** Firebase App Distribution for Beta; Google Play / App Store for production.
- **Environments:** Dev, Staging, Prod Firebase projects.

## 13. Scalability Considerations
- **Firestore:** Use subcollections to prevent large document reads.
- **WebRTC:** For large group voice (Phase 2), a transition from pure P2P mesh to an SFU (Selective Forwarding Unit) may be required.
- **Functions:** Set appropriate auto-scaling limits for AI API calls to manage costs.

## 14. Glossary
- **BLE:** Bluetooth Low Energy.
- **Geofencing:** A virtual geographic boundary.
- **Haversine:** Formula for distance on a sphere.
- **Ray Casting:** Algorithm to determine point inside a polygon.
- **SFU:** Selective Forwarding Unit (WebRTC).
- **STUN/TURN:** Protocols for NAT traversal in WebRTC.
- **TFLite:** TensorFlow Lite (mobile ML framework).
