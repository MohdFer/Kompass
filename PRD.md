# KOMPASS — Product Requirements Document (PRD)

## 1. Executive Summary
KOMPASS is an intelligent mobile application designed to simplify the planning, coordination, communication, attendance management, and safety monitoring of organized tour groups. Managing organized tours often relies on fragmented tools—using different apps for messaging, navigation, attendance, and location sharing. This fragmentation leads to communication delays, difficulty tracking participants, and delayed emergency responses. KOMPASS solves this by integrating essential tour management functionalities into a single, centralized platform. 
The development is structured in three phases:
- **Phase 1:** Core Tour Management (Authentication, role-based access, basic itinerary, and attendance).
- **Phase 2:** Advanced Geofencing & Offline Communication (Hybrid geofencing, BitChat-inspired offline Bluetooth mesh, and WebRTC voice).
- **Phase 3:** AI-Driven Predictive Models & Smart Assistance (Predictive crowd density, dynamic routing, lost participant prediction, multilingual AI assistant, and health/weather alerts based on IEEE Hajj paper concepts).

## 2. Product Vision & Goals
**Vision:** To be the most reliable, comprehensive, and intelligent platform for group tour coordination, ensuring safety and seamless communication regardless of geographical or network constraints.
**Mission:** To empower tour organizers, guides, and participants with a unified mobile application that provides real-time location intelligence, resilient offline communication, and AI-driven predictive insights.
**Measurable Goals:**
- Reduce manual attendance tracking time by 80%.
- Ensure 95% message delivery success rate even in offline environments using Bluetooth mesh.
- Achieve sub-10 second geofence breach alerting.
- Decrease guide workload on repetitive participant queries by 50% using AI assistants.

## 3. Target Users & Personas

### Administrator
**Persona:** Alex, a Tour Operations Manager at a medium-sized travel agency.
**Goals:** Efficiently create tours, assign guides, monitor ongoing trips, and access post-tour analytics.
**Pain Points:** Lacks visibility into active tours, struggles to coordinate multiple guides, and spends too much time on manual reporting.
**How KOMPASS Helps:** Provides a centralized dashboard to oversee all tours, manage roles, and review digital attendance reports seamlessly.

### Tour Guide / Coordinator
**Persona:** Sarah, a veteran Tour Guide specializing in European history tours.
**Goals:** Keep the group together, communicate schedule changes instantly, and ensure everyone's safety.
**Pain Points:** Constantly counting heads manually, losing participants in crowded areas, and repeating the same answers to different people.
**How KOMPASS Helps:** Automates attendance via QR, alerts her when someone leaves a geofenced area, and allows one-to-many announcements.

### Participant
**Persona:** David, an elderly tourist on a religious pilgrimage.
**Goals:** Enjoy the tour without getting lost, easily find meeting points, and request help if needed.
**Pain Points:** Bad sense of direction, language barriers, and fear of getting disconnected from the group without cellular service.
**How KOMPASS Helps:** Shows live directions to meeting points, translates questions via AI, and enables SOS and offline messaging.

### Target Application Domains
Educational tours, religious pilgrimages (e.g., Hajj, Umrah), corporate retreats, school field trips, and multi-day holiday packages.

## 4. User Stories

### Administrator
**Phase 1**
- As an Administrator, I want to create and edit tours so that I can schedule upcoming trips.
- As an Administrator, I want to assign Tour Guides to specific tours so that they have access to manage the group.
- As an Administrator, I want to upload travel documents so that guides and participants can access them.
- As an Administrator, I want to view digital attendance logs so that I can verify participation.
- As an Administrator, I want to register users and assign roles so that access is securely controlled.
- As an Administrator, I want to manage tour statuses (active, completed) so that the system is organized.
- As an Administrator, I want to view reports on tour completion so that I can analyze performance.
- As an Administrator, I want to revoke user access so that I can maintain security after a tour ends.

**Phase 2**
- As an Administrator, I want to define default polygonal geofences for standard attractions so that guides can easily apply them.
- As an Administrator, I want to review geofence breach logs so that I can audit safety incidents.
- As an Administrator, I want to configure offline sync intervals so that app performance is optimized.

