
# Version Validator API

A Swift backend application implemented with [Vapor](https://vapor.codes/). This project provides two API endpoints to manage front-end version compatibility and serve sample data based on version validation.

## Features

- **Version Validation**: Ensures the front-end version meets backend requirements.
- **Endpoints**:
  - Retrieve the minimum version, current version, and force-update status.
  - Validate the front-end version and return sample data if valid.

## Endpoints

### Get minimum version
```bash
curl  http://localhost:8080/minversion
```

### Sample request
```bash
curl -X POST -d '{"version":"2.0.0"}' -H 'Content-Type: application/json' http://localhost:8080/sample
```

