Incident Report: Web Application Service Disruption
Introduction
This report details a significant security incident involving a Distributed Denial of Service (DDoS) attack targeted at our primary web application. The attack resulted in a total service outage, preventing legitimate users from accessing resources. The purpose of this document is to analyze the attack vectors, identify underlying vulnerabilities—specifically those that limited the server's resource usage—and propose a robust mitigation and monitoring strategy.

Detailed Attack Analysis

Attack Type: Volumetric Distributed Denial of Service (DDoS).

Source: A distributed botnet consisting of approximately 15,000 unique IP addresses globally.

Targeted Endpoints: The primary login page (/auth/login) and the search API (/api/v1/search).

Request Volume: Peak traffic reached 45 Gbps, with an average of 1.2 million Requests Per Second (RPS).

Tools Used: Analysis suggests a combination of customized HTTP flood scripts and the LOIC (Low Orbit Ion Cannon) toolset.

The Critical Limit: The attack successfully exhausted the Server's Bandwidth and CPU Interrupt Capacity. By flooding the API with complex search queries, the attacker forced the database to hit its Maximum Connection Limit, effectively locking out legitimate traffic.

Proposed Mitigation Strategy
To prevent a recurrence, we propose a multi-layered defense-in-depth approach:

Deployment of a Web Application Firewall (WAF): To filter malicious HTTP/S traffic and block known botnet patterns.

Implementation of Rate Limiting: Restricting the number of requests a single IP can make within a specific timeframe.

Content Delivery Network (CDN) Integration: Offloading static content and using Anycast routing to absorb volumetric spikes before they reach the origin server.

Auto-Scaling Infrastructure: Configuring the environment to spin up additional instances automatically when CPU or RAM thresholds are exceeded.

Justification for the Proposed Solution
Based on NIST SP 800-94 and industry best practices, a WAF combined with a CDN is the gold standard for mitigating application-layer attacks. Unlike simple firewall rules, this solution provides deep packet inspection, ensuring that "low and slow" attacks are caught alongside high-volume floods. This approach minimizes downtime and protects the server’s finite resources (CPU/RAM/Bandwidth) from exhaustion.

Steps for Implementation

Phase 1: Provision a cloud-based WAF (e.g., Cloudflare or AWS WAF) and point DNS records to the protected proxy.

Phase 2: Configure specific "Challenge" rules (JS Challenge/CAPTCHA) for the /api and /auth endpoints.

Phase 3: Update the web server configuration (Nginx/Apache) to implement server-side rate limiting as a secondary failover.

Phase 4: Conduct a controlled stress test to verify the effectiveness of the new limits.

Post-Implementation Monitoring
Ongoing security will be managed through:

SIEM Integration: Exporting WAF logs to a centralized dashboard for real-time anomaly detection.

Performance Metrics: Using tools like Prometheus and Grafana to monitor CPU usage, memory pressure, and 5xx error rates.

Synthetic Monitoring: Running automated scripts to check site availability from various global locations every 60 seconds.

Conclusion
The identified incident exploited the inherent physical limits of our server infrastructure. By implementing the proposed WAF and rate-limiting strategies, the organization will shift from a reactive to a proactive security posture. Protecting the availability of our web application is critical to maintaining user trust and operational continuity.
