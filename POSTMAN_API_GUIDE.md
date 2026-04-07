# 📮 Postman API Integration Guide
## Complete API Requests for Tier 1 Features

---

## 🔑 Setup Your Postman Environment

### 1. Create New Environment Variables
In Postman: `Environments` → `Create` → Add these variables:

```
STRIPE_SECRET_KEY: sk_test_YOUR_KEY
STRIPE_PUBLISHABLE_KEY: pk_test_YOUR_KEY
TWILIO_ACCOUNT_SID: ACxxxxx
TWILIO_AUTH_TOKEN: your_twilio_token
AGORA_APP_ID: your_agora_id
AGORA_CERTIFICATE: your_agora_cert
OPENAI_API_KEY: sk-xxxxx
FIREBASE_API_KEY: AIxxx
FIREBASE_PROJECT_ID: shecan-ai-project
STRIPE_WEBHOOK_SECRET: whsec_xxxxx
```

---

## 💳 STRIPE PAYMENT API

### 1️⃣ Create Payment Intent (Server-side)

**Method:** `POST`  
**URL:** `https://api.stripe.com/v1/payment_intents`  
**Auth:** Basic Auth with Secret Key `sk_test_xxx`

**Headers:**
```
Content-Type: application/x-www-form-urlencoded
```

**Body (form-data):**
```
amount=5000
currency=usd
payment_method_types[]=card
metadata[projectId]=proj_123
metadata[clientId]=user_456
description=Payment for Project Design
```

**cURL:**
```bash
curl -X POST https://api.stripe.com/v1/payment_intents \
  -H "Authorization: Bearer sk_test_YOUR_SECRET_KEY" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=5000&currency=usd&payment_method_types[]=card"
```

**Response Example:**
```json
{
  "id": "pi_1234567890",
  "amount": 5000,
  "currency": "usd",
  "client_secret": "pi_1234567890_secret_abcd1234",
  "status": "requires_payment_method"
}
```

---

### 2️⃣ Confirm Payment

**Method:** `POST`  
**URL:** `https://api.stripe.com/v1/payment_intents/{payment_intent_id}/confirm`

**Headers:**
```
Authorization: Bearer sk_test_YOUR_SECRET_KEY
Content-Type: application/x-www-form-urlencoded
```

**Body (form-data):**
```
payment_method=pm_1234567890
```

**cURL:**
```bash
curl -X POST https://api.stripe.com/v1/payment_intents/pi_1234567890/confirm \
  -H "Authorization: Bearer sk_test_YOUR_SECRET_KEY" \
  -d "payment_method=pm_card_visa"
```

---

### 3️⃣ Get Payment Status

**Method:** `GET`  
**URL:** `https://api.stripe.com/v1/payment_intents/{payment_intent_id}`

**Headers:**
```
Authorization: Bearer sk_test_YOUR_SECRET_KEY
```

**cURL:**
```bash
curl -X GET https://api.stripe.com/v1/payment_intents/pi_1234567890 \
  -H "Authorization: Bearer sk_test_YOUR_SECRET_KEY"
```

---

### 4️⃣ Create Customer for Recurring Billing

**Method:** `POST`  
**URL:** `https://api.stripe.com/v1/customers`

**Body (form-data):**
```
email=user@example.com
name=John Doe
metadata[userId]=user_123
```

**cURL:**
```bash
curl -X POST https://api.stripe.com/v1/customers \
  -H "Authorization: Bearer sk_test_YOUR_SECRET_KEY" \
  -d "email=user@example.com&name=John Doe"
```

---

### 5️⃣ Get Charges List

**Method:** `GET`  
**URL:** `https://api.stripe.com/v1/charges?limit=10`

**Headers:**
```
Authorization: Bearer sk_test_YOUR_SECRET_KEY
```

---

### 🧪 Stripe Test Cards

Use these in Postman when testing:

| Card Number | Exp | CVC | Status |
|---|---|---|---|
| `4242 4242 4242 4242` | 12/26 | 123 | ✅ Success |
| `4000 0000 0000 9995` | 12/26 | 123 | ❌ Decline |
| `4000 0025 0000 3155` | 12/26 | 123 | ❌ 3D Secure |

---

## 📱 TWILIO VIDEO API

### 1️⃣ Generate Video Room Token

**Method:** `POST`  
**URL:** `https://api.twilio.com/2010-04-01/Accounts/{TWILIO_ACCOUNT_SID}/Tokens`

**Auth:** Basic Auth with Account SID and Auth Token

**Headers:**
```
Content-Type: application/x-www-form-urlencoded
```

