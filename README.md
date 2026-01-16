# GreenNest - Plant E-Commerce Platform

A comprehensive plant e-commerce application with a professional admin dashboard, built with Flutter (frontend) and Spring Boot (backend).

## 📱 Application Features

### Customer Features
- **User Authentication**
  - User registration with email and password
  - Secure login with JWT token authentication
  - Password reset functionality
  - User profile management

- **Plant Browsing & Shopping**
  - Browse all available plants with images and details
  - Search plants by name
  - Filter plants by category
  - View detailed plant information (description, price, stock, category)
  - Responsive grid layout displaying plants

- **Favorites System**
  - Add/remove plants to favorites with heart icon
  - Dedicated favorites screen
  - View all bookmarked plants in one place
  - Sync favorites across all screens

- **Shopping Cart**
  - Add plants to cart from home screen or detail screen
  - Adjust quantity before checkout
  - View total price
  - Persistent cart management

- **Order Management**
  - Place orders with multiple items
  - View complete order history
  - Track order status (Pending, Shipped, Delivered, Cancelled)
  - View order details and delivery address
  - Expandable order cards showing items and pricing

- **User Profile**
  - View profile information (name, email, address)
  - Account management
  - Logout functionality

- **Navigation**
  - Smooth bottom navigation bar with 4 main sections
  - PageView for seamless screen transitions
  - Professional Material Design 3 UI

### Plant Detail Screen
- Full plant information display
- High-quality plant image
- Price, category, and description
- Stock availability indicator
- Favorite toggle button
- Quantity selector
- Add to cart functionality

---

## 🛡️ Admin Dashboard Features (Professional E-Commerce Standard)

### Dashboard Overview
- **Real-time Statistics**
  - Total Products count
  - Total Categories count
  - Total Customers count
  - Auto-refresh button to update stats
  - Professional stat cards with gradient header
  - Modern white AppBar with branded logo

### Products Management
- **Plant Management Interface**
  - View all plants in beautiful grid layout (2-column design)
  - Professional plant cards with:
    - Plant image preview
    - Plant name and category badge
    - Price display
    - Stock availability with color-coded indicators
    - Direct action buttons (Edit/Delete)
  
  - **Add New Plant**
    - Modal dialog for plant creation
    - Fields: Name, Description, Price, Stock, Image URL, Category
    - Image preview before saving
    - Category selection dropdown
    - Form validation
    - Success notifications
  
  - **Edit Plant**
    - Update all plant details
    - Change plant image
    - Modify pricing and stock
    - Update category assignment
  
  - **Delete Plant**
    - Confirmation dialog
    - Instant removal from inventory
    - Instant notification

### Categories Management
- **Category Management Interface**
  - View all categories in professional list layout
  - Category cards with:
    - Category icon
    - Category name and description
    - Direct action buttons (Edit/Delete)
  
  - **Add New Category**
    - Create plant categories
    - Fields: Category Name, Description
    - Quick category creation
  
  - **Edit Category**
    - Update category details
    - Change category name
    - Modify description
  
  - **Delete Category**
    - Remove categories with confirmation
    - Safeguard against accidental deletion

### Customers Management
- **Customer Management Interface**
  - View all registered customers in professional card layout
  - Customer cards with:
    - Avatar with user initial and gradient background
    - Customer name and email
    - Customer status badge
    - Direct action buttons (View Orders/Edit/Delete)
  
  - **View Customer Orders**
    - See all orders placed by specific customer
    - Order details with ID, date, and total amount
    - Expandable order cards
    - View items in each order
    - Track order status
    - See delivery address
  
  - **Edit Customer**
    - Update customer profile information
    - Modify customer details
  
  - **Delete Customer**
    - Remove customer accounts
    - Confirmation dialog for safety

### UI/UX Features
- **Professional Design**
  - Modern white AppBar with green gradient logo
  - Gradient header section for dashboard
  - Premium stat cards with colored backgrounds
  - Professional bottom navigation with active states
  - Soft shadows and rounded corners (14-16px)
  - Consistent spacing (16px, 20px, 24px)
  
- **Action Buttons**
  - Direct buttons on cards (no dropdown menus needed)
  - Color-coded buttons (Blue: View/Edit, Orange: Edit, Red: Delete)
  - Beautiful shadows matching button colors
  - Professional rounded design (10px radius)
  - Bold, readable typography
  
- **Loading States**
  - Loading spinners with green/cyan/purple colors
  - Loading messages
  - Skeleton states for data loading
  
- **Empty States**
  - Friendly messages when no data exists
  - Encouraging CTAs to create first item
  - Empty state icons
  - Helpful descriptions

