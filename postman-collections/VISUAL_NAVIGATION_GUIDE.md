# 🗺️ VISUAL NAVIGATION GUIDE - Where to Click on Each Service

## 1️⃣ FIREBASE - Where to Find Your Keys

```
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE CONSOLE                          │
│                                                             │
│  https://console.firebase.google.com                        │
│                                                             │
│  MAIN DASHBOARD:                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Project Overview                                    │  │
│  │                                                     │  │
│  │ ⚙️ [GEAR ICON]  ← CLICK HERE                       │  │
│  │ (Next to "Project Overview" in top-left)          │  │
│  │                                                     │  │
│  │ Dropdown menu appears:                             │  │
│  │ ├─ Project settings ← CLICK THIS                   │  │
│  │ ├─ Project members                                 │  │
│  │ └─ Firestore rules                                 │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  AFTER CLICKING "Project Settings":                        │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Project Settings                                    │  │
│  │                                                     │  │
│  │ Tabs: General | Cloud Messaging | Integrations     │  │
│  │ Click "General" (usually already selected)          │  │
│  │                                                     │  │
│  │ You'll see:                                         │  │
│  │ • Project ID: shecan-ai-project ← COPY THIS       │  │
│  │ • Web API Key: AIza... ← COPY THIS                │  │
│  │                                                     │  │
│  │ Left sidebar: "Your apps"                          │  │
│  │ ├─ [YOUR_WEB_APP] ← Click to expand               │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  FOR DATABASE URL:                                         │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Left Sidebar Menu:                                  │  │
│  │                                                     │  │
│  │ Build                                               │  │
│  │ ├─ Firestore Database                              │  │
│  │ ├─ Realtime Database ← CLICK THIS                  │  │
│  │ └─ Cloud Storage                                    │  │
│  │                                                     │  │
│  │ Realtime Database Page:                            │  │
│  │ URL: https://shecan-ai-project.firebaseio.com      │  │
│  │                      ↑↑↑ COPY THIS ↑↑↑             │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

SUMMARY:
✓ API Key:      From Project Settings → General tab
✓ Project ID:   From Project Settings → General tab
✓ Database URL: From Realtime Database page
```

---

## 2️⃣ STRIPE - Where to Find Your Keys

```
┌─────────────────────────────────────────────────────────────┐
│                    STRIPE DASHBOARD                         │
│                                                             │
│  https://dashboard.stripe.com                              │
│                                                             │
│  IMPORTANT: CHECK TEST MODE IS ON                          │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Top Right Corner:                                   │  │
│  │                                                     │  │
│  │ [Test mode ●] ← Should be BLUE/ON                 │  │
│  │ [Live mode]   ← Stay OFF for development           │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  FIND YOUR KEYS:                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Top Menu:                                           │  │
│  │                                                     │  │
│  │ Dashboard | Payments | Developers | ...            │  │
│  │                                      ↓              │  │
│  │          CLICK "Developers" ← HERE                 │  │
│  │                                                     │  │
│  │ Submenu:                                            │  │
│  │ ├─ API Keys ← CLICK THIS                            │  │
│  │ ├─ Webhooks                                         │  │
│  │ └─ Documentation                                    │  │
│  │                                                     │  │
│  │ API Keys Page Shows:                                │  │
│  │ ┌────────────────────────────────────────────────┐ │  │
│  │ │ Secret Key                                     │ │  │
│  │ │ sk_test_[random characters]                    │ │  │
│  │ │                            ↑↑↑ COPY ↑↑↑      │ │  │
│  │ │                                                │ │  │
│  │ │ Publishable Key                                │ │  │
│  │ │ pk_test_[random characters]                    │ │  │
│  │ │                          ↑↑↑ COPY ↑↑↑        │ │  │
│  │ └────────────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

⚠️ CRITICAL: Make sure you copy keys from TEST MODE section
             NOT LIVE MODE section!
             
SUMMARY:
✓ Secret Key:       From Developers → API Keys (starts with sk_test_)
✓ Publishable Key:  From Developers → API Keys (starts with pk_test_)
```

