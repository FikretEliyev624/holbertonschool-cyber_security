# Security Assessment Report: CyberBank Financial Platform
**Date:** March 28, 2026  
**Subject:** Discovery and Exploitation of IDOR and Logic Flaws

---

## 1. Introduction
This report outlines the findings of a comprehensive security assessment conducted on the CyberBank application. The objective was to identify potential vulnerabilities in the handling of user data and transaction processing.

## 2. Methodology
The assessment utilized manual penetration testing with **Burp Suite Professional** for request interception and modification. Focus areas included API authorization and financial transaction logic.

---

## 3. Vulnerability Findings

### 3.1. Discovery of User IDs and Profile IDOR (Flag 0)
* **Vulnerability:** Insecure Direct Object Reference (IDOR).
* **Impact:** High. Disclosure of PII (Full name, username, financial summary) of any customer.
* **Exploitation:** By iterating UUIDs in the `/api/customer/info/` endpoint, data for user Megan White was successfully retrieved.
* **Evidence (Flag 0):** `12fb9acad3dfb72866b3fb0a4f5ea407`

### 3.2. Account Enumeration and Balance Exposure (Flag 1)
* **Vulnerability:** Unauthorized access to account-level objects via predictable/discovered identifiers.
* **Impact:** Critical. Exposure of account balances, routing numbers, and transaction paths.
* **Exploitation:** Accessing `/api/accounts/` with a target user ID allowed full disclosure of financial details for account `102367163623`.
* **Evidence (Flag 1):** `bf1a298f72df216dff6a315fee7aa5a1`

### 3.3. Financial Logic Flaw - Balance Inflation (Flag 2)
* **Vulnerability:** Lack of server-side validation for negative transaction amounts.
* **Impact:** Critical. Unauthorized generation of funds and account balance manipulation.
* **Exploitation:** A negative amount transfer request was sent, causing the server to add funds to the sender's balance (Yosri Musk) instead of deducting them, reaching a total over $50K.
* **Evidence (Flag 2):** `fe0220749b739358e920bf4230474793`

### 3.4. 3D Secure Authorization Bypass (Flag 3)
* **Vulnerability:** Parameter tampering in the payment confirmation flow.
* **Impact:** Critical. Ability to authorize unauthorized charges on third-party cards.
* **Exploitation:** By intercepting the `/api/cards/confirm_payment/` request, the `number` parameter was diverted to a target card while utilizing a valid OTP context, successfully upgrading the account.
* **Evidence (Flag 3):** `e364ac892b86210cb89a367d4d81cac1`

---

## 4. Remediation Recommendations
1. **Enforce Authorization Checks:** Implement server-side verification to ensure the authenticated user owns the resource being accessed.
2. **Input Sanitization:** Strictly validate all transaction amounts to be positive integers.
3. **Cryptographic Binding:** Ensure 3D Secure transactions are cryptographically bound to the initiating card and session to prevent redirection.

## 5. Conclusion
The CyberBank application exhibits several critical flaws that jeopardize customer data and financial integrity. Immediate remediation is required to prevent real-world exploitation.