- **Scrolling & Layout**
  - Smooth scrolling for all sections
  - Responsive design for different screen sizes
  - SingleChildScrollView for proper overflow handling

- **Navigation**
  - Professional bottom navigation bar with 4 tabs
  - Smooth transitions between sections
  - Active state highlighting
  - Icon and label display

---

## 🔐 Admin Dashboard Access

### Requirements
- Admin account created in MongoDB
- User role must be set to `ADMIN`
- Valid JWT authentication token

### How to Access

1. **Login to Admin Account**
   - Open the app and navigate to login screen
   - Enter admin email and password
   - Upon successful login, admin is redirected to Dashboard

2. **Admin Authentication Check**
   - System verifies if user has ADMIN role
   - If not authorized, redirected to login screen
   - Admin privileges required to access dashboard

3. **Dashboard URL** (if running on web)
   - Navigate to `/admin-dashboard` after login
   - Admin token required in headers

### Admin User Setup
```bash
# Create admin user in MongoDB
db.users.insertOne({
  name: "Admin User",
  email: "admin@greennest.com",
  password: "hashed_password", // bcrypt hashed
  role: "ADMIN"
})
```

---

## 🚀 Installation & Setup

### Prerequisites
- **Flutter SDK** (latest version)
- **Java JDK 17** or higher
- **MongoDB** (local or cloud instance)
- **VS Code** with Flutter extensions
- **Android Studio** (for Android emulator)
- **Git**

### Frontend Setup

#### 1. Clone and Navigate to Flutter App
```bash
cd c:\Users\MIHIR\Downloads\GreenNest\Frontend
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Configure API Endpoint
Edit `lib/Services/api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.0.104:8080';
```

#### 4. Run Flutter App
```bash
flutter run
```

Or in VS Code:
- Open Command Palette: `Ctrl + Shift + P`
- Type: `Flutter: Run Without Debugging`
- Select device (Android/iOS emulator)

### Backend Setup

#### 1. Navigate to Backend Directory
```bash
cd c:\Users\MIHIR\Downloads\GreenNest\Backend
```

#### 2. Configure MongoDB Connection
Edit `application.properties`:
```properties
spring.data.mongodb.uri=mongodb://localhost:27017
spring.data.mongodb.database=greennest
```

#### 3. Build Project
```bash
mvn clean install
```

#### 4. Run Spring Boot Application
```bash
mvn spring-boot:run
```

Or in VS Code using Spring Boot extension:
- Open the main class `Application.java`
- Click "Run" above the class declaration
- Server starts on `http://localhost:8080`

---

## 💻 Running in VS Code

### Frontend (Flutter)

**Step 1: Open Flutter App in VS Code**
```bash
code c:\Users\MIHIR\Downloads\GreenNest\Frontend
```

**Step 2: Install Flutter Extension**
- Open VS Code Extensions (Ctrl + Shift + X)
- Search for "Flutter"
- Install Flutter extension by Dart Code

**Step 3: Run the App**
- Press `F5` to start debugging
- OR use Command Palette: `Ctrl + Shift + P` → `Flutter: Run`
- Select your target device

**Step 4: Hot Reload**
- Press `R` for hot reload (updates UI without restart)
- Press `Ctrl + F5` for full restart

**Alternative: Terminal Method**
```bash
cd Frontend
flutter run
```

### Backend (Spring Boot)

**Step 1: Open Backend in VS Code**
```bash
code c:\Users\MIHIR\Downloads\GreenNest\Backend
```

**Step 2: Install Extensions**
- Search "Extension Pack for Java" in VS Code Extensions
- Install the official Microsoft Java extension pack

**Step 3: Run Spring Boot Application**
- Open `Application.java` or `GreenNestBackendApplication.java`
- Click "Run" above the main method
- OR use Command Palette: `Ctrl + Shift + P` → `Java: Start Debugging`

**Step 4: Verify Backend is Running**
- Open browser: `http://localhost:8080`
- Check console for: "Server started on port 8080"

**Alternative: Terminal Method**
```bash
cd Backend
mvn spring-boot:run
```

---

## 📊 API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `PUT /auth/passwordForgot/{email}` - Reset password
- `GET /auth/users/{email}` - Get user by email
- `GET /auth/users` - Get all users (admin only)

### Plants
- `GET /plants` - Get all plants with pagination
- `GET /plants/search?q=query` - Search plants
- `GET /categories` - Get all categories

### Admin APIs
- `GET /api/admin/plants` - Get all plants (admin)
- `POST /api/admin/plants` - Create plant (admin)
- `PUT /api/admin/plants/{id}` - Update plant (admin)
- `DELETE /api/admin/plants/{id}` - Delete plant (admin)
- `GET /api/admin/categories` - Get categories (admin)
- `POST /api/admin/categories` - Create category (admin)
- `PUT /api/admin/categories/{id}` - Update category (admin)
- `DELETE /api/admin/categories/{id}` - Delete category (admin)

