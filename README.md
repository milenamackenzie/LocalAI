
=======
# LocalAI
**AI-Powered Location & Interest-Based Mobile App**

## Overview
A cross-platform mobile app that helps users find personalised places and events based on their location and interests. The app integrates external search APIs, advanced LLM summarisation, and dashboards for monitoring and cost tracking.

## Repository Structure
- **/frontend/**: Flutter app source code (Android).
- **/backend/**: Node.js (Express) backend code with SQLite.
- **/docs/**: Project documentation, architecture diagrams, privacy and ethics notes.
- **/tests/**: Integration and environment verification test suites.
- **/.github/**: GitHub Actions workflows, issue, and PR templates.
- **/.vscode/**: Development environment configuration.

## Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.19+
- **Node.js**: Version 24+ (for Express Backend)
- **SQLite**: Local database
- **Android Studio / SDK**: For Android emulation/building

### Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Milenamackenzie/LocalAI.git
    ```

2.  **Mobile App**:
    Navigate to `/frontend/` and follow setup instructions:
    ```bash
    cd frontend
    flutter pub get
    flutter run
    ```

3.  **Backend**:
    Navigate to `/backend/` and follow setup instructions:
    ```bash
    cd backend
    npm install
    npm run dev
    ```

4.  **Environment Verification**:
    Run the automated test suite to ensure your environment is configured correctly:
    ```bash
    node run_env_tests.js
    ```

## Documentation
- **System Architecture**: See `/docs/` (To be populated)
- **CI/CD Pipelines**: See `/.github/workflows/`
- **Environment Reports**: See `env_test_report.html` (Local only)

## Contribution Guidelines
1.  Open an issue for feature requests or bugs.
2.  Fork and create a feature branch.
3.  Ensure tests pass before submitting a pull request.
4.  Follow the code style guidelines in the contributing docs.

---
*Created by [Milenamackenzie](https://github.com/Milenamackenzie)*
>>>>>>> 6943538ae9cfdfccee75ec2370c2964422e41490
