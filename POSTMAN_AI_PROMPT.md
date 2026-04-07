# Postman AI Prompt - Shecan AI API Integration

**Copy this entire prompt and paste it into Postman AI, ChatGPT, or Claude:**

---

## Project Overview

I'm building **Shecan AI** - a Flutter mobile app for a freelancer and mentor marketplace (similar to Upwork + mentorship platform).

**Project Stack:**
- Frontend: Flutter (Dart)
- Backend: Firebase (Firestore, Auth, Storage, Messaging)
- Payment: Stripe
- Video: Twilio OR Agora
- AI: OpenAI (GPT-3.5-turbo)
- Backend APIs: Node.js/Express (optional)

---

## What I Need Help With

I need you to help me:

1. **Create Postman requests** for all major API integrations
2. **Set up environment variables** for testing
3. **Generate test cases** to verify each API works
4. **Provide cURL commands** I can use for quick testing
5. **Debug authentication issues** when they occur
6. **Optimize API request structure** for best performance

---

## My 8 Core Features (Tier 1)

### 1. **Real-Time Chat** (Firebase + WebSockets)
- Send/receive messages in real-time
- Read receipts
- Conversation history
- Files/attachments support

### 2. **Video Consultations** (Twilio or Agora)
- Schedule video calls
- Generate room tokens
- Record consultations
- Rating system post-call

### 3. **Skill Assessments** (Firebase)
- MCQ-based skill tests
- Auto-grading
- Badge system (Bronze/Silver/Gold/Platinum)
- Score tracking

### 4. **Payment Processing** (Stripe)
- Create payment intents
- Confirm payments with test cards
- Wallet system (freelancer earnings)
- Withdrawal requests
- Transaction history

### 5. **AI Resume Builder** (OpenAI)
- Generate professional resumes from profile data
- AI-powered suggestions
- Multiple versions
- PDF export

### 6. **AI Chat Bot** (OpenAI + Firebase)
- Answer freelancer questions
- Provide gig tips
- Help with payment issues
- Career advice

### 7. **Smart Recommendations** (Firestore + Algorithms)
- Recommend projects to freelancers
- Recommend mentors to users
- Trending gigs
- Personalized matches

### 8. **Enhanced Reviews & Fraud Detection** (Firestore)
- 5-star ratings
- Detailed feedback
- Fraud detection (5 heuristics)
- Moderation queue
- Helpful vote system

---

## API Credentials I Have

Please help me organize and test these:

```
STRIPE_SECRET_KEY: sk_test_YOUR_KEY_HERE
STRIPE_PUBLISHABLE_KEY: pk_test_YOUR_KEY_HERE

TWILIO_ACCOUNT_SID: AC_YOUR_SID_HERE
TWILIO_AUTH_TOKEN: YOUR_TOKEN_HERE

AGORA_APP_ID: YOUR_AGORA_ID_HERE
AGORA_CERTIFICATE: YOUR_CERT_HERE

OPENAI_API_KEY: sk-YOUR_KEY_HERE

FIREBASE_API_KEY: AIxxxxx_YOUR_KEY_HERE
FIREBASE_PROJECT_ID: shecan-ai-project
FIREBASE_DATABASE_URL: https://shecan-ai-project.firebaseio.com

JWT_SECRET: (for backend authentication if needed)
```

---

## Specific Help Needed

### A. Create Ready-to-Use Postman Requests For:

1. **Stripe** - Payment lifecycle:
   - Create payment intent → Confirm → Get status
   - Create customer → List charges
   - Refund payment

2. **Twilio** - Video:
   - Generate token for video room
   - List active rooms
   - End room session

3. **Agora** - Alternative video:
   - Generate RTC token
   - RTM token
   - List channels

4. **Firebase Auth** - User management:
   - Sign up / Sign in
   - Get ID token
   - Refresh token
   - Reset password

5. **Firebase Firestore** - Chat & Data:
   - Create conversation
   - Send message
   - Get messages (with pagination)
   - Mark message as read
   - Update user profile

