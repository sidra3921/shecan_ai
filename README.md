# SheCan AI

SheCan AI is an AI-powered skill-matching and micro-gig platform designed exclusively for women in Pakistan.

Many women possess valuable home-based skills, such as tailoring, handicrafts, baking, tutoring, and digital services, yet they often lack access to safe, supportive, and trustworthy marketplaces to monetize them. SheCan AI addresses this gap by enabling women to build skill-based profiles, showcase portfolios, and receive AI-driven recommendations for suitable micro-projects.

The platform uses intelligent matching algorithms to connect women with verified clients, while supporting secure in-app payments, transparent reviews, and mentorship opportunities.

By combining empowerment through technology, localized opportunities, and a women-friendly digital environment, SheCan AI bridges the gap between women’s skills and real market demand. The mission is to increase women’s participation in Pakistan’s digital economy while fostering financial independence and long-term skill growth.

## Methodology

### 1. User Selection Phase

The workflow starts with role selection. A user chooses whether she is joining as:

- Client
- Woman Service Provider (Mentor/Freelancer)

This role selection controls both feature access and platform behavior.

### 2. Client Journey

If the user selects Client, the flow is:

1. Login/signup
2. Preference and interest analysis (favorites, selected categories, location)
3. AI-powered gig recommendations (tailoring, crafts, coaching, baking, digital services, and related categories)
4. Provider discovery and trust checks (profile, portfolio, ratings, reviews)
5. Direct order placement through the platform

### 3. Woman Service Provider Journey

If the user selects Woman Service Provider, the flow is:

1. Login/signup with provider role
2. Build a skill-based profile (skills, bio, pricing, location, portfolio)
3. Receive AI-recommended micro-gig opportunities based on skills and relevance
4. Track gig activity (saved gigs, viewed gigs, applied interest)
5. Communicate with clients through in-app channels
6. Deliver services and build trust through verified reviews and ratings
7. Improve long-term growth through mentorship opportunities and continuous profile strengthening

### 4. Trust, Safety, and Role Separation

The platform follows strict role isolation and safety-first behavior:

- One email account is locked to one role type
- Client and provider features are separated by role
- Sensitive data access is restricted through backend policies
- In-app interactions prioritize transparency and user safety

### 5. AI Matching Logic (Platform Intent)

AI matching is designed to optimize relevance and outcomes by combining:

- Skill compatibility
- Category fit
- User preferences and interest signals
- Location relevance where required
- Quality indicators (ratings/reviews)

## Product Pillars

- Safe and women-friendly digital marketplace
- AI-based skill and gig matching
- Verified clients and trust-first interactions
- Secure transactions and transparent feedback
- Mentorship and long-term capability building

## Current Role Model (Implemented)

- Mentor and client accounts are separated by role.
- A single email is locked to one role type.
- Client and mentor navigation/features are role-gated.
- Backend hardening script is provided in SUPABASE_RLS_HARDENING.sql.