**Body (form-data):**
```
VideoGrant={"room":"room_name_here","maxParticipants":4}
Identity=user_unique_id_123
```

**cURL:**
```bash
curl -X POST \
  https://api.twilio.com/2010-04-01/Accounts/AC_YOUR_ACCOUNT_SID/Tokens \
  -u "AC_YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN" \
  -d "Identity=user123&VideoGrant={\"room\":\"consultation_room\",\"maxParticipants\":2}"
```

**Response Example:**
```json
{
  "jwt": "eyJhbGc...",
  "lifetime": 3600
}
```

---

### 2️⃣ Create Twilio Participant

**Method:** `POST`  
**URL:** `https://video.twilio.com/v1/Rooms/{room_name}/Participants`

**Auth:** Basic (Account SID + Auth Token)

**Body (form-data):**
```
Identity=participant_name
TTL=3600
```

**cURL:**
```bash
curl -X POST \
  https://video.twilio.com/v1/Rooms/my_room/Participants \
  -u "AC_YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN" \
  -d "Identity=john_doe"
```

---

### 3️⃣ List Active Rooms

**Method:** `GET`  
**URL:** `https://video.twilio.com/v1/Rooms?Status=in-progress&limit=10`

**Auth:** Basic (Account SID + Auth Token)

**cURL:**
```bash
curl -X GET \
  "https://video.twilio.com/v1/Rooms?Status=in-progress" \
  -u "AC_YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN"
```

---

## 🎥 AGORA VIDEO API

### 1️⃣ Generate Agora Token

**Method:** `POST`  
**URL:** `https://api.agora.io/v1/projects/{AGORA_APP_ID}/rtc/channels/{channelName}/users/{uid}/token`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer YOUR_AGORA_API_KEY
```

**Body (JSON):**
```json
{
  "role": "publisher",
  "expire": 3600,
  "uid": "12345",
  "channel": "consultation_channel"
}
```

**cURL:**
```bash
curl -X POST \
  "https://api.agora.io/v1/projects/YOUR_AGORA_APP_ID/rtc/channels/my_channel/users/123/token" \
  -H "Authorization: Bearer YOUR_AGORA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "publisher",
    "expire": 3600
  }'
```

**Response Example:**
```json
{
  "rtcToken": "00690e8d98eee...",
  "rtmToken": "1:appId:...",
  "uid": "12345"
}
```

---

### 2️⃣ List Active Channels

**Method:** `GET`  
**URL:** `https://api.agora.io/v1/projects/{AGORA_APP_ID}/channels`

**Headers:**
```
Authorization: Bearer YOUR_AGORA_API_KEY
```

---

## 🤖 OPENAI API

### 1️⃣ Generate AI Resume

**Method:** `POST`  
**URL:** `https://api.openai.com/v1/chat/completions`

**Headers:**
```
Authorization: Bearer sk-YOUR_OPENAI_API_KEY
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "model": "gpt-3.5-turbo",
  "temperature": 0.7,
  "max_tokens": 1000,
  "messages": [
    {
      "role": "system",
      "content": "You are a professional resume writer. Create a professional resume based on provided information."
    },
    {
      "role": "user",
      "content": "Create resume for: Name: John Doe, Skills: JavaScript, React, Node.js, Experience: 5 years as Full Stack Developer"
    }
  ]
}
```

**cURL:**
```bash
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer sk-YOUR_OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "Create a professional resume for a JavaScript developer with 5 years experience"
      }
    ]
  }'
```

**Response Example:**
```json
{
  "choices": [
    {
      "message": {
        "content": "JOHN DOE\n\nJavaScript Developer with 5+ years...\n"
      }
    }
  ],
  "usage": {
    "prompt_tokens": 50,
    "completion_tokens": 150
  }
}
```

---

### 2️⃣ Chat Bot Query

**Method:** `POST`  
**URL:** `https://api.openai.com/v1/chat/completions`

**Body (JSON):**
```json
{
  "model": "gpt-4",
  "temperature": 0.8,
  "max_tokens": 500,
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful mentor for freelancers. Provide advice on gig work, payments, and skills improvement."
    },
    {
      "role": "user",
      "content": "How can I improve my profile to get more projects?"
    }
  ]
}
```

**cURL:**
```bash
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer sk-YOUR_OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "How do I improve my freelance profile?"}
    ]
  }'
```

---

### 3️⃣ Generate Audio Transcription (for voice notes)

**Method:** `POST`  
**URL:** `https://api.openai.com/v1/audio/transcriptions`

