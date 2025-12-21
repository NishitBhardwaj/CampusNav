# CampusNav Backend - Spring Boot

Backend service for CampusNav (future scope).

## Purpose
Optional backend sync for:
- Map data updates
- Personnel directory synchronization
- Analytics and usage data
- Multi-device location sharing

## Tech Stack
- Java 17+
- Spring Boot 3.x
- PostgreSQL
- Redis (caching)
- Maven

## Project Structure

```
backend/springboot/
├── controller/     # REST API endpoints
├── service/        # Business logic
├── model/          # Data models/entities
├── repository/     # Database access
├── config/         # Configuration classes
└── pom.xml         # Maven dependencies
```

## API Endpoints (Planned)

### Maps
- `GET /api/buildings` - List all buildings
- `GET /api/buildings/{id}/floors` - Get floors for a building
- `GET /api/floors/{id}/map` - Get floor map data

### Navigation
- `POST /api/navigation/path` - Calculate path between points
- `GET /api/locations/search` - Search locations

### People
- `GET /api/people/search` - Search personnel directory
- `GET /api/people/{id}` - Get person details

## Setup Instructions

1. Install Java 17+
2. Install Maven
3. Configure PostgreSQL database
4. Update `application.properties`
5. Run: `mvn spring-boot:run`

## Note
The Flutter app is designed to work offline-first. This backend is 
optional and only needed for data synchronization features.