**Phase 3**
- As an Administrator, I want to view historical crowd density reports so that I can better plan future itineraries.
- As an Administrator, I want to access AI-generated risk assessment logs so that I can ensure compliance with safety standards.

### Tour Guide
**Phase 1**
- As a Tour Guide, I want to scan participant QR codes so that I can quickly record attendance.
- As a Tour Guide, I want to broadcast announcements so that all participants are informed of schedule changes.
- As a Tour Guide, I want to view participant locations on a map so that I know where everyone is.
- As a Tour Guide, I want to set a meeting point on the itinerary so that participants know where to gather.
- As a Tour Guide, I want to receive SOS alerts so that I can respond to emergencies immediately.
- As a Tour Guide, I want to manually mark attendance for participants whose phones are dead so that records are accurate.
- As a Tour Guide, I want to access the daily itinerary so that I can keep the tour on track.
- As a Tour Guide, I want to send direct messages to a participant so that I can address individual concerns.

**Phase 2**
- As a Tour Guide, I want to set a circular geofence around the hotel so that I know if anyone wanders off at night.
- As a Tour Guide, I want to receive push notifications when a participant exits a geofence so that I can intervene.
- As a Tour Guide, I want to use group voice calling so that I can give guided commentary without shouting.
- As a Tour Guide, I want to send offline messages so that I can reach participants in areas with no cellular network.
- As a Tour Guide, I want to initiate a head-count check over the mesh network so that I can verify presence offline.

**Phase 3**
- As a Tour Guide, I want to receive predictive crowd density alerts so that I can dynamically change the route to avoid congestion.
- As a Tour Guide, I want to see the predicted trajectory of a lost participant so that I can locate them faster.
- As a Tour Guide, I want to receive health and weather risk alerts so that I can remind the group to stay hydrated.

### Participant
**Phase 1**
- As a Participant, I want to log in securely so that my personal data is protected.
- As a Participant, I want to view the itinerary so that I know the schedule for the day.
- As a Participant, I want to display my QR code so that the guide can mark me present.
- As a Participant, I want to share my location with the guide so that they can find me if I get lost.
- As a Participant, I want to trigger an SOS button so that I can get immediate help in an emergency.
- As a Participant, I want to view the meeting point on a map so that I can navigate there.
- As a Participant, I want to access shared travel tickets so that I don't need to carry paper copies.
- As a Participant, I want to message the guide directly so that I can ask questions privately.

**Phase 2**
- As a Participant, I want my app to automatically relay messages via Bluetooth so that the group stays connected offline.
- As a Participant, I want to receive offline announcements so that I don't miss important updates in dead zones.
- As a Participant, I want to join a group voice call so that I can hear the guide's instructions clearly.
- As a Participant, I want to be notified if I accidentally leave the geofenced area so that I can return to safety.

**Phase 3**
- As a Participant, I want to see a dynamic ETA to the next location so that I know how long the walk will take.
- As a Participant, I want to ask the AI assistant questions in my native language so that I can get quick answers without bothering the guide.
- As a Participant, I want to receive proactive warnings about extreme weather conditions so that I can prepare accordingly.

## 5. Feature Requirements — Phase 1: Core Tour Management

