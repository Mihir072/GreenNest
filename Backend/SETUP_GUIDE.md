# GreenNest Backend - Setup & Deployment Guide

## Prerequisites

- Java 17+
- Maven 3.8+
- MongoDB Atlas account (or local MongoDB)
- Gmail account with app-specific password
- Git (optional)

---

## Step 1: Clone or Extract Project

```bash
cd /path/to/GreenNest/Backend
```

---

## Step 2: Configure Environment

### A. Edit `application.yml`

```yaml
spring:
  application:
    name: "Green-Harbor-Backend"

  data:
    mongodb:
      uri: mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@cluster.mongodb.net/GreenNestDB?retryWrites=true&w=majority&appName=Cluster0

  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-app-specific-password
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true

server:
  port: 8081
```

### B. Get MongoDB Connection String

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a cluster if you don't have one
3. Click "Connect" → "Connect your application"
4. Copy the connection string
5. Replace `<username>`, `<password>`, and `<database>` in `application.yml`

### C. Get Gmail App Password

1. Enable 2-factor authentication on your Gmail account
2. Go to [Google Account Settings](https://myaccount.google.com/)
3. Navigate to Security → App passwords
4. Generate a new app password for Mail
5. Use this 16-character password in `application.yml`

---

## Step 3: Build Project

### Option A: Build with Maven

```bash
# Clean and install dependencies
mvn clean install

# Or skip tests during development
mvn clean install -DskipTests
```

### Option B: Build with Maven Wrapper

```bash
# On Windows
mvnw.cmd clean install

# On Linux/Mac
./mvnw clean install
```

---

## Step 4: Run Application

### Option A: Maven Command

```bash
mvn spring-boot:run
```

### Option B: Run JAR File

```bash
java -jar target/GreenNest-Backend-0.0.1-SNAPSHOT.jar
```

### Option C: IDE (IntelliJ IDEA / VS Code)

1. Open the project in your IDE
2. Navigate to `GreenHarborBackendApplication.java`
3. Click the Run button (▶️) or press `Shift + F10` (IntelliJ)

---

## Step 5: Verify Installation

### Check Server Health

```bash
curl http://localhost:8081/auth/users
```

Expected response: `401 Unauthorized` (because no token provided - which is correct!)

### Check Logs

Look for messages like:
```
Started GreenHarborBackendApplication in X.XXX seconds
```

---

## Step 6: Test with Postman/cURL

### 1. Register a New User

```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "address": "123 Main St",
    "role": "USER"
  }'
```

### 2. Login User

```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

You'll get a response like:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "role": "USER",
  "email": "john@example.com",
  "id": "userId123",
  "name": "John Doe"
}
```

### 3. Get All Plants

```bash
curl -X GET http://localhost:8081/plants \
  -H "Content-Type: application/json"
```

---

## Docker Deployment (Optional)

### Create Dockerfile

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/GreenNest-Backend-0.0.1-SNAPSHOT.jar app.jar

ENV SPRING_DATA_MONGODB_URI=${MONGODB_URI}
ENV SPRING_MAIL_USERNAME=${MAIL_USERNAME}
ENV SPRING_MAIL_PASSWORD=${MAIL_PASSWORD}

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Build Docker Image

```bash
docker build -t greennest-backend:latest .
```

### Run Docker Container

```bash
docker run -e MONGODB_URI="mongodb+srv://..." \
           -e MAIL_USERNAME="your-email@gmail.com" \
           -e MAIL_PASSWORD="your-app-password" \
           -p 8081:8081 \
           greennest-backend:latest
```

---

## Troubleshooting

### Issue: MongoDB Connection Failed

**Solution:**
1. Check if MongoDB URI is correct in `application.yml`
2. Verify IP whitelist on MongoDB Atlas (add 0.0.0.0/0 for development)
3. Ensure username and password are URL encoded (special characters like @ need encoding)

### Issue: Email Not Sending

**Solution:**
1. Verify Gmail app password (not regular password)
2. Check if 2FA is enabled on Gmail account
3. Ensure "Less secure app access" is not blocking (use app passwords instead)
4. Check email address format in your requests

### Issue: Port 8081 Already in Use

**Solution:**
```bash
# Change port in application.yml
server:
  port: 8082

# Or kill the process using the port (Linux/Mac)
lsof -ti:8081 | xargs kill -9
```

### Issue: Build Fails with Lombok Error

**Solution:**
- Ensure you've removed all Lombok annotations
- Run `mvn clean install` to clear cache
- Check for any remaining `@Data`, `@Slf4j` annotations in source files

### Issue: Compilation Errors on Controllers

**Solution:**
1. Ensure Java 17+ is installed: `java -version`
2. Set JAVA_HOME environment variable
3. In IDE: File → Project Structure → SDK → Set to Java 17+

---

## Security Checklist

Before deploying to production:

- [ ] Change default passwords/secrets
- [ ] Use environment variables for sensitive data (don't hardcode)
- [ ] Enable HTTPS/SSL certificates
- [ ] Set up proper MongoDB backups
- [ ] Configure firewall rules
- [ ] Enable CORS only for frontend domain
- [ ] Set up rate limiting on API endpoints
- [ ] Enable request logging and monitoring
- [ ] Use JWT secret key generation for production
- [ ] Update all dependencies to latest versions

---

## Environment Variables Setup

### Linux/Mac

```bash
export SPRING_DATA_MONGODB_URI="mongodb+srv://..."
export SPRING_MAIL_USERNAME="your-email@gmail.com"
export SPRING_MAIL_PASSWORD="your-app-password"
export SERVER_PORT=8081
```

### Windows PowerShell

```powershell
$env:SPRING_DATA_MONGODB_URI = "mongodb+srv://..."
$env:SPRING_MAIL_USERNAME = "your-email@gmail.com"
$env:SPRING_MAIL_PASSWORD = "your-app-password"
$env:SERVER_PORT = "8081"
```

### Windows CMD

```cmd
set SPRING_DATA_MONGODB_URI=mongodb+srv://...
set SPRING_MAIL_USERNAME=your-email@gmail.com
set SPRING_MAIL_PASSWORD=your-app-password
set SERVER_PORT=8081
```

---

## API Documentation

Once the server is running, access API documentation:

- **Swagger UI:** http://localhost:8081/swagger-ui.html
- **API Docs:** http://localhost:8081/v3/api-docs

Full endpoint documentation: See `API_DOCUMENTATION.md`

---

## Database Initialization

### Create Test Data (MongoDB)

```javascript
// Users collection
db.users.insertOne({
  name: "Admin User",
  email: "admin@example.com",
  password: "hashed_password",
  address: "Admin Address",
  role: "ADMIN",
  createdAt: new Date()
})

// Categories collection
db.categories.insertOne({
  name: "Flowers",
  description: "Beautiful flowering plants",
  imageUrl: "http://...",
  createdAt: new Date()
})

// Plants collection
db.plants.insertOne({
  name: "Rose",
  description: "Beautiful red rose",
  price: 299,
  category: "Flowers",
  imageUrl: "http://...",
  stock: 50,
  createdAt: new Date()
})
```

---

## Monitoring & Logs

### Application Logs

Logs are written to console by default. For file logging, add to `application.yml`:

```yaml
logging:
  level:
    root: INFO
    com.greenharbor: DEBUG
  file:
    name: logs/application.log
```

### View Logs

```bash
# Linux/Mac
tail -f logs/application.log

# Windows PowerShell
Get-Content logs/application.log -Tail 50 -Wait
```

---

## Deployment to Cloud

### AWS (Elastic Beanstalk)

```bash
# Install EB CLI
pip install awsebcli

# Create and deploy
eb create greennest-backend-env
eb deploy
```

### Azure (App Service)

```bash
# Install Azure CLI
# Then deploy using VS Code extension

az appservice plan create --name greennest-plan --resource-group mygroup
az webapp create --resource-group mygroup --plan greennest-plan --name greennest-backend
```

### Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create greennest-backend

# Deploy
git push heroku main
```

---

## Performance Optimization

1. **Enable Connection Pooling**
   ```yaml
   spring:
     datasource:
       hikari:
         maximum-pool-size: 20
   ```

2. **Add Database Indexing** (in MongoDB)
   ```javascript
   db.plants.createIndex({ name: 1 })
   db.plants.createIndex({ category: 1 })
   db.orders.createIndex({ userId: 1 })
   ```

3. **Implement Caching** (Future enhancement)

4. **Use Pagination** (Already implemented on plants endpoint)

---

## Support & Resources

- **Frontend Repository:** Check Flutter app for API integration examples
- **Documentation:** See `API_DOCUMENTATION.md` and `REFACTORING_SUMMARY.md`
- **Issues:** Check build.log for compilation errors
- **Configuration:** See `application.yml` for all available options

---

**Last Updated:** January 14, 2026
**Status:** ✅ Ready for Development & Production Deployment
