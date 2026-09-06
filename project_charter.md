# KOMPASS — Project Charter

## 1. Project Title
**KOMPASS: Intelligent Tour Coordination and Management Mobile Application**

## 2. Project Sponsor & Authorization
This is a **Final-Year Academic Project**. The project is authorized by the academic institution as a capstone/final-year project spanning Phase 1 (Mini Project) and Phase 2 (Main Project), with Phase 3 introduced as an extended research component.

## 3. Project Purpose & Justification
Managing organized tours using multiple applications and manual processes results in fragmented workflows, communication delays, and inefficient coordination. Existing solutions lack unified capabilities specifically designed for tour groups, making it difficult to track attendees, communicate offline, and respond to emergencies. 

KOMPASS aims to solve this by providing a centralized, intelligent mobile platform for tour management, offline mesh communication, advanced geofencing, and safety. Furthermore, motivated by academic research such as the IEEE paper on smart mobile features for Hajj, Phase 3 introduces advanced predictive AI and smart assistance. This will proactively address challenges like crowd congestion and lost participants, elevating both safety and participant autonomy.

## 4. Project Objectives
1. Develop a centralized platform for tour coordination and management.
2. Implement role-based access for administrators, guides, and participants.
3. Digitally manage tour participants and attendance.
4. Provide itinerary and meeting-point management.
5. Enable consent-based participant location sharing.
6. Provide map-based visualization of participant locations.
7. Implement real-time messaging and announcements.
8. Provide push notifications for important tour events.
9. Implement in-app voice communication using WebRTC.
10. Provide emergency SOS support.
11. Develop a custom hybrid geofencing engine in Phase 2.
12. Implement offline Bluetooth mesh communication in Phase 2.
13. Reduce manual coordination efforts for tour organizers.
14. Improve safety and communication during organized tours.
15. Extend the system toward a scalable, production-ready application.
16. Integrate AI models to achieve high crowd density prediction accuracy (RMSE < threshold).
17. Implement a multilingual AI assistant with >85% F1 intent recognition accuracy.
18. Provide dynamic routing and predictive safety/health alerts based on real-time environmental data.

## 5. High-Level Scope

### 5.1 In Scope
- **Phase 1:** Core tour management (CRUD operations), role-based access, basic itinerary setup, QR and manual attendance, basic messaging, GPS location sharing, map visualization, and basic SOS.
- **Phase 2:** Custom hybrid geofencing (Haversine + Ray Casting algorithms), BitChat-inspired offline Bluetooth mesh communication, WebRTC voice communication (1-to-1 and group), offline data synchronization, and advanced SOS features.
- **Phase 3:** Crowd density prediction, dynamic ETA/routing, lost participant trajectory prediction, multilingual AI assistant (Gemini/DistilBERT), and health & weather risk alerts.

### 5.2 Out of Scope
The following items are explicitly out of scope for this project:
- Payment/financial transactions
- Hotel/flight booking integration
- Video calling (listed as future enhancement)
- Wearable device integration (listed as future enhancement)
- Expense management
- iOS-specific features (Flutter targets Android primarily for this academic project)
- Production-scale deployment (this is an academic prototype, though Phase 2 aims for production-readiness)

## 6. Key Deliverables

### Phase 1 Deliverables
- Functional KOMPASS mobile app (Flutter/Android)
- Firebase backend with Authentication, Firestore, Storage, FCM
- Core modules: Auth, Tour Management, Itinerary, Attendance (QR + Manual), Basic Messaging, Announcements, GPS Location Sharing, Map Visualization, Basic SOS
- Phase 1 Documentation (SRS, design documents)
- Mini Project Demonstration

### Phase 2 Deliverables
- Custom Hybrid Geofencing Engine (Haversine + Ray Casting)
- BitChat-inspired Offline Bluetooth Mesh Communication
- WebRTC Voice Communication (1-to-1 and Group)
- Advanced Safety Features (geofence alerts, enhanced SOS)
- Offline Synchronization
- Security Hardening
- Phase 2 Documentation and Testing Reports
- Full Project Demonstration

### Phase 3 Deliverables
- Crowd Density Prediction Module (LSTM/STGCN)
- Dynamic ETA & Predictive Routing Module
- Lost Participant Trajectory Prediction Module (Kalman Filter/MDP)
- Multilingual AI Assistant (Gemini API + on-device DistilBERT)
- Health & Weather Risk Alert Module
- AI Model Training & Evaluation Reports
- Phase 3 Documentation

## 7. Key Milestones

| Milestone | Target Date | Phase | Description |
|-----------|-------------|-------|-------------|
| Project Kickoff | Month 1 | Phase 1 | Initial planning, requirements gathering, and environment setup |
| Phase 1 Requirements Complete | Month 1 | Phase 1 | Finalization of SRS and architecture design |
| Phase 1 UI/UX Design Complete | Month 2 | Phase 1 | Wireframes and high-fidelity mockups approved |
| Phase 1 Core Backend Ready | Month 2 | Phase 1 | Firebase structured and integrated with app |
| Phase 1 Feature Complete | Month 3 | Phase 1 | All core CRUD, messaging, and basic map features integrated |
| Phase 1 Testing & Demo | Month 4 | Phase 1 | Mini Project Demonstration |
| Phase 2 Geofencing Engine Complete | Month 6 | Phase 2 | Custom hybrid geofencing algorithms active |
| Phase 2 Bluetooth Mesh Prototype | Month 7 | Phase 2 | Basic offline P2P message relay working |
| Phase 2 WebRTC Integration | Month 8 | Phase 2 | Group and 1-to-1 voice calling active |
| Phase 2 Integration Testing | Month 9 | Phase 2 | Offline sync and end-to-end testing complete |
| Phase 2 Field Testing & Demo | Month 10 | Phase 2 | Main Project Demonstration |
| Phase 3 AI Model Training Complete | Month 11 | Phase 3 | Predictive models trained and validated |
| Phase 3 On-Device Integration | Month 12 | Phase 3 | TFLite models and LLM APIs integrated into mobile client |
| Phase 3 UAT & Final Demo | Month 13 | Phase 3 | UAT testing and final extended research demonstration |

