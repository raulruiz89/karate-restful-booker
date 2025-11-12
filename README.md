# RESTful Booker - Karate API Test Suite

A comprehensive API test automation suite for the [RESTful Booker API](https://restful-booker.herokuapp.com) built with Karate Framework.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Test Categories](#test-categories)
- [CI/CD Pipeline](#cicd-pipeline)
- [Test Reports](#test-reports)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a complete test automation framework for the RESTful Booker API, covering functional, contract, security, negative, and non-functional testing scenarios. Built with Karate DSL for readable, maintainable, and scalable API tests.

## ✨ Features

- **Comprehensive Test Coverage**: Functional, contract, security, negative, and performance tests
- **Reusable Components**: Common helper features for authentication and booking creation
- **Tag-Based Execution**: Run specific test suites using tags (@smoke, @regression, @negative, etc.)
- **Schema Validation**: Contract testing with JSON schema validation
- **Security Testing**: Authentication flows and injection attack validation
- **Performance Testing**: Response time thresholds and SLA validation
- **CI/CD Integration**: GitHub Actions workflow with automated test execution and reporting
- **GitHub Pages Reporting**: Automated deployment of test reports to GitHub Pages

## 📁 Project Structure

```
restful-booker/
├── .github/
│   └── workflows/
│       └── restfull-booker.yml      # CI/CD pipeline configuration
├── src/
│   └── test/
│       ├── java/
│       │   ├── booker/
│       │   │   ├── common/           # Reusable helper features
│       │   │   │   ├── auth.feature
│       │   │   │   ├── create-booking.feature
│       │   │   │   ├── response-validation.feature
│       │   │   │   └── utils.js
│       │   │   ├── contract/         # Contract/schema validation tests
│       │   │   │   └── booking-contract.feature
│       │   │   ├── e2e/              # End-to-end test scenarios
│       │   │   │   └── booking-e2e.feature
│       │   │   ├── functional/       # CRUD and functional tests
│       │   │   │   └── booking-functional.feature
│       │   │   ├── negative/         # Negative test scenarios
│       │   │   │   └── booking-negative.feature
│       │   │   ├── nonfunctional/    # Performance and resilience tests
│       │   │   │   └── booking-nonfunctional.feature
│       │   │   └── security/         # Security and authentication tests
│       │   │       └── booking-security.feature
│       │   ├── karate-config.js      # Global test configuration
│       │   ├── logback-test.xml      # Logging configuration
│       │   └── BookerTest.java       # JUnit test runner
│       └── resources/
│           ├── schemas/              # JSON schemas for validation
│           │   └── booking/
│           │       ├── booking.schema.json
│           │       └── booking-create-response.schema.json
│           └── testdata/             # Test data files
│               └── booking/
│                   ├── booking-create.json
│                   ├── booking-patch.json
│                   ├── booking-update.json
│                   └── booking-invalid-*.json
├── .gitignore
├── pom.xml
└── README.md
```

## 🔧 Prerequisites

- **Java**: JDK 21 (Temurin/Eclipse Adoptium recommended)
- **Maven**: 3.8.x or higher
- **Git**: For version control

## 📥 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd restful-booker
   ```

2. **Verify Java and Maven installation**:
   ```bash
   java -version
   mvn -version
   ```

3. **Install dependencies**:
   ```bash
   mvn clean install -DskipTests
   ```

## 🚀 Running Tests

### Run All Tests

```bash
mvn clean test
```

### Run Specific Test Categories

**Exclude negative tests** (recommended for CI/CD):
```bash
mvn test -Dkarate.options="--tags ~@negative"
```

**Run only smoke tests**:
```bash
mvn test -Dkarate.options="--tags @smoke"
```

**Run smoke AND regression tests**:
```bash
mvn test -Dkarate.options="--tags @smoke&@regression"
```

**Run only negative tests**:
```bash
mvn test -Dkarate.options="--tags @negative"
```

**Run functional tests**:
```bash
mvn test -Dkarate.options="--tags @functional"
```

### Run Specific Test Files

```bash
mvn test -Dtest=BookerTest -Dkarate.options="classpath:booker/functional/booking-functional.feature"
```

## 🏷️ Test Categories

| Tag | Description | Use Case |
|-----|-------------|----------|
| `@smoke` | Critical path tests | Quick validation |
| `@regression` | Full regression suite | Complete validation |
| `@functional` | CRUD operations | Feature validation |
| `@contract` | Schema validation | API contract testing |
| `@security` | Auth & injection tests | Security validation |
| `@negative` | Error scenarios | Robustness testing |
| `@nonfunctional` | Performance & SLA | Performance validation |
| `@e2e` | End-to-end flows | Integration testing |

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow that:

1. **Runs on**: Push/PR to `develop` or `main` branches, or manual trigger
2. **Executes**: All tests except `@negative` scenarios
3. **Generates**: Karate HTML test reports
4. **Deploys**: Test reports to GitHub Pages automatically
5. **Retention**: Reports stored for 30 days

### Workflow Configuration

See `.github/workflows/restfull-booker.yml` for the complete pipeline configuration.

### Triggering the Workflow

- **Automatic**: Push or create PR to `develop`/`main`
- **Manual**: Go to Actions → Select workflow → Run workflow

## 📊 Test Reports

### Local Reports

After running tests locally, reports are available at:
- **Summary**: `target/karate-reports/karate-summary.html`
- **Timeline**: `target/karate-reports/karate-timeline.html`
- **Tags**: `target/karate-reports/karate-tags.html`

### GitHub Pages Reports

Automated test reports are deployed to GitHub Pages after each workflow run:
- URL: `https://github.com/raulruiz89/karate-restful-booker/`

## 🧪 Test Scenarios Covered

### Functional Tests
- Health check (GET /ping)
- Get all bookings with filters (firstname, lastname, checkin/checkout dates)
- Get booking by ID
- Create booking
- Update booking (PUT)
- Partial update (PATCH)
- Delete booking

### Contract Tests
- Response schema validation
- Content-Type header validation
- Deterministic ID handling

### Security Tests
- Valid authentication
- Invalid credentials handling
- Unauthorized access (403)
- SQL injection protection
- XSS injection protection

### Negative Tests
- Missing required fields
- Invalid data types
- Invalid date ranges
- Unauthorized operations
- Media type handling

### Non-Functional Tests
- Response time < 800ms
- Average response time < 1200ms
- Resilience (delete + 404 verification)

## 🛠️ Utilities

The framework includes reusable utilities (`src/test/java/booker/common/utils.js`):

- `todayPlus(days)`: Generate dates relative to today
- `buildBooking(opts)`: Create booking payloads with defaults
- `mean(nums)`: Calculate average for performance tests
- `nonEmptyIdList(list)`: Validate booking ID lists

## 📝 Configuration

### Environment Configuration

Edit `src/test/java/karate-config.js`:

```javascript
function fn() {
  var config = {
    baseUrl: 'https://restful-booker.herokuapp.com',
    username: 'admin',
    password: 'password123'
  };
  return config;
}
```

### Test Data

Update test data files in `src/test/resources/testdata/booking/`:
- `booking-create.json`: Default booking creation payload
- `booking-update.json`: Full update payload
- `booking-patch.json`: Partial update payload

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Karate Documentation](https://github.com/karatelabs/karate)
- [RESTful Booker API](https://restful-booker.herokuapp.com/apidoc/index.html)
- [Maven Documentation](https://maven.apache.org/guides/)

## 📧 Contact

For questions or support, please open an issue in the repository.

---

**Built with ❤️ using Karate Framework**