**Headers:**
```
Authorization: Bearer sk-YOUR_OPENAI_API_KEY
```

**Body:** (form-data)
```
file: <select audio file>
model: whisper-1
```

**cURL:**
```bash
curl -X POST https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer sk-YOUR_OPENAI_API_KEY" \
  -F "model=whisper-1" \
  -F "file=@audio.mp3"
```

---

## 🔥 FIREBASE REST API

### 1️⃣ Create Conversation (Firestore)

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/conversations`

**Headers:**
```
Authorization: Bearer {YOUR_ID_TOKEN}
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "fields": {
    "participantIds": {
      "arrayValue": {
        "values": [
          {"stringValue": "user_1"},
          {"stringValue": "user_2"}
        ]
      }
    },
    "participantNames": {
      "mapValue": {
        "fields": {
          "user_1": {"stringValue": "John Doe"},
          "user_2": {"stringValue": "Jane Smith"}
        }
      }
    },
    "lastMessage": {"stringValue": "Hello there!"},
    "lastMessageTimestamp": {"timestampValue": "2024-01-15T10:30:00Z"},
    "createdAt": {"timestampValue": "2024-01-15T10:00:00Z"}
  }
}
```

**cURL:**
```bash
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/shecan-ai-project/databases/(default)/documents/conversations" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "participantIds": {"arrayValue": {"values": [{"stringValue": "user1"}]}},
      "lastMessage": {"stringValue": "Hello"}
    }
  }'
```

---

### 2️⃣ Send Chat Message

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/conversations/{conversationId}/messages`

**Body (JSON):**
```json
{
  "fields": {
    "senderId": {"stringValue": "user_123"},
    "senderName": {"stringValue": "John Doe"},
    "content": {"stringValue": "This is a test message"},
    "timestamp": {"timestampValue": "2024-01-15T10:35:00Z"},
    "readBy": {
      "arrayValue": {
        "values": []
      }
    },
    "isRead": {"booleanValue": false}
  }
}
```

**cURL:**
```bash
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/shecan-ai-project/databases/(default)/documents/conversations/conv_123/messages" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "senderId": {"stringValue": "user123"},
      "content": {"stringValue": "Hello!"},
      "timestamp": {"timestampValue": "2024-01-15T10:35:00Z"}
    }
  }'
```

---

### 3️⃣ Create Payment Record

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/payments`

**Body (JSON):**
```json
{
  "fields": {
    "projectId": {"stringValue": "proj_123"},
    "fromUserId": {"stringValue": "user_client"},
    "toUserId": {"stringValue": "user_freelancer"},
    "amount": {"doubleValue": 150.00},
    "status": {"stringValue": "completed"},
    "method": {"stringValue": "stripe"},
    "stripePaymentIntentId": {"stringValue": "pi_1234567890"},
    "createdAt": {"timestampValue": "2024-01-15T10:40:00Z"}
  }
}
```

---

### 4️⃣ Get All Conversations

**Method:** `GET`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/conversations`

**Headers:**
```
Authorization: Bearer {YOUR_ID_TOKEN}
```

**cURL:**
```bash
curl -X GET \
  "https://firestore.googleapis.com/v1/projects/shecan-ai-project/databases/(default)/documents/conversations" \
  -H "Authorization: Bearer YOUR_ID_TOKEN"
```

---

### 5️⃣ Query Messages in Conversation (with filtering)

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`

**Body (JSON):**
```json
{
  "structuredQuery": {
    "from": [{"collectionId": "conversations"}],
    "where": {
      "fieldFilter": {
        "field": {"fieldPath": "id"},
        "op": "EQUAL",
        "value": {"stringValue": "conv_123"}
      }
    },
    "orderBy": [
      {
        "field": {"fieldPath": "lastMessageTimestamp"},
        "direction": "DESCENDING"
      }
    ]
  }
}
```

---

## 🏆 Assessment & Skills API

### 1️⃣ Submit Assessment Answers

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/assessments`

**Body (JSON):**
```json
{
  "fields": {
    "userId": {"stringValue": "user_123"},
    "skillType": {"stringValue": "javascript"},
    "answers": {
      "mapValue": {
        "fields": {
          "q1": {"stringValue": "A"},
          "q2": {"stringValue": "C"},
          "q3": {"stringValue": "B"}
        }
      }
    },
    "score": {"doubleValue": 85.5},
    "badge": {"stringValue": "gold"},
    "completedAt": {"timestampValue": "2024-01-15T11:00:00Z"}
  }
}
```

---

### 2️⃣ Get User's Badge Progress

