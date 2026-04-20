# Submission 8: Final Legal Compliance Report

Date: 2026-04-15
Project: SheCan AI

## 1. Executive Verdict

Current status: **Partially legally safe, but not yet production-legally safe**.

The system has strong technical privacy/security foundations (especially role separation and Supabase RLS) but still lacks mandatory legal/compliance controls required for launch in most jurisdictions (privacy policy, terms acceptance, DSAR/account deletion workflow, moderation framework, and stronger secret handling).

## 2. What Is Already Legally Strong

### A. Access Control and Data Isolation

- Row-Level Security (RLS) is enabled for key tables (`users`, `projects`, `messages`, `notifications`, `payments`, `disputes`, `reviews`, `project_applications`, `mentor_gigs`).
- Policies enforce per-user or participant-level access for most sensitive entities.
- Role-based separation is implemented at authentication and app navigation levels (mentor vs client).
- One-email/one-role lock behavior exists in auth logic, reducing identity confusion and cross-role misuse.

### B. Payment and Record-keeping Intent

- The app configuration includes retention intent for payment records (`2555` days, ~7 years), which aligns with common financial record retention expectations.

### C. Security Awareness in Codebase

- Configuration comments explicitly warn against committing real secrets and recommend secure storage.

## 3. Legal Gaps and Risk Areas

### High Risk (must fix before launch)

1. **No enforceable legal policy flow in product UX**
- No implemented Privacy Policy / Terms of Service acceptance capture at sign-up.
- No versioned consent log proving what each user accepted and when.

2. **No data-subject rights workflow (privacy law core requirement)**
- No implemented in-app flow for account deletion, data export, or erasure request tracking.
- This creates GDPR/UK-GDPR style compliance risk and weakens trust for any privacy-regulated deployment.

3. **Sensitive data may be publicly exposed via storage URLs**
- Storage service returns public URLs for profile photos, project media, documents, and videos.
- If bucket policies are permissive, this can expose personal data/content and violate confidentiality commitments.

4. **Secrets and environment handling are not production-safe yet**
- `main.dart` includes hardcoded Supabase URL/key values.
- `app_config.dart` includes client-side placeholders for secret-style keys (e.g., Stripe secret key), which must never be used client-side.

5. **Content safety / abuse moderation controls are incomplete**
- UI has placeholders (e.g., blocked users) but no concrete moderation/reporting pipeline is implemented.
- For a women-focused marketplace, missing anti-harassment enforcement creates legal and safeguarding exposure.

### Medium Risk (should fix before scale)

6. **Data retention is declared but not operationalized**
- Retention constants exist, but no verified scheduled deletion/anonymization jobs are present.

7. **Schema-drift resilience may hide governance issues**
- The prune-and-retry pattern keeps app flows running when columns are missing.
- Operationally useful, but it can silently skip fields that may be needed for compliance/audit unless monitored.

8. **Documentation status is incomplete**
- Existing summary/setup markdown files are empty in this workspace snapshot, reducing audit-readiness.

## 4. Is the System Legally Safe Today?

**Answer:** Not fully.

It is **technically safer than many early-stage apps** because RLS and role isolation are in place. However, legal compliance is not only about backend access control. Without policy acceptance records, data-rights workflows, robust secret management, and moderation enforcement, the system is **not yet legally safe for production launch**.

## 5. Required Improvements (Priority Plan)

## Phase 1 (Immediate: Blocker fixes before production)

1. Publish and link legal documents
- Privacy Policy
- Terms of Service
- Community Guidelines / Safety Policy
- Cookie/Tracking disclosure (if analytics/SDK tracking is enabled)

2. Add consent capture and evidence
- Mandatory checkbox acceptance during signup.
- Store `policy_version`, `accepted_at`, `accepted_ip` (where lawful), and user ID.
- Require re-consent on policy updates.

3. Implement user rights operations
- In-app account deletion request.
- Data export request (machine-readable format).
- Admin workflow and SLA tracking for DSAR requests.

4. Lock down storage confidentiality
- Use private buckets for user-generated and sensitive files.
- Replace public URLs with signed URLs where needed.
- Add strict storage policies by owner/role.

5. Remove secret-style values from client code
- Keep only public keys in client.
- Move secret keys and privileged operations to server/edge functions.

## Phase 2 (Near term: compliance hardening)

6. Add moderation and trust/safety operations
- Report/block/mute workflows.
- Admin review queue and escalation process.
- Repeat-offender controls and evidence retention policy.

7. Enforce retention in backend jobs
- Scheduled deletion/anonymization for messages and non-required personal data.
- Keep finance records based on legal retention rules.

8. Strengthen logging and auditability
- Security event logs (auth events, policy acceptance, admin actions).
- Tamper-evident audit trail for disputes and payment events.

## Phase 3 (Before expansion/regulatory scrutiny)

9. Formal governance
- Data Processing Agreement (if using third-party processors).
- Incident response plan and breach notification runbook.
- DPIA-style privacy risk review for AI recommendations and profiling.
- Age policy and parental consent logic (if minors could onboard).

## 6. Final Conclusion

SheCan AI is on a strong **technical foundation** for privacy-by-design (notably Supabase RLS and role isolation), but it is **not yet fully legally compliant for production deployment**.

If Phase 1 is completed, legal risk drops significantly and the platform can move toward a safer launch posture. Phase 2 and 3 are required for durable, audit-ready compliance as user volume and regulatory exposure increase.

---

This report is a product/compliance engineering assessment and not formal legal advice. A qualified lawyer should review jurisdiction-specific obligations before launch.