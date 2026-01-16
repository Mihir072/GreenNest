# GreenNest Backend API Documentation

## Overview
This is a Spring Boot backend for the GreenNest plant e-commerce application. The API provides endpoints for user authentication, plant management, order processing, and admin operations.

## Base URL
```
http://localhost:8081
```

---

## Authentication Endpoints

### 1. Register New User
- **Endpoint:** `POST /auth/register`
- **Description:** Register a new user account
- **Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "address": "123 Main St",
  "role": "USER"
}
```
- **Response:** User object with generated ID

### 2. Login User
- **Endpoint:** `POST /auth/login`
- **Description:** Authenticate user and return JWT token
- **Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```
- **Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "role": "USER",
  "email": "john@example.com",
  "id": "userId",
  "name": "John Doe"
}
```

### 3. Logout User
- **Endpoint:** `POST /auth/logout`
- **Description:** Logout the user
- **Headers:** `Authorization: Bearer {token}`
- **Response:**
```json
{
  "message": "Logout successful"
}
```

### 4. Forgot Password / Reset Password
- **Endpoint:** `PUT /auth/passwordForgot/{email}`
- **Description:** Reset user password
- **Request Body:**
```json
{
  "password": "newPassword123"
}
```
- **Response:**
```json
{
  "message": "Password updated successfully"
}
```

### 5. Get User by Email
- **Endpoint:** `GET /auth/users/{email}`
- **Description:** Get user details by email
- **Response:** User object

### 6. Get All Users (Admin Only)
- **Endpoint:** `GET /auth/users`
- **Description:** Retrieve all users from the system
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Array of User objects

### 7. Get User by ID (Admin Only)
- **Endpoint:** `GET /auth/users/id/{id}`
- **Description:** Get specific user by ID
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** User object

### 8. Update User
- **Endpoint:** `PUT /auth/users/{id}`
- **Description:** Update user information
- **Request Body:**
```json
{
  "name": "Updated Name",
  "email": "newemail@example.com",
  "address": "New Address",
  "password": "newPassword123"
}
```
- **Response:** Updated User object

### 9. Delete User (Admin Only)
- **Endpoint:** `DELETE /auth/users/{id}`
- **Description:** Delete a user account
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:**
```json
{
  "message": "User deleted successfully"
}
```

---

## Plant Endpoints

### 1. Get All Plants with Pagination
- **Endpoint:** `GET /plants`
- **Description:** Retrieve all plants with pagination and optional category filter
- **Query Parameters:**
  - `page` (default: 0) - Page number
  - `size` (default: 12) - Items per page
  - `category` (optional) - Filter by category
- **Response:**
```json
{
  "content": [...],
  "currentPage": 0,
  "totalItems": 50,
  "totalPages": 5
}
```

### 2. Search Plants
- **Endpoint:** `GET /plants/search?q={query}`
- **Description:** Search plants by name or description
- **Query Parameters:**
  - `q` - Search query (required)
  - `category` (optional) - Filter by category
- **Response:** Array of matching Plant objects

### 3. Get Plant by ID
- **Endpoint:** `GET /plants/{id}`
- **Description:** Get detailed information about a specific plant
- **Response:** Plant object

### 4. Get Categories
- **Endpoint:** `GET /categories`
- **Description:** Get all available plant categories
- **Response:** Array of Category objects

---

## Admin Plant Management Endpoints

### 1. Get All Plants (Admin)
- **Endpoint:** `GET /api/admin/plants`
- **Description:** Retrieve all plants for admin management
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Array of Plant objects

### 2. Create Plant (Admin)
- **Endpoint:** `POST /api/admin/plants`
- **Description:** Create a new plant listing
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Request Body:**
```json
{
  "name": "Rose",
  "description": "Beautiful red rose",
  "price": 299,
  "category": "Flowers",
  "imageUrl": "http://...",
  "stock": 50
}
```
- **Response:** Created Plant object

### 3. Update Plant (Admin)
- **Endpoint:** `PUT /api/admin/plants/{id}`
- **Description:** Update plant details
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Request Body:** Plant object with fields to update
- **Response:** Updated Plant object

### 4. Delete Plant (Admin)
- **Endpoint:** `DELETE /api/admin/plants/{id}`
- **Description:** Delete a plant from the catalog
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:**
```json
{
  "message": "Plant deleted successfully"
}
```

---

## Admin Category Management Endpoints

### 1. Get All Categories (Admin)
- **Endpoint:** `GET /api/admin/categories`
- **Description:** Retrieve all categories for admin management
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Array of Category objects

### 2. Create Category (Admin)
- **Endpoint:** `POST /api/admin/categories`
- **Description:** Create a new plant category
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Request Body:**
```json
{
  "name": "Flowers",
  "description": "Blooming flowers",
  "imageUrl": "http://..."
}
```
- **Response:** Created Category object

### 3. Update Category (Admin)
- **Endpoint:** `PUT /api/admin/categories/{id}`
- **Description:** Update category details
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Request Body:** Category object with fields to update
- **Response:** Updated Category object

### 4. Delete Category (Admin)
- **Endpoint:** `DELETE /api/admin/categories/{id}`
- **Description:** Delete a category
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:**
```json
{
  "message": "Category deleted successfully"
}
```

---

## Order Endpoints

### 1. Place New Order
- **Endpoint:** `POST /orders/place`
- **Description:** Create and place a new order
- **Headers:** `Authorization: Bearer {token}`
- **Security:** Requires USER role
- **Request Body:**
```json
{
  "name": "John Doe",
  "address": "123 Main St",
  "email": "john@example.com",
  "items": [
    {
      "plantId": "plantId123",
      "name": "Rose",
      "price": 299,
      "quantity": 2
    }
  ],
  "totalAmount": 598
}
```
- **Response:** Created Order object

### 2. Get User's Orders
- **Endpoint:** `GET /orders/my-orders`
- **Description:** Retrieve all orders placed by the authenticated user
- **Headers:** `Authorization: Bearer {token}`
- **Security:** Requires USER role
- **Response:** Array of Order objects

### 3. Get Order Details
- **Endpoint:** `GET /orders/{orderId}`
- **Description:** Get detailed information about a specific order
- **Headers:** `Authorization: Bearer {token}`
- **Security:** Requires USER role (can only view own orders)
- **Response:** Order object

---

## Admin Order Management Endpoints

### 1. Get All Orders (Admin)
- **Endpoint:** `GET /api/admin/orders`
- **Description:** Retrieve all orders in the system
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Array of Order objects

### 2. Get Orders by User (Admin)
- **Endpoint:** `GET /api/admin/orders/user/{userId}`
- **Description:** Get all orders for a specific user
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Array of Order objects

### 3. Get Order by ID (Admin)
- **Endpoint:** `GET /api/admin/orders/{orderId}`
- **Description:** Get detailed order information
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:** Order object

### 4. Update Order (Admin)
- **Endpoint:** `PUT /api/admin/orders/{orderId}`
- **Description:** Update order status or details
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Request Body:**
```json
{
  "status": "Shipped"
}
```
- **Response:** Updated Order object

### 5. Delete Order (Admin)
- **Endpoint:** `DELETE /api/admin/orders/{orderId}`
- **Description:** Delete an order
- **Headers:** `Authorization: Bearer {adminToken}`
- **Security:** Requires ADMIN role
- **Response:**
```json
{
  "message": "Order deleted successfully"
}
```

---

## Payment Endpoints

### 1. Initiate Payment
- **Endpoint:** `POST /api/payments/initiate`
- **Description:** Create a payment session
- **Headers:** `Authorization: Bearer {token}`
- **Security:** Requires USER role
- **Request Body:**
```json
{
  "amount": 598,
  "orderId": "orderId123"
}
```
- **Response:**
```json
{
  "paymentId": "uuid",
  "userId": "userId",
  "amount": 598,
  "orderId": "orderId123",
  "status": "INITIATED",
  "timestamp": 1234567890
}
```

### 2. Verify Payment
- **Endpoint:** `POST /api/payments/verify?paymentId={paymentId}&isSuccess={true/false}&failureReason={reason}`
- **Description:** Verify payment completion
- **Headers:** `Authorization: Bearer {token}`
- **Security:** Requires USER role
- **Query Parameters:**
  - `paymentId` - Payment ID to verify (required)
  - `isSuccess` - Payment success status (required)
  - `failureReason` - Reason for failure if applicable
- **Response:**
```json
{
  "paymentId": "uuid",
  "userId": "userId",
  "status": "SUCCESS/FAILED",
  "failureReason": "reason if failed",
  "verifiedAt": 1234567890
}
```

---

## Data Models

### User
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "password": "string (encrypted)",
  "address": "string",
  "role": "USER or ADMIN",
  "createdAt": "timestamp"
}
```