### Orders
- `POST /orders/place` - Place new order
- `GET /orders/my-orders` - Get user's orders
- `GET /orders/{orderId}` - Get order details

---

## 🎨 Design System

### Color Scheme
- **Primary Green**: `Colors.green[700]` - Main brand color
- **Secondary Cyan**: `Colors.cyan[700]` - Categories
- **Tertiary Purple**: `Colors.deepPurple[700]` - Customers
- **Action Blue**: `Colors.blue[600]` - View/Edit
- **Danger Red**: `Colors.red[600]` - Delete
- **Warning Orange**: `Colors.orange[600]` - Edit

### Typography
- **Headers**: Bold, 18-22px
- **Titles**: Bold, 15-16px
- **Body Text**: Regular, 12-14px
- **Labels**: Semibold, 11-13px

### Spacing
- **Card Padding**: 16px
- **Section Padding**: 20-24px
- **Element Spacing**: 8-12px
- **Border Radius**: 10-16px

---

## 📦 Project Structure

```
GreenNest/
├── GreenNest-App/                 # Flutter Frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── Auth/                  # Authentication screens
│   │   ├── Screens/               # Main app screens
│   │   ├── Admin/                 # Admin dashboard
│   │   ├── Services/              # API services
│   │   ├── Helper/                # Helper functions
│   │   ├── Widget/                # Reusable widgets
│   │   └── Util/                  # Constants (colors, strings, etc)
│   ├── pubspec.yaml               # Flutter dependencies
│   └── android/, ios/, web/       # Platform-specific files
│
├── GreenNest-Backend/             # Spring Boot Backend
│   ├── Green-Harbor-Backend/
│   │   ├── src/
│   │   │   ├── main/java/         # Java source code
│   │   │   ├── main/resources/    # Configuration files
│   │   │   └── test/              # Unit tests
│   │   ├── pom.xml                # Maven dependencies
│   │   └── application.properties # Configuration
│
├── docker-compose.yml             # Docker setup for MongoDB
├── README.md                       # This file
└── LOCAL_SETUP_GUIDE.md          # Local development guide
```

---

## 🔧 Troubleshooting

### Flutter Issues

**Issue: "Target of URI doesn't exist"**
- Solution: Run `flutter pub get` in the project directory

**Issue: "App won't connect to backend"**
- Solution: Check API endpoint in `api_service.dart` matches your backend URL
- Verify backend is running: `http://localhost:8080`

**Issue: "Hot reload not working"**
- Solution: Press `Ctrl + F5` for full restart

### Backend Issues

**Issue: "MongoDB connection failed"**
- Solution: Verify MongoDB is running and connection string is correct
- Check `application.properties` for correct MongoDB URI

**Issue: "Port 8080 already in use"**
- Solution: Change port in `application.properties`:
  ```properties
  server.port=8081
  ```
- Update frontend API endpoint accordingly

---

## 📝 Environment Variables

### Backend (application.properties)
```properties
# Server
server.port=8080

# MongoDB
spring.data.mongodb.uri=mongodb://localhost:27017
spring.data.mongodb.database=greennest

# JWT
jwt.secret=your_jwt_secret_key
jwt.expiration=86400000
```

### Frontend (api_service.dart)
```dart
static const String baseUrl = 'http://192.168.0.104:8080';
```

---

## 🚢 Deployment

### Deploy to Production
1. Build Flutter app for release
2. Deploy Spring Boot backend to cloud
3. Update API endpoints in frontend
4. Configure CORS settings
5. Set up HTTPS
6. Configure database backups

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Developer

**Mihir** - Full Stack Developer

---

## 📞 Support

For issues and questions, please refer to:
- [LOCAL_SETUP_GUIDE.md](LOCAL_SETUP_GUIDE.md) - Detailed setup instructions
- [ADMIN_DASHBOARD_GUIDE.md](ADMIN_DASHBOARD_GUIDE.md) - Admin features guide
- GitHub Issues: https://github.com/Mihir072/GreenNest/issues

---

## ✨ Key Technologies

- **Frontend**: Flutter, Material Design 3, Dart
- **Backend**: Spring Boot 3.5.3, Java 17, Spring Data MongoDB
- **Database**: MongoDB
- **Authentication**: JWT (JSON Web Tokens)
- **API**: RESTful API
- **Version Control**: Git & GitHub

---

**Last Updated**: January 5, 2026

For the latest updates, visit: https://github.com/Mihir072/GreenNest