---

## 3️⃣ TWILIO - Where to Find Your Keys

```
┌─────────────────────────────────────────────────────────────┐
│                    TWILIO CONSOLE                           │
│                                                             │
│  https://console.twilio.com                                │
│  https://www.twilio.com/try-twilio ← If new account       │
│                                                             │
│  MAIN DASHBOARD VIEW:                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Welcome to Twilio Console                           │  │
│  │                                                     │  │
│  │ [Account Info] [Programmable SMS] [Video] [...]    │  │
│  │                                                     │  │
│  │ RIGHT SIDE - Your Keys (most important!):          │  │
│  │ ┌───────────────────────────────────────────────┐ │  │
│  │ │ Account Info                                  │ │  │
│  │ │                                               │ │  │
│  │ │ Account SID:                                  │ │  │
│  │ │ AC1234567890abcdefghijklmnopqrstuv            │ │  │
│  │ │              ↑↑↑ COPY THIS ↑↑↑               │ │  │
│  │ │                                               │ │  │
│  │ │ Auth Token:                                   │ │  │
│  │ │ 🔒 ••••••••••••••••••••••••••••              │ │  │
│  │ │     [👁️ Eye icon] ← CLICK TO REVEAL          │ │  │
│  │ │                                               │ │  │
│  │ │ After clicking eye icon:                      │ │  │
│  │ │ a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6             │ │  │
│  │ │                      ↑↑↑ COPY THIS ↑↑↑        │ │  │
│  │ │                                               │ │  │
│  │ └───────────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  OPTIONAL - ENABLE VIDEO (if needed):                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Left Sidebar Menu:                                  │  │
│  │                                                     │  │
│  │ Products                                            │  │
│  │ ├─ Programmable SMS                                │  │
│  │ ├─ Programmable Voice                              │  │
│  │ ├─ Video ← CLICK HERE                              │  │
│  │ └─ ...                                              │  │
│  │                                                     │  │
│  │ Click to enable Video API for your account         │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

SUMMARY:
✓ Account SID: Right side of Dashboard (starts with AC)
✓ Auth Token: Right side of Dashboard (click 👁️ to reveal)
```

---

## 4️⃣ AGORA - Where to Find Your Keys

```
┌─────────────────────────────────────────────────────────────┐
│                     AGORA CONSOLE                           │
│                                                             │
│  https://console.agora.io                                  │
│                                                             │
│  STEP 1: CREATE PROJECT                                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ After signup, click "Project" in left sidebar       │  │
│  │                                                     │  │
│  │ Left Menu:                                          │  │
│  │ ├─ Dashboard                                        │  │
│  │ ├─ Project ← CLICK HERE                            │  │
│  │ ├─ Document                                         │  │
│  │ └─ ...                                              │  │
│  │                                                     │  │
│  │ Main Area:                                          │  │
│  │ [Create] [Manage] [Region]                         │  │
│  │                                                     │  │
│  │ Click [Create] button                              │  │
│  │                                                     │  │
│  │ Fill in:                                            │  │
│  │ • Project name: shecan-ai-video                     │  │
│  │ • Use case: Real-time communication                 │  │
│  │                                                     │  │
│  │ Click "Create" → Project created!                  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  STEP 2: GET APP ID                                        │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Your new project appears in the list               │  │
│  │                                                     │  │
│  │ Project Name | App ID                              │  │
│  │ shecan-ai.. | a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6   │  │
│  │                           ↑↑↑ COPY THIS ↑↑↑        │  │
│  │                                                     │  │
│  │ Or click project name to open details page         │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  STEP 3: GET API KEY FROM CONFIG                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Click your project → Details page opens            │  │
│  │                                                     │  │
│  │ Tabs: Key | RTC | RTM | Cloud Recording           │  │
│  │                 ↓                                   │  │
│  │ Look for "Config" or "Main Config"                 │  │
│  │                                                     │  │
│  │ You'll see an existing API Key or                  │  │
│  │ A "Generate" button to create one                  │  │
│  │                                                     │  │
│  │ Copy/Generate API Key:                             │  │
│  │ b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u          │  │
│  │                              ↑↑↑ COPY ↑↑↑          │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

SUMMARY:
✓ App ID:    From Project list page (hex string)
✓ API Key:   From Config section (click Generate if needed)
```

