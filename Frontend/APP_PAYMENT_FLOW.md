# GreenNest App - Complete Payment Flow

## 📱 Application Flow Overview

### 1. **Home Screen** (Entry Point)
- User browsing plants catalog
- Each plant shows: name, price, image, rating
- User can add plants to cart

### 2. **Cart Screen** 
- Displays all items added by user
- Shows quantity, price per item, total price
- Features:
  - Increase/Decrease quantity
  - Remove items from cart
  - View total amount
  - **"Place Order" Button** → Navigates to Checkout Screen

### 3. **Checkout Screen** ✨ (NEW)
- **Order Summary Display:**
  - List of all items with quantity and price
  - Itemized breakdown
  - Total amount calculation
  - User details (name, email, address)
- **"Proceed to Payment" Button** → Creates order and navigates to Payment Method Selection

### 4. **Payment Method Screen** ✨ (NEW)
- User selects payment method:
  - **UPI** (Unified Payments Interface)
  - **Card** (Debit/Credit Card)
- Selection highlights the chosen method
- **"Continue" Button** → Initiates payment and navigates to selected payment screen

### 5. **Payment Processing** ✨ (NEW)

#### **Option A: UPI Payment Screen**
- Display QR Code for scanning
- OR Option to enter UPI ID manually
- Show payment details:
  - Order ID
  - Amount
  - Transaction details
- Simulated payment processing
- **Submit** → Verifies payment

#### **Option B: Card Payment Screen**
- Card details form with fields:
  - Card number (validation: Visa/Mastercard)
  - Cardholder name
  - Expiry date (MM/YY format)
  - CVV (3-4 digits)
- Input validation in real-time
- Secure form layout
- **"Pay Now" Button** → Processes payment

### 6. **Payment Success Screen** ✨ (NEW)
- ✅ Success message with animation
- Order confirmation details:
  - Order ID
  - Amount paid
  - Payment method used
  - Transaction ID
  - Timestamp
- **"Continue Shopping" Button** → Returns to Home Screen
- Cart is cleared on successful payment

### 7. **Payment Failure Screen** ✨ (NEW)
- ❌ Error message display
- Failure reason (if provided)
- Options:
  - **"Retry Payment"** → Back to payment method selection
  - **"Go to Home"** → Returns to home screen
- Order remains in pending state

---

## 🔄 Complete User Journey

```
Home Screen
    ↓
  Add Plants to Cart
    ↓
Cart Screen (View Cart & Items)
    ↓
Click "Place Order"
    ↓
Checkout Screen (Order Summary)
    ↓
Click "Proceed to Payment"
    ↓
Create Order (Backend)
    ↓
Payment Method Screen (UPI/Card)
    ↓
Select Payment Method
    ↓
├─→ UPI Payment Screen
│     ↓
│   Scan QR or Enter UPI ID
│     ↓
│   Verify Payment
│
└─→ Card Payment Screen
      ↓
    Enter Card Details
      ↓
    Validate & Process
    ↓
Success → Payment Success Screen → Home Screen
    OR
Failure → Payment Failure Screen → Retry or Home
```

---

## 🛡️ Security Features

### Frontend (Flutter)
1. **JWT Token Authentication**
   - Every API request includes Bearer token in header
   - Token extracted from login response
   - Token validated on each request

2. **Input Validation**
   - Card number validation (Luhn algorithm simulation)
   - Expiry date format validation (MM/YY)
   - CVV length validation (3-4 digits)
   - Phone number format validation for UPI

3. **Secure Data Handling**
   - Sensitive data not stored locally
   - Payment details not cached
   - Clear session on logout

### Backend (Spring Boot)
1. **JWT Authentication**
   - `@PreAuthorize("hasRole('USER')")` on payment endpoints
   - JWT token validation
   - User extraction from token

2. **Authorization**
   - UserId extracted from JWT
   - Reject orders for different users
   - Validate payment belongs to user

3. **Data Validation**
   - Request DTOs with validation
   - Order amount verification
   - User ID consistency checks

---

