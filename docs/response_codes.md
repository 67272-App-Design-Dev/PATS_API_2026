# API Response Codes

This document describes the HTTP response codes returned by the PATS API and what each one means in context.

---

## 2xx — Success

### 200 OK
The request was successful. Returned by most successful `GET`, `PATCH`, and `DELETE` requests.

**Examples:**
- `GET /v1/owners` — returns the list of owners
- `PATCH /v1/pets/:id` — owner was updated successfully
- `DELETE /v1/owners/:id` — owner was deleted successfully

### 201 Created
The request was successful and a new resource was created. Typically returned by `POST` requests.

> **Note:** The PATS API currently returns `200` instead of `201` for successful create actions. This is something to be aware of when writing tests.

### 204 No Content
The request was successful but there is no content to return. Can be returned by `DELETE` requests when nothing is rendered.

---

## 4xx — Client Errors

### 400 Bad Request
The server could not understand the request due to malformed syntax or invalid parameters. The client should not repeat the request without modifications.

### 401 Unauthorized
The request requires authentication. This is returned when:
- No `Authorization` header is provided
- An invalid or expired API token is used

All PATS API endpoints (except `/v1/token`) require a Bearer token in the request header:
```
Authorization: Token token=<your_api_key>
```

### 404 Not Found
The requested resource does not exist. Returned when an ID is provided that does not match any record in the database.

**Examples:**
- `GET /v1/owners/0` — no owner with ID 0
- `GET /v1/pets/9999` — no pet with that ID

### 422 Unprocessable Entity
The request was well-formed but could not be processed due to validation errors. Returned when:
- A required field is missing (e.g., no `last_name` for an owner)
- A field value is invalid (e.g., `state` is not PA, OH, or WV)
- A referenced association is inactive (e.g., creating a pet with an inactive owner or animal)

The response body will contain a JSON object describing the specific validation errors.

---

## 5xx — Server Errors

### 500 Internal Server Error
An unexpected error occurred on the server. This indicates a bug or unhandled exception in the application code, not a problem with the request itself.

---

## Quick Reference

| Code | Name                  | Meaning                                      |
|------|-----------------------|----------------------------------------------|
| 200  | OK                    | Request succeeded                            |
| 201  | Created               | Resource created successfully                |
| 204  | No Content            | Success, nothing to return                   |
| 400  | Bad Request           | Malformed request syntax                     |
| 401  | Unauthorized          | Missing or invalid authentication token      |
| 404  | Not Found             | Resource does not exist                      |
| 422  | Unprocessable Entity  | Validation errors prevented saving           |
| 500  | Internal Server Error | Unexpected server-side error                 |
