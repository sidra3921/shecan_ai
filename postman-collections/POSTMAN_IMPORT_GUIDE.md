# Postman Collection Import Guide

## ✅ Files Created

Two ready-to-import files have been created in `postman-collections/`:

1. **shecan-ai-collection.json** - Complete API collection with 20+ requests
2. **shecan-ai-environment.json** - Environment variables for all APIs

---

## 🚀 Quick Start (3 Steps)

### Step 1: Open Postman
1. Download Postman from https://www.postman.com/downloads/
2. Create a free account or login
3. Create a new workspace (File → Create Workspace)

### Step 2: Import Collection
1. Click **Import** button (top-left)
2. Select **File** tab
3. Choose `shecan-ai-collection.json`
4. Click **Import**

### Step 3: Import Environment
1. Click **Import** button again
2. Choose `shecan-ai-environment.json`
3. Select the environment from the dropdown (top-right)

---

## 🔑 Add Your API Keys

**IMPORTANT:** Replace all placeholder values with your actual keys:

### Firebase
- Go to: https://console.firebase.google.com
- Select project → Settings (gear icon) → Service Accounts
- Copy your **API Key**, **Project ID**, **Database URL**
- Paste into environment variables:
  ```
  firebase_api_key: AIxxx...
  firebase_project_id: shecan-ai-project
  firebase_database_url: https://...
  ```

### Stripe
- Go to: https://dashboard.stripe.com/apikeys
- Copy **Secret Key** (starts with `sk_test_`)
- Copy **Publishable Key** (starts with `pk_test_`)
- Paste into:
  ```
  stripe_secret_key: sk_test_...
  stripe_publishable_key: pk_test_...
  ```

### Twilio
- Go to: https://console.twilio.com
- Copy **Account SID** and **Auth Token**
- Paste into:
  ```
  twilio_account_sid: AC...
  twilio_auth_token: ...
  ```

### Agora (if using instead of Twilio)
- Go to: https://console.agora.io
- Copy **App ID** and **API Key**
- Paste into:
  ```
  agora_app_id: ...
  agora_api_key: ...
  ```

### OpenAI
- Go to: https://platform.openai.com/api-keys
- Create new API key
- Paste into:
  ```
  openai_api_key: sk-...
  ```

---

## ✅ Testing Sequence (Recommended Order)

### Week 1 Testing Schedule

**Day 1: Authentication & Chat**
```
1. Auth → Sign Up (Create User)
2. Auth → Sign In (Login) ← Saves ID token automatically
3. Chat → Create Conversation
4. Chat → Send Message
5. Chat → Get Messages
```

**Day 2: Payments**
```
1. Stripe → Create Payment Intent ← Saves intent ID
2. Stripe → Confirm Payment (use 4242 4242 4242 4242)
3. Stripe → Get Payment Status ← Should show "succeeded"
4. Stripe → Create Customer
5. Stripe → List Charges
```

**Day 3: Video**
```
Option A (Twilio):
1. Twilio → Generate Video Room Token ← Saves token
2. Twilio → List Active Rooms

Option B (Agora):
1. Agora → Generate RTC Token
2. Agora → List Active Channels
```

**Day 4: AI Features**
```
1. OpenAI → Generate AI Resume
2. OpenAI → Chat Bot Query
3. OpenAI → Transcribe Audio (if you have sample audio)
```

**Day 5: Assessments & Reviews**
```
1. Assessments → Submit Assessment
2. Assessments → Get User Badges
3. Reviews → Submit Review
4. Reviews → Get User Reviews
```

**Day 6: Recommendations**
```
1. Recommendations → Get Recommended Projects
2. Recommendations → Get Trending Gigs
```

---

## 🧪 Test Cards & Data

### Stripe Test Cards
- **Success:** `4242 4242 4242 4242` (Any future date, any CVC)
- **Decline:** `4000 0000 0000 9995`
- **3D Secure:** `4000 0025 0000 3155`

### Test User Data
```
User 1 (Client):
- ID: user_client
- Email: client@example.com
- Name: John Client

User 2 (Freelancer):
- ID: user_freelancer
- Email: freelancer@example.com
- Name: Jane Freelancer

Test Project:
- ID: proj_design_001
- Title: Website Design Project
- Budget: $5000

Test Conversation:
- ID: conv_chat_001
- Type: Project Discussion
```

---

## 🔴 Common Issues & Solutions