| ID | Feature | Description | Priority | Acceptance Criteria |
|---|---|---|---|---|
| P1-AUTH-01 | User Registration & Login | Secure login via Firebase Auth supporting email/password. | Must Have | User can register, login, logout, and reset password. |
| P1-ROLE-01 | Role-Based Access | Differentiates UI and capabilities for Admin, Guide, and Participant. | Must Have | Admin can create tours; Guide sees guide dashboard; Participant sees itinerary. |
| P1-TOUR-01 | Tour Creation & Management | Admins can create tours with start/end dates, descriptions, and assign guides/participants. | Must Have | Tour is created in Firestore and visible to assigned users. |
| P1-ITIN-01 | Itinerary Management | Create daily schedules with activities, times, and meeting points. | Must Have | Guides and participants can view a chronological list of events. |
| P1-ATT-01 | QR Code Attendance | Dynamic QR code generation for participants, scannable by guides. | Must Have | Guide scans QR, attendance record created in Firestore with timestamp. |
| P1-MSG-01 | Basic Messaging | One-to-one and group chat functionality. | Must Have | Messages are sent and received in real-time using Firestore. |
| P1-MSG-02 | Broadcast Announcements | One-way messaging from Admin/Guide to all tour participants. | Must Have | Push notification is triggered via FCM for all participants. |
| P1-LOC-01 | GPS Location Sharing | Participants can toggle consent-based location sharing. | Must Have | Guide map updates with participant markers accurately. |
| P1-EMR-01 | Emergency SOS | A panic button that alerts the guide immediately with location. | Must Have | SOS triggers loud notification on guide's phone with exact GPS coords. |
| P1-MED-01 | Document Sharing | Upload and retrieve tickets and travel documents. | Should Have | PDFs/Images can be uploaded to Firebase Storage and viewed in-app. |

## 6. Feature Requirements — Phase 2: Advanced Geofencing & Offline Communication

| ID | Feature | Description | Priority | Acceptance Criteria |
|---|---|---|---|---|
| P2-GEO-01 | Circular Geofencing | Define circular safe zones using Haversine algorithm. | Must Have | System calculates distance from center; alerts if radius exceeded. |
| P2-GEO-02 | Polygonal Geofencing | Define complex boundaries using Ray Casting algorithm. | Must Have | System detects if participant GPS point is outside the polygon. |
| P2-GEO-03 | Geofencing Optimizations | Bounding box filtering, consecutive exit validation, adaptive polling. | Should Have | False alerts reduced; battery consumption minimized during tracking. |
| P2-MESH-01 | Offline Bluetooth Mesh | BitChat-inspired peer-to-peer BLE message relay. | Must Have | Message successfully routes from Participant A to Guide via Participant B without internet. |
| P2-MESH-02 | Store-and-Forward | Queue messages when offline and sync when online/connected. | Must Have | Messages sent while offline are delivered once a connection is re-established. |
| P2-VOI-01 | WebRTC Voice Calls | 1-to-1 and group voice communication over IP. | Must Have | Audio is clear; STUN/TURN servers facilitate connection across NAT. |
| P2-SYNC-01 | Offline Synchronization | Local data caching (Hive) syncing with Firestore upon reconnection. | Must Have | App works offline (reads cached data) and syncs changes seamlessly. |

## 7. Feature Requirements — Phase 3: AI-Driven Predictive Models & Smart Assistance

> [!TIP]
> Phase 3 features are inspired by the IEEE Hajj paper, emphasizing predictive capabilities to prevent issues before they occur.

| ID | Feature | Description | Priority | Acceptance Criteria |
|---|---|---|---|---|
| P3-AI-01 | Predictive Crowd Density | Forecasts congestion at landmarks using historical/live data. | Should Have | Guide receives an alert if destination density exceeds threshold prior to arrival. |
| P3-AI-02 | Dynamic ETA & Routing | Predicts travel time and optimizes routes based on traffic/weather. | Must Have | Itinerary updates ETA dynamically; map shows optimized route. |
| P3-AI-03 | Lost Participant Trajectory | Predicts path of a lost participant based on last velocity/heading. | Must Have | Map displays a projected search cone/path when geofence is breached. |
| P3-AI-04 | Multilingual AI Assistant | NLP chatbot (Gemini API) for participant queries with offline fallback. | Must Have | User asks a question in Spanish, bot answers correctly based on tour context. |
| P3-AI-05 | Predictive Health & Weather | Cross-references weather and itinerary to alert about health risks. | Should Have | Push notification sent to hydrate if temperature > 35°C and activity involves walking. |

## 8. Non-Functional Requirements
- **Performance:** UI rendering must be 60fps (Flutter). Firestore queries should return in < 500ms.
- **Reliability & Availability:** Cloud services rely on Firebase (99.9% uptime). Offline mesh provides fallback availability.
- **Scalability:** System must support up to 500 participants per tour and 100 concurrent active tours.
- **Security & Privacy:** 
  - Strict location consent (opt-in). 
  - Data encryption in transit (TLS) and at rest (Firestore). 
  - Role-based authorization via Firestore Security Rules.