**Method:** `GET`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/users/{userId}/badges`

---

## ⭐ Reviews & Ratings API

### 1️⃣ Submit Review

**Method:** `POST`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/reviews`

**Body (JSON):**
```json
{
  "fields": {
    "projectId": {"stringValue": "proj_123"},
    "fromUserId": {"stringValue": "user_client"},
    "toUserId": {"stringValue": "user_freelancer"},
    "rating": {"doubleValue": 4.5},
    "comment": {"stringValue": "Excellent work, very professional!"},
    "communicationRating": {"doubleValue": 5},
    "qualityRating": {"doubleValue": 4},
    "deliveryRating": {"doubleValue": 5},
    "createdAt": {"timestampValue": "2024-01-15T11:15:00Z"}
  }
}
```

---

## 🎯 Smart Recommendations API

### 1️⃣ Get Recommended Users

**Method:** `GET`  
**URL:** `https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/databases/(default)/documents/recommendations?userId=user_123`

---

## 🔐 Authentication (Firebase)

### 1️⃣ Get ID Token

**Method:** `POST`  
**URL:** `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_API_KEY}`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "returnSecureToken": true
}
```

**cURL:**
```bash
curl -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "returnSecureToken": true
  }'
```

**Response Example:**
```json
{
  "idToken": "eyJhbGc...",
  "email": "user@example.com",
  "refreshToken": "xxxxx",
  "expiresIn": "3600"
}
```

---

### 2️⃣ Create New User

**Method:** `POST`  
**URL:** `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={FIREBASE_API_KEY}`

**Body (JSON):**
```json
{
  "email": "newuser@example.com",
  "password": "securePassword123",
  "returnSecureToken": true
}
```

---

## 📊 Test Data for Your Project

### User Object Example:
```json
{
  "id": "user_123",
  "email": "john@example.com",
  "displayName": "John Doe",
  "userType": "freelancer",
  "photoURL": "https://...",
  "skills": ["JavaScript", "React", "Node.js"],
  "hourlyRate": 50,
  "rating": 4.8,
  "completedProjects": 25,
  "totalEarnings": 5000
}
```

### Project Object Example:
```json
{
  "id": "proj_123",
  "title": "Mobile App Development",
  "description": "Build a cross-platform mobile app",
  "budget": 2500,
  "requiredSkills": ["React Native", "Firebase"],
  "createdBy": "user_client_id",
  "status": "in_progress",
  "createdAt": "2024-01-10T08:00:00Z"
}
```

---

## 🧪 Quick Test Workflow

### Step 1: Authenticate
- Get ID Token from Firebase

### Step 2: Create Payment Intent
- Use Stripe to create payment intent
- Store `client_secret` for frontend

### Step 3: Confirm Payment
- Use Stripe to confirm with card

### Step 4: Save Payment Record
- Store in Firestore with payment details

### Step 5: Create/Send Message
- Create message in Firestore
- Update conversation's lastMessage

### Step 6: Generate Video Token
- Get Twilio/Agora token
- Use in mobile app for video call

---

## ✅ Common Response Status Codes

| Code | Meaning |
|------|---------|
| 200 | ✅ Success |
| 201 | ✅ Created |
| 400 | ❌ Bad Request |
| 401 | ❌ Unauthorized |
| 403 | ❌ Forbidden |
| 404 | ❌ Not Found |
| 500 | ❌ Server Error |

---

## 🚀 Import to Postman

### Option 1: Create Manually
- Create new requests following templates above
- Save each as Collection

### Option 2: Use cURL
- Copy cURL commands
- In Postman: `Import` → `Paste Raw Text`

### Option 3: JSON Collection File
Create file `shecan-ai-postman.json` with:
```json
{
  "info": {
    "name": "Shecan AI APIs",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Stripe - Create Payment Intent",
      "request": {
        "method": "POST",
        "url": "https://api.stripe.com/v1/payment_intents"
      }
    }
  ]
}
```

---

## 📚 API Documentation Links

- **Stripe**: https://stripe.com/docs/api
- **Twilio**: https://www.twilio.com/docs/video/api
- **Agora**: https://docs.agora.io
- **OpenAI**: https://platform.openai.com/docs/api-reference
- **Firebase**: https://firebase.google.com/docs/firestore/use-rest-api

---

## ⚠️ Security Best Practices

1. **Never expose Secret Keys** in Postman collections
2. **Use environment variables** for sensitive data
3. **Create API Key restrictions** (Stripe, Firebase, etc.)
4. **Enable webhooks** for payment confirmations
5. **Test on staging** before production
6. **Use test data** when possible