6. **OpenAI** - AI features:
   - Generate resume
   - Chat completion
   - Transcribe audio

7. **Custom Backend** (if I build it):
   - Create project
   - Get recommendations
   - Submit assessment

### B. Set Up Postman Environment With:
- Test API keys in variables
- Base URLs for each service
- Auth headers templates
- Test data templates

### C. Create Test Scenarios:
- Happy path flow (success cases)
- Error handling (invalid data)
- Edge cases (missing fields)
- Authentication failures

### D. Provide Helper Scripts:
- Pre-request scripts (calculate signatures, timestamps)
- Post-request scripts (extract tokens, validate responses)
- Test assertions (verify status codes, response structure)

---

## Sample API Requests I Need

### 1. Stripe - Create Payment
```
POST https://api.stripe.com/v1/payment_intents
Headers: Authorization: Bearer {{stripe_secret_key}}
Body: amount=5000&currency=usd&payment_method_types[]=card
```

### 2. Firebase - Send Chat Message
```
POST https://firestore.googleapis.com/v1/projects/shecan-ai-project/databases/(default)/documents/conversations/{{conversationId}}/messages
Headers: Authorization: Bearer {{id_token}}
Body: { "fields": { "senderId": {"stringValue": "{{userId}}"}, "content": {"stringValue": "Hello"}, "timestamp": {"timestampValue": "2024-01-15T10:35:00Z"} } }
```

### 3. Twilio - Get Video Token
```
POST https://api.twilio.com/2010-04-01/Accounts/{{twilio_account_sid}}/Tokens
Auth: Basic {{twilio_account_sid}}:{{twilio_auth_token}}
Body: Identity=user123&VideoGrant={"room":"consultation_room"}
```

### 4. OpenAI - Generate Resume
```
POST https://api.openai.com/v1/chat/completions
Headers: Authorization: Bearer {{openai_api_key}}
Body: { "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Create resume for {{userProfile}}"}] }
```

---

## Testing Data You Can Generate

**User IDs:** user_123, user_client_abc, user_freelancer_xyz
**Project IDs:** proj_design_001, proj_coding_002
**Conversation IDs:** conv_chat_001
**Stripe Test Cards:**
- Success: 4242 4242 4242 4242
- Decline: 4000 0000 0000 9995
- 3D Secure: 4000 0025 0000 3155

---

## What I Want as Output

Please provide:

1. ✅ Complete Postman collection (JSON format) with all requests
2. ✅ Environment setup file with all variables
3. ✅ Step-by-step testing guide
4. ✅ cURL commands for each major operation
5. ✅ Error handling & troubleshooting tips
6. ✅ Security checklist (what NOT to do)
7. ✅ Performance optimization tips
8. ✅ Sample test data for each API

---

## Questions for You to Answer in Your Next Response

1. Should I test Twilio OR Agora first? (I want the cheaper option for mobile)
2. Do I need webhook setup for Stripe (for server-side payment confirmation)?
3. Should I set up a backend API wrapper around these services, or call them directly from Flutter?
4. How should I handle token expiration and refresh in Postman?
5. What's the best way to keep API keys secure in my Postman workspace?

---

## My Current Status

- ✅ Flutter app structure ready
- ✅ Firebase auth + Firestore set up
- ✅ All 50+ service methods coded (backend ready)
- ✅ Chat UI screen created
- ❌ NOT TESTED: Stripe payment flow
- ❌ NOT TESTED: Video consultation flow
- ❌ NOT TESTED: OpenAI integration
- ❌ NOT TESTED: Full end-to-end workflow

---

## Timeline

I need to:
1. Test all APIs in Postman (this week)
2. Fix any integration issues (next week)
3. Deploy to staging (week 3)
4. Go live to production (week 4)

---

## Additional Context

- This is a production app going to Apple App Store + Google Play Store
- I expect 1000+ users in first month
- Payment processing is critical (real money involved)
- Video quality matters (mentorship is core feature)
- Security is paramount (user data + payments)

Please help me ensure all APIs work perfectly before I integrate them into the Flutter app!
