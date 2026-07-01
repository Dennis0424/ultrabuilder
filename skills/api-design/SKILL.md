---
name: api-design
description: "API architecture — REST/GraphQL design, endpoint naming, error handling, versioning, documentation"
triggers:
  - "api design"
  - "design the api"
  - "rest api"
  - "graphql schema"
  - "endpoint design"
---

# API Design — Interface Architecture

## When to Invoke

Use when designing new APIs (REST, GraphQL, tRPC), restructuring existing endpoints, or establishing API conventions for a project.

## Design Principles

1. **Consumer-first** — design from the client's perspective, not the database schema
2. **Predictable** — same patterns everywhere, no surprises
3. **Minimal** — expose only what clients need, nothing more
4. **Evolvable** — can add fields/endpoints without breaking existing clients
5. **Self-describing** — names tell you what it does without reading docs

## REST Design

### URL Naming

```
# Resources are nouns (plural)
GET    /api/v1/users          # List users
POST   /api/v1/users          # Create user
GET    /api/v1/users/:id      # Get one user
PATCH  /api/v1/users/:id      # Update user
DELETE /api/v1/users/:id      # Delete user

# Nested resources for relationships
GET    /api/v1/users/:id/posts     # User's posts
POST   /api/v1/users/:id/posts     # Create post for user

# Actions (when CRUD doesn't fit)
POST   /api/v1/users/:id/activate  # Verb for non-CRUD action
POST   /api/v1/orders/:id/refund   # Action on resource
```

**Rules:**
- Plural nouns for collections (`/users` not `/user`)
- Kebab-case for multi-word (`/order-items` not `/orderItems`)
- No verbs in resource URLs (HTTP method IS the verb)
- Max 3 levels of nesting (`/users/:id/posts/:id/comments` — stop here)

### Response Format

```json
// Success (single item)
{
  "data": { "id": "123", "name": "...", "email": "..." },
  "meta": { "updatedAt": "2026-07-01T10:00:00Z" }
}

// Success (collection)
{
  "data": [{ "id": "123" }, { "id": "456" }],
  "meta": { "total": 42, "page": 1, "perPage": 20 }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Required", "code": "required" }
    ]
  }
}
```

### Status Codes (use correctly)

| Code | When |
|------|------|
| 200 | Success (with body) |
| 201 | Created (POST success) |
| 204 | Success (no body — DELETE) |
| 400 | Client error (validation, bad input) |
| 401 | Not authenticated |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state conflict) |
| 422 | Unprocessable entity (valid JSON, invalid semantics) |
| 429 | Rate limited |
| 500 | Server error (our fault) |

### Pagination

```
# Cursor-based (preferred for real-time data)
GET /api/v1/posts?cursor=abc123&limit=20
→ { data: [...], meta: { nextCursor: "def456", hasMore: true } }

# Offset-based (simpler, for stable datasets)
GET /api/v1/posts?page=2&perPage=20
→ { data: [...], meta: { total: 100, page: 2, perPage: 20, totalPages: 5 } }
```

### Filtering & Sorting

```
# Filtering
GET /api/v1/posts?status=published&author=123&tag=typescript

# Sorting
GET /api/v1/posts?sort=-createdAt    # Descending (prefix -)
GET /api/v1/posts?sort=title          # Ascending

# Searching
GET /api/v1/posts?q=search+term
```

### Versioning

```
# URL prefix (simplest, most visible)
/api/v1/users
/api/v2/users

# Header (cleaner URLs, harder to test)
Accept: application/vnd.api+json; version=2
```

**Rule:** v1 until you MUST break compatibility. Then v2 with a migration guide.

## GraphQL Design

### Schema Conventions

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts(first: Int, after: String): PostConnection!
  createdAt: DateTime!
}

type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
}

type PostEdge {
  node: Post!
  cursor: String!
}

# Mutations return the affected object
type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

type CreateUserPayload {
  user: User
  errors: [UserError!]
}
```

### Naming Conventions

- Types: `PascalCase`
- Fields: `camelCase`
- Enums: `SCREAMING_SNAKE_CASE`
- Inputs: `VerbNounInput` (e.g., `CreateUserInput`)
- Payloads: `VerbNounPayload`

## Error Handling Strategy

```typescript
// Typed error codes (not just strings)
enum ErrorCode {
  VALIDATION_ERROR = "VALIDATION_ERROR",
  NOT_FOUND = "NOT_FOUND",
  UNAUTHORIZED = "UNAUTHORIZED",
  RATE_LIMITED = "RATE_LIMITED",
  INTERNAL_ERROR = "INTERNAL_ERROR",
}

// Consistent error shape
interface ApiError {
  code: ErrorCode
  message: string          // Human-readable
  details?: FieldError[]   // For validation
  requestId?: string       // For support/debugging
}
```

## Security Checklist

- [ ] Authentication on all non-public endpoints
- [ ] Authorization (can THIS user do THIS action on THIS resource?)
- [ ] Input validation and sanitization
- [ ] Rate limiting (per user, per endpoint)
- [ ] No sensitive data in URLs (tokens, passwords)
- [ ] CORS configured (not `*` in production)
- [ ] Request size limits
- [ ] SQL injection prevention (parameterized queries)
- [ ] No verbose error details in production (no stack traces)

## Output

```markdown
## API Design

**Style**: REST / GraphQL / tRPC
**Endpoints**: [count]
**Auth**: [strategy]
**Versioning**: [approach]
**Pagination**: [cursor / offset]
**Error format**: [consistent shape]
**Documentation**: [OpenAPI / GraphQL introspection / tRPC types]
```