---

## 5️⃣ OPENAI - Where to Find Your Key

```
┌─────────────────────────────────────────────────────────────┐
│                    OPENAI PLATFORM                          │
│                                                             │
│  https://platform.openai.com                               │
│                                                             │
│  STEP 1: SIGN UP & VERIFY                                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ https://platform.openai.com/signup                 │  │
│  │                                                     │  │
│  │ 1. Enter email                                      │  │
│  │ 2. Create password                                  │  │
│  │ 3. Verify email (check inbox)                      │  │
│  │ 4. Add phone number (may be required)              │  │
│  │ 5. Verify phone (get code via SMS)                 │  │
│  │ 6. Login                                            │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  STEP 2: ADD PAYMENT METHOD ⚠️ REQUIRED                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Top Right - Click your profile:                     │  │
│  │                                                     │  │
│  │ [Profile Icon] ↓ (top-right corner)               │  │
│  │ ├─ Account                                          │  │
│  │ ├─ Billing overview ← CLICK THIS                   │  │
│  │ ├─ API keys                                         │  │
│  │ └─ Settings                                         │  │
│  │                                                     │  │
│  │ On Billing Overview:                               │  │
│  │ Look for "Add payment method" or "Billing"         │  │
│  │ Click "Add to account"                             │  │
│  │                                                     │  │
│  │ Fill in credit card:                               │  │
│  │ • Card number: ____________________________         │  │
│  │ • Expiry: MM/YY                                     │  │
│  │ • CVC: ___                                          │  │
│  │ • Billing zip: _______                             │  │
│  │                                                     │  │
│  │ Click "Save"                                        │  │
│  │                                                     │  │
│  │ Set Usage Limits (optional but recommended):        │  │
│  │ • Hard limit: $20/month                             │  │
│  │ • Soft limit: $10/month                             │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  STEP 3: CREATE API KEY                                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Click profile icon (top-right)                      │  │
│  │                                                     │  │
│  │ [Profile Icon] ↓                                   │  │
│  │ ├─ Account                                          │  │
│  │ ├─ Billing overview                                 │  │
│  │ ├─ API keys ← CLICK THIS                           │  │
│  │ └─ Settings                                         │  │
│  │                                                     │  │
│  │ API Keys Page:                                      │  │
│  │ [Create new secret key] ← CLICK THIS BUTTON        │  │
│  │                                                     │  │
│  │ Modal appears:                                      │  │
│  │ Name: Shecan AI Development                        │  │
│  │ [Create secret key]                                 │  │
│  │                                                     │  │
│  │ KEY IS SHOWN ONLY ONCE! Copy immediately:         │  │
│  │ ┌─────────────────────────────────────────────────┐│  │
│  │ │ sk-proj-1a2b3c4d5e6f7g8h9i0j...                ││  │
│  │ │                       ↑↑↑ COPY IMMEDIATELY ↑↑↑ ││  │
│  │ │                                                 ││  │
│  │ │ ⚠️  If you close this, you CAN'T retrieve it!  ││  │
│  │ │    Screenshot or save to password manager!      ││  │
│  │ └─────────────────────────────────────────────────┘│  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

⚠️ CRITICAL: API Key shown ONLY ONCE!
             Copy immediately or regenerate

SUMMARY:
✓ API Key: From API keys section (click Create new secret key)
✓ Requires: Payment method must be added first
```

---

## 🎯 POSTMAN - Where to Click