### Issue 1: "Unauthorized" Error on API Calls
**Problem:** API keys are not set or are wrong
**Solution:** 
1. Double-check you copied the key correctly (no spaces)
2. Use the **exact key format** (sk_test_ for Stripe, etc.)
3. Make sure the environment is **selected** (dropdown, top-right)

### Issue 2: Stripe Test Card Declined
**Problem:** You're using a declined test card
**Solution:** Use `4242 4242 4242 4242` for successful tests

### Issue 3: Video Token Generation Returns Error
**Problem:** Twilio credentials are wrong or service is not enabled
**Solution:**
1. Verify Account SID and Auth Token from Twilio console
2. Enable Video API in Twilio
3. Check that you have valid Video Resource

### Issue 4: Firebase Auth Returns 400 Error
**Problem:** Wrong request format or invalid JSON
**Solution:**
1. Check email format is valid
2. Check password is at least 6 characters
3. Look at the error message for details

### Issue 5: OpenAI Returns 401 Error
**Problem:** API key is invalid or expired
**Solution:**
1. Go to https://platform.openai.com/api-keys
2. Regenerate API key
3. Make sure key starts with `sk-`

---

## 📊 Understanding Responses

Every API request returns a status and data:

### ✅ Success Responses (200/201)
- Status: `200 OK` or `201 Created`
- Body: Contains the data you requested
- Action: Save IDs from response (like `payment_intent_id`)

### ❌ Error Responses (400/401/403/500)
- Status: Error code
- Body: Contains error message
- Action: Read error message and fix the issue

### Example - Successful Login
```json
{
  "idToken": "eyJhbGc...",
  "email": "user@example.com",
  "refreshToken": "AEu...",
  "expiresIn": "3600"
}
```
The **idToken** is automatically saved to the environment by the test script!

---

## 🔐 Security Best Practices

### ✅ DO:
- ✅ Use separate environments for Dev/Staging/Production
- ✅ Rotate API keys regularly
- ✅ Revoke old keys when creating new ones
- ✅ Use environment-specific keys
- ✅ Enable IP whitelisting where available

### ❌ DON'T:
- ❌ Share your postman-environment.json file with others
- ❌ Commit real API keys to Git
- ❌ Use test keys in production
- ❌ Share API keys in chat or email
- ❌ Use weak/default credentials

---

## 🎯 Next Steps After Testing

### If All Tests Pass ✅
1. Document any special headers or auth needed
2. Save request examples for reference
3. Share collection with team (without sensitive keys)
4. Start integrating APIs into Flutter code
5. See `TIER1_QUICK_START.md` for integration patterns

### If Tests Fail ❌
1. Check error message in response body
2. Review the request (method, URL, headers, body)
3. Verify API keys are correct
4. Check service status (is API up?)
5. Review API documentation for latest changes

---

## 📚 Useful Resources

- **Postman Docs:** https://learning.postman.com/
- **Firebase Documentation:** https://firebase.google.com/docs
- **Stripe Documentation:** https://stripe.com/docs/api
- **Twilio Documentation:** https://www.twilio.com/docs
- **Agora Documentation:** https://docs.agora.io/
- **OpenAI Documentation:** https://platform.openai.com/docs/

---

## 📋 Checklist Before Going Live

- [ ] All API keys added to environment
- [ ] All requests tested and returning 200/201
- [ ] Authentication flow works (login → token received)
- [ ] Payment processing works with test card
- [ ] Video token generates successfully
- [ ] Chat messages send/receive correctly
- [ ] OpenAI queries return valid responses
- [ ] Error handling is clear and actionable
- [ ] Collection shared with team members
- [ ] Documentation updated with findings
- [ ] Security review completed
- [ ] Ready to integrate into Flutter app!

---

## 💡 Pro Tips

1. **Save Responses:** Right-click request → Save response as example (shows in documentation)
2. **Create Tests:** Add assertions like `pm.expect(response.status).to.equal(200)`
3. **Use Pre-scripts:** Calculate signatures or timestamps before sending
4. **Monitor APIs:** Set up Postman monitoring to test on schedule
5. **Run Collections:** Use Collection Runner to test entire flow sequentially
6. **Export for Docs:** Use Postman to generate API documentation automatically

---

## Questions?

If you encounter issues:
1. Check the response body for error details
2. Review the API documentation
3. Verify your API keys are correct
4. Make sure environment is selected
5. Check network connectivity

Good luck with your API testing! 🚀