- **Usability:** High-contrast UI for outdoor visibility. Simple navigation for elderly users.
- **Accessibility:** Voice-over support and dynamic text sizing.
- **Battery Efficiency:** Adaptive GPS polling must prevent battery drain (limit to < 15% drain per hour of active use).
- **Offline Capability:** Core itinerary viewing, QR display, and mesh messaging must function with zero internet.

## 9. Success Metrics & KPIs
- **Phase 1:** User adoption rate, attendance tracking time (target: < 2 secs per scan), system uptime.
- **Phase 2:** Geofence alert latency (target: < 5 secs), offline message delivery rate (target: > 90%), false positive geofence alerts (target: < 5%).
- **Phase 3:** AI prediction accuracy (RMSE/MAE for crowd/ETA models), Chatbot resolution rate (target: > 70% queries resolved without guide intervention), reduction in search time for lost participants.

## 10. Constraints & Assumptions
**Constraints:**
- Bluetooth mesh range is physically limited (~10-50 meters between nodes).
- AI processing on-device must be lightweight to fit within mobile memory constraints (using TFLite).
- Cost constraints may limit the use of premium APIs (e.g., Google Maps, Gemini).

**Assumptions:**
- Participants own relatively modern smartphones with BLE and GPS capabilities.
- Guides have data plans for cloud syncing when out of the hotel.
- Participants are willing to grant location and Bluetooth permissions.

## 11. Dependencies
- **Backend:** Firebase (Auth, Firestore, Storage, Cloud Messaging).
- **Maps & Routing:** OpenStreetMap, flutter_map, Mapbox/Google Maps Directions API.
- **AI/ML:** Google Gemini API (Cloud NLP), TensorFlow Lite (On-device ML).
- **Other APIs:** OpenWeatherMap API for health/weather risk prediction.
- **Libraries:** Geolocator (GPS), WebRTC (Voice), Hive (Local DB), Riverpod (State).

## 12. Risks & Mitigations

> [!WARNING]
> Battery drain from continuous GPS and Bluetooth scanning is the highest technical risk.

| Risk | Impact | Mitigation |
|---|---|---|
| Excessive Battery Drain | High | Implement adaptive polling; pause GPS when stationary; optimize BLE scanning intervals. |
| Inaccurate GPS (Urban Canyons) | High | Use bounding box filtering and consecutive validation before triggering geofence alerts. |
| Low Bluetooth Mesh Density | Medium | Ensure guides are positioned strategically; fallback to cellular when available. |
| Privacy Concerns / Data Leak | High | Implement explicit consent UI; strict Firestore rules; auto-delete location history post-tour. |
| High API Costs (Phase 3) | Medium | Cache AI responses; use on-device DistilBERT for common queries to reduce cloud calls. |

## 13. Release Strategy
- **Phase 1 (Mini Project Prototype):** Focus on core functionality. Internal testing with small student groups. Delivery: End of semester 1.
- **Phase 2 (Production System):** Integration of Geofencing and Mesh. Beta testing in real-world environments (e.g., local campus tours). Delivery: Mid semester 2.
- **Phase 3 (AI-Enhanced System):** Rollout AI modules progressively. Start with predictive weather alerts, followed by trajectory prediction and chatbot. Final delivery: End of semester 2.

## 14. Glossary
- **BLE:** Bluetooth Low Energy, used for the offline mesh network.
- **FCM:** Firebase Cloud Messaging, used for push notifications.
- **Geofencing:** A virtual geographic boundary defined by GPS coordinates.
- **Haversine Algorithm:** A mathematical formula to calculate the distance between two points on a sphere.
- **Mesh Network:** A network topology where each node (smartphone) relays data for the network.
- **Ray Casting:** An algorithm used to determine if a point is inside a polygon.
- **WebRTC:** Web Real-Time Communication, an open framework for voice/video communication.