```
┌─────────────────────────────────────────────────────────────┐
│                      POSTMAN INTERFACE                      │
│                                                             │
│  WHEN FIRST OPENING POSTMAN:                               │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Top-left area:                                      │  │
│  │                                                     │  │
│  │ [Create] [Import] [Share] [...]                    │  │
│  │           ↑↑↑ CLICK THIS ↑↑↑                       │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  IMPORT DIALOG:                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ File | Folder | Link | Paste raw text             │  │
│  │ ↑↑↑ CLICK FILE ↑↑↑                                │  │
│  │                                                     │  │
│  │ [Upload Files] button                              │  │
│  │ Select: shecan-ai-collection.json                  │  │
│  │ Click [Open]                                        │  │
│  │ Click [Import]                                      │  │
│  │                                                     │  │
│  │ Then repeat for shecan-ai-environment.json         │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  AFTER IMPORT:                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │ Left Sidebar       |  Main Area        | Right     │  │
│  │ ┌──────────────┐   |  ┌─────────────┐ |  ┌───────┐ │  │
│  │ │ Collections  │   |  │   Request   │ |  │ Tests │ │  │
│  │ │ ┌─────────┐  │   |  │   Details   │ |  │       │ │  │
│  │ │ │ 🔐 Auth │  │   |  │             │ |  │       │ │  │
│  │ │ │ 💬 Chat │  │   |  │             │ |  │       │ │  │
│  │ │ │ 💳 Pay  │  │   |  │ [Send]      │ |  │       │ │  │
│  │ │ │ 📹 Video│  │   |  │             │ |  │       │ │  │
│  │ │ │ 🤖 AI   │  │   |  │             │ |  │       │ │  │
│  │ │ │ ...     │  │   |  │             │ |  │       │ │  │
│  │ │ └─────────┘  │   |  │             │ |  │       │ │  │
│  │ └──────────────┘   |  │             │ |  │       │ │  │
│  │                    |  └─────────────┘ |  └───────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  TOP RIGHT AREA:                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │ [No Environment ▼] [👁️ eye] [Folder]              │  │
│  │                ↑↑↑ CLICK THIS ↑↑↑                 │  │
│  │                                                     │  │
│  │ Select: "Shecan AI - Development Environment"      │  │
│  │                                                     │  │
│  │ Then click 👁️ → Click "Edit"                      │  │
│  │ Add your API keys in the modal                      │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  SENDING A REQUEST:                                        │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ 1. Expand folder in left sidebar                    │  │
│  │ 2. Click request name                               │  │
│  │ 3. Review the request details                       │  │
│  │ 4. Click [Send] button (top right of main area)     │  │
│  │ 5. See response below the request                   │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

SUMMARY:
✓ Import Collection: Top-left [Import] → Select JSON file
✓ Select Environment: Top-right dropdown
✓ Add API Keys: Click 👁️ → Edit environment
✓ Send Request: Expand folder → Click request → [Send]
```

---

## ✅ COMPLETE CHECKLIST - Where to Click

| Step | Service | Where to Go | What to Look For |
|------|---------|------------|------------------|
| 1 | Firebase | console.firebase.google.com | ⚙️ gear icon → Project settings |
| 2 | Firebase | Project Settings page | Web API Key, Project ID |
| 3 | Firebase | Realtime Database | Database URL (https://...) |
| 4 | Stripe | dashboard.stripe.com | Toggle TEST MODE on |
| 5 | Stripe | Developers → API keys | Secret Key (sk_test_), Public Key (pk_test_) |
| 6 | Twilio | console.twilio.com | Account SID + Auth Token on dashboard |
| 7 | Agora | console.agora.io | Create Project → Get App ID |
| 8 | Agora | Project Config | Generate API Key |
| 9 | OpenAI | platform.openai.com | Add payment method first! |
| 10 | OpenAI | API keys section | Create new secret key (copy immediately!) |
| 11 | Postman | Click [Import] | Select shecan-ai-collection.json |
| 12 | Postman | Click [Import] | Select shecan-ai-environment.json |
| 13 | Postman | Environment dropdown (top-right) | Select "Shecan AI - Development Environment" |
| 14 | Postman | Click 👁️ → Edit | Paste all 10 API keys |
| 15 | Postman | Left sidebar → 🔐 Authentication | Click "1. Sign Up" → Send → Should see 200 OK |

---

**Keep this guide handy while setting up!** 📌