### Plant
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "category": "string",
  "imageUrl": "string",
  "stock": "number",
  "createdAt": "timestamp"
}
```

### Category
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "imageUrl": "string",
  "createdAt": "timestamp"
}
```

### Order
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "address": "string",
  "email": "string",
  "items": [
    {
      "plantId": "string",
      "name": "string",
      "price": "number",
      "quantity": "number"
    }
  ],
  "totalAmount": "number",
  "status": "string (Placed, Shipped, Delivered, etc.)",
  "createdAt": "timestamp"
}
```

---

## Error Handling

All endpoints return standardized error responses:

```json
{
  "error": "Error message describing what went wrong"
}
```

Common HTTP Status Codes:
- `200 OK` - Successful request
- `201 CREATED` - Resource created successfully
- `400 BAD REQUEST` - Invalid request or validation error
- `401 UNAUTHORIZED` - Missing or invalid authentication
- `403 FORBIDDEN` - User doesn't have required permissions
- `404 NOT FOUND` - Resource not found
- `500 INTERNAL SERVER ERROR` - Server error

---

## Security Notes

1. **JWT Authentication:** All protected endpoints require a valid JWT token in the Authorization header
2. **Role-based Access Control:** Admin endpoints are protected with `@PreAuthorize("hasRole('ADMIN')")`
3. **User Data Privacy:** Users can only access their own orders; admins can access all orders
4. **Password Security:** Passwords are encrypted using BCrypt before storage

---

## Setup & Configuration

### Required Environment Variables
```
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-app-password

SPRING_DATA_MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname
```

### Build & Run
```bash
mvn clean install
mvn spring-boot:run
```

---

## Notes

- **Lombok Removed:** This backend no longer uses Lombok annotations. All models have explicit getters, setters, and constructors.
- **Redis Removed:** Redis caching has been completely removed. The application now uses only MongoDB for data persistence.
- **JWT Token:** Token is extracted from Authorization header with format `Bearer {token}`
- **Pagination:** Default page size is 12 items per page for plant listings