## 8. Project Team & Roles

| Roll No. | Name | Primary Role | Responsibilities |
|----------|------|--------------|------------------|
| 502319 | Aswin | Project Lead & Backend Developer | • Oversee project schedule and milestones<br>• Setup Firebase backend architecture<br>• Develop cloud functions and core logic |
| 502326 | Jefrin | Frontend Developer & UI/UX Designer | • Design intuitive UI/UX for all user roles<br>• Implement Flutter screens and state management<br>• Ensure high-contrast, accessible design |
| 502337 | Mohamed Feroz | Communication & Geofencing Engineer | • Implement Haversine/Ray Casting algorithms<br>• Develop Bluetooth mesh protocol<br>• Integrate WebRTC for voice calls |
| 502361 | Barnabas Mathew Vaz | AI/ML & Integration Engineer | • Train predictive AI models (LSTM/STGCN)<br>• Integrate Gemini API and on-device NLP<br>• Implement mapping and routing APIs |

> [!NOTE]
> The **Academic Supervisor/Mentor** serves as an external stakeholder offering guidance and evaluation throughout all phases.

## 9. Stakeholders

| Stakeholder | Role | Interest | Influence | Communication Needs |
|-------------|------|----------|-----------|--------------------|
| Development Team | Builders | High | High | Daily standups, weekly reviews |
| Academic Supervisor | Mentor/Evaluator | High | High | Bi-weekly progress reports |
| External Evaluators | Assessors | Medium | High | Phase demo presentations |
| End Users (Guides) | Primary users | High | Medium | UAT feedback sessions |
| End Users (Participants) | Primary users | High | Low | Beta testing feedback |

## 10. Assumptions
1. Team members have basic Flutter/Dart knowledge for mobile app development.
2. Firebase free tier is sufficient for development, testing, and initial deployment.
3. Smartphones with BLE 4.0+ are readily available for mesh networking tests.
4. Internet connectivity is available for cloud-based feature development and sync.
5. The academic timeline accommodates the extended three-phase development cycle.
6. OpenStreetMap data is accessible and adequate for the target tour locations.
7. Gemini API free tier provides sufficient quota for Phase 3 chatbot development.
8. Test participants are available for field tests and User Acceptance Testing (UAT).

## 11. Constraints
1. Fixed team size of exactly 4 members.
2. Adherence to a strict academic semester timeline.
3. Project budget is limited strictly to free-tier cloud services and APIs.
4. Flutter and Dart are the mandated technology framework for the mobile application.
5. Bluetooth Low Energy (BLE) range limitations restrict mesh nodes to ~30-100 meters.
6. GPS accuracy varies significantly by environment (e.g., urban canyons).
7. On-device ML model sizes must remain under 50MB to ensure reasonable app download sizes.

## 12. Risks (High-Level)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Excessive Battery Drain | High | High | Implement adaptive GPS polling; pause tracking when stationary; optimize BLE scanning. |
| Inaccurate GPS Tracking | High | Medium | Use bounding box filtering and consecutive validation before triggering geofence alerts. |
| Low Bluetooth Mesh Density | Medium | Medium | Ensure strategic guide positioning; use store-and-forward fallback to cellular when available. |
| API Cost Overruns (Phase 3)| Medium | Low | Utilize free tiers, cache AI responses aggressively, and use on-device models for common requests. |
| Project Schedule Delays | High | Medium | Maintain strict adherence to milestone schedules; employ scope reduction as a fallback plan. |

## 13. Communication Plan

| Communication Type | Frequency | Audience | Medium |
|-------------------|-----------|----------|--------|
| Daily Standup | Daily | Team | In-person / WhatsApp |
| Sprint Review | Bi-weekly | Team + Supervisor | Presentation |
| Progress Report | Monthly | Supervisor | Document |
| Phase Demo | Per Phase | Evaluators | Live Demo |
| Code Review | Per PR | Team | GitHub |

## 14. Success Criteria

> [!IMPORTANT]
> The success of each phase determines the authorization to proceed to the next phase in the academic evaluation cycle.

- **Phase 1:** All core modules functional without fatal errors, successful end-to-end demo with a test tour.
- **Phase 2:** Geofence accuracy >95%, offline mesh message delivery >90% within range, successful field testing in a localized zone.
- **Phase 3:** AI prediction accuracy targets met (crowd RMSE < threshold), AI chatbot intent recognition >85% F1 score, highly positive UAT feedback.

## 15. Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Lead | | | |
| Academic Supervisor | | | |
| Department Head | | | |