## 📤 API Endpoints

### Order Management
```
POST /api/orders
├─ Create new order
├─ Body: {userId, name, email, address, totalAmount, items[]}
└─ Returns: {status, data: {orderId, orderStatus}}

POST /api/orders/{orderId}/confirm
├─ Confirm order after payment
├─ Body: {paymentStatus}
└─ Returns: {status, data: {orderId, confirmed}}
```

### Payment Processing
```
POST /api/payments/initiate
├─ Initiate payment
├─ Body: {orderId, userId, paymentMethod, amount}
└─ Returns: {status, data: {paymentId, transactionId}}

POST /api/payments/verify
├─ Verify payment completion
├─ Body: {paymentId, orderId, transactionStatus}
└─ Returns: {status, data: {verified, paymentStatus}}
```

---

## 💾 Database Schema

### Orders Collection
```json
{
  "_id": "order_123",
  "userId": "user_456",
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main St",
  "items": [
    {
      "plantId": "plant_789",
      "name": "Money Plant",
      "quantity": 2,
      "price": 500
    }
  ],
  "totalAmount": 1000,
  "status": "pending",
  "createdAt": "2026-01-03T21:30:00Z",
  "paymentStatus": "pending"
}
```

### Payments Collection
```json
{
  "_id": "payment_123",
  "orderId": "order_123",
  "userId": "user_456",
  "amount": 1000,
  "paymentMethod": "UPI",
  "paymentStatus": "completed",
  "transactionId": "txn_456789",
  "transactionDetails": {
    "upiId": "user@upi",
    "timestamp": "2026-01-03T21:35:00Z"
  },
  "createdAt": "2026-01-03T21:30:00Z",
  "updatedAt": "2026-01-03T21:35:00Z"
}
```

---

## 📊 State Management

### Cart Management
- Managed in `HomeScreen` state
- Updated when items added/removed
- Passed to `CartScreen` as parameter
- Cleared after successful payment

### Order State
- Created at checkout
- Managed across payment flow
- Final status set after payment verification
- Persisted in backend

### Payment State
- Initiated when payment method selected
- Verified after payment completion
- Success/Failure determined by response
- Error handling with retry option

---

## ✅ Features Implemented

- [x] Checkout screen with order summary
- [x] Payment method selection (UPI/Card)
- [x] UPI payment with QR code
- [x] Card payment with validation
- [x] Payment success screen
- [x] Payment failure screen with retry
- [x] Order creation before payment
- [x] JWT authentication on all endpoints
- [x] Input validation on payment forms
- [x] Loading indicators during processing
- [x] Error handling with user feedback
- [x] Cart clearing on successful payment
- [x] Navigation between screens

---

## 🔧 Configuration

### Backend Endpoints
- Base URL: `http://192.168.0.104:8080`
- All endpoints require JWT Bearer token
- Request timeout: 30 seconds

### Payment Methods Supported
1. **UPI** - India's Unified Payments Interface
   - Via QR scan or UPI ID entry
   - Instant transaction confirmation

2. **Card** - Debit/Credit Cards
   - Visa, Mastercard
   - 3D Secure validation
   - Real-time card verification

---

## 🚀 Usage Instructions

### For Users
1. Browse and add plants to cart
2. Go to cart and review items
3. Click "Place Order" to proceed
4. Review order summary in checkout
5. Click "Proceed to Payment"
6. Select preferred payment method
7. Complete payment
8. Confirm successful transaction
9. Return to home and continue shopping

### For Developers
1. All payment flows are in `/lib/Screens/` directory
2. API calls handled in `/lib/Services/api_service.dart`
3. Custom widgets in `/lib/Widget/` directory
4. Colors and strings in `/lib/Util/` directory
5. Backend payment controllers in Spring Boot app

---

## 📝 Notes

- Payments are simulated for testing purposes
- Real payment gateway integration (Razorpay/Stripe) can be added
- Order confirmation emails can be sent after successful payment
- Payment history can be viewed in user profile (future feature)
- Refund processing support can be implemented
