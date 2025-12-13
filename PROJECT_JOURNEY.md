# Libri AI: Product Journey & Engineering Changelog

**Project:** Libri AI (Semantic Book Recommender)
**Engineer:** Neil Patrick Potot
**Duration:** 4-Week Sprint

---

## 📖 Executive Summary
**Libri AI** reimagines book discovery by moving beyond rigid keyword matching. While traditional apps require users to know the exact title (e.g., "Harry Potter"), Libri AI uses **Vector Embeddings** to understand the *vibe* of a request (e.g., "A nostalgic story about a boy wizard").

This document outlines the engineering decisions, architectural pivots, and user experience refinements made to build a self-learning, scalable recommendation engine.

---

## 🏗 Phase 1: Foundation & Architecture
**Goal:** Build a system that is robust enough for enterprise use but agile enough for rapid iteration.

* **Architecture Strategy: Clean Architecture**
    * *Implementation:* Codebase separated into `Data`, `Domain`, and `Presentation` layers.
    * *Product Value:* Ensures stability. We can swap the database or redesign the UI without breaking the core AI logic.
* **Tech Stack Selection**
    * **Flutter:** For pixel-perfect, cross-platform mobile rendering.
    * **Supabase (PostgreSQL + pgvector):** Chosen to keep the data and the AI vectors in a single, unified database, reducing latency and cost.
    * **Riverpod:** For predictable, testable state management.

---

## 🎨 Phase 2: The Core Experience (UI/UX)
**Goal:** Differentiate the product with a "Premium" feel that encourages exploration.

* **The "Bento Grid" Dashboard**
    * *Feature:* A dynamic, staggered grid layout showcasing "Trending," "Up Next," and "Reading Stats."
    * *Product Value:* moved away from boring list views to a modern, density-rich interface similar to Apple Music or Spotify.
* **Dynamic Island Navigation**
    * *Feature:* A floating, glass-morphism navigation bar.
    * *Product Value:* Maximizes screen real estate and provides a distinct visual identity.
* **Cinematic Detail View**
    * *Feature:* Collapsing "Sliver" headers where book covers fade and recede during scrolling.
    * *Product Value:* Creates an immersive reading experience that focuses users on the content.

---

## 🧠 Phase 3: The Intelligence (AI Integration)
**Goal:** Implement the "Vibe Match" engine securely and efficiently.

* **Semantic Vector Search**
    * *Feature:* Integrated **Google Gemini AI** to convert text into 768-dimensional vectors.
    * *Product Value:* Users can search by feeling ("sad robot space") rather than just metadata.
* **Security First: Edge Functions**
    * *Decision:* Moved all AI processing to server-side **Supabase Edge Functions**.
    * *Product Value:* Protects API keys and sensitive logic from being exposed in the mobile app.
* **Hybrid Search Strategy (The "Smart Switch")**
    * *Feature:* The app automatically detects user intent.
        * **Title Search:** Routes to Google Books API (Fast/Cheap).
        * **Vibe Search:** Routes to Vector Database (Smart/Deep).
    * *Product Value:* Optimizes costs while delivering the best results for every query type.

---

## 🔄 Phase 4: The Self-Healing Ecosystem
**Goal:** Solve the "Empty Database" problem without manual data entry.

* **Passive Ingestion (Crowdsourced Data)**
    * *Feature:* When a user searches for a specific title (e.g., "Dune") via the Google API, the system silently "learns" that book, vectorizes it, and saves it to the database in the background.
    * *Product Value:* **The system gets smarter with every use.** Early users populate the database for future users automatically.
* **Smart Deduplication**
    * *Feature:* "Idempotency Checks" prevent the system from processing the same book twice.
    * *Product Value:* Reduces AI costs by ~80% and keeps the database clean.
* **Metadata Normalization**
    * *Feature:* Automated cleaning of messy data (e.g., fixing partial dates like "1977" to "1977-01-01").
    * *Product Value:* Ensures reliable sorting and filtering, preventing application crashes due to bad data.

---

## ✨ Phase 5: Polish & Reliability
**Goal:** Ensure the app feels professional and handles real-world failure.

* **Offline-First Architecture**
    * *Feature:* Used **Hive** (Local NoSQL) to cache search results and the "My Library" list.
    * *Product Value:* Users can access their saved books and recent searches even without an internet connection.
* **First-Run Experience (FRE)**
    * *Feature:* Automated seeding of a "Welcome Guide" book upon first install.
    * *Product Value:* Prevents the "Empty State" problem; new users immediately see content and learn how to use the app.
* **Friendly Error Handling**
    * *Feature:* Custom UI components for network failures (e.g., "Connection Drifted") instead of raw error codes.
    * *Product Value:* Maintains user trust even when technical issues occur.
* **Crash-Proofing & Stability**
    * *Feature:* Implemented robust null-safety checks in the Dashboard to handle "Fresh Install" scenarios where local databases are initializing.
    * *Product Value:* Guarantees a stable launch experience for 100% of new users.

---

## 🛠 Phase 6: DevOps, Quality Assurance, & Refactoring (Tech Debt Payment)
**Goal:** Establish professional engineering practices and maintainable code.

* **Tri-Fold Presentation Layer:**
    * *Refactor:* Standardized all feature folders into strict `screens/`, `widgets/`, and `providers/` sub-directories.
    * *Value:* Improved code navigability and separation of concerns as the app scaled.
* **Dependency Inversion Enforcement:**
    * *Refactor:* Moved abstract Repositories to the `Domain` layer and implementations to `Data`, strictly adhering to Clean Architecture rules.
    * *Value:* Decoupled business logic from specific backend implementations (Supabase).
* **CI/CD Pipeline:**
    * *Implementation:* Configured **GitHub Actions** to automatically analyze code, run unit tests, and build the Android APK on every push.
    * *Value:* Guarantees code stability and prevents regressions before they reach the main branch.
* **Secret Management:**
    * *Implementation:* Secured API keys using `.env` files locally and GitHub Secrets for CI/CD.
    * *Value:* Industry-standard security compliance.

---

## 📜 Release History

### v1.0.3 (Hotfix)
* **Connectivity Fix:** Resolved an issue where Release builds could not connect to the internet due to missing permissions in the Android Manifest.

### v1.0.2 (Hotfix)
* **Critical Fix:** Resolved a potential crash on fresh installs where the "Up Next" tile would throw a casting error if the local database hadn't finished seeding.
* **Stability:** Improved null safety checks in the Home Dashboard.

### v1.0.1 (Patch)
* **UX Fix:** The "Up Next" tile now prioritizes user-saved books over the "Welcome Guide."
* **Polish:** Improved list filtering in the Home Dashboard.

### v1.0.0 (MVP)
* Initial release with Bento Grid, Hybrid Search, and Passive Ingestion pipeline.

---
*Generated by Libri AI Engineering Team*