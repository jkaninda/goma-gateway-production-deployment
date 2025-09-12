#  Goma Gateway Production Deployment

Goma Gateway is a modern, developer-friendly API Gateway built for simplicity, security, and scale. More than just a reverse proxy, it streamlines service infrastructure management with declarative configuration and enterprise-grade features.

Goma Gateway Github: https://github.com/jkaninda/goma-gateway

## Quickstart Guide – Goma Gateway Production Deployment

This guide walks you through deploying **Goma Gateway** with monitoring, caching, and example applications in a production-like setup.

---

## 1. Requirements

Make sure you have installed:

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Basic knowledge of Reverse Proxies and DNS

---

## 2. Clone the Repository

```sh
git clone https://github.com/jkaninda/goma-gateway-production-deployment.git deployments
cd deployments
```

---

## 3. Setup Virtual Hosts / Subdomains

Decide which domains or subdomains you will use. Update your DNS or `/etc/hosts` accordingly.

For example:

* Grafana → `grafana.example.com`
* Okapi Example → `okapi.example.com`
* WordPress → `wordpress.example.com`
* Metrics → `metrics.example.com` *(optional, you can also expose metrics on any route under `/metrics`)*

---

## 4. Create a Shared Docker Network

All services will run on the same Docker network for easy communication:

```sh
docker network create web
```

---

## 5. Configure Goma Gateway Routes

Edit the routes file:

```sh
nano gateway/extra/routes.yaml
```

Add your applications’ routes.

Content of the routes file: `gateway/extra/routes.yaml`

```yaml
# ================================
# Route Configuration
# ================================
# routes can be defined in multiple files,
# just make sure the files are in the directory defined in extraConfig
routes:
  - name: okapi-example
    methods: [] # Empty array means all methods are allowed
    hosts: 
       - okapi.example.com
    path: /
    rewrite: / # Rewrite to the target
    target: http://okapi-example:8080
    # Middlewares are executed in the order they are defined
    middlewares:
      - enforceHttps # ensures all traffic is redirected to HTTPS.
      #- rate-limit  # Uncomment to enable rate limiting

  - name: wordpress
    methods: []
    hosts: 
       - wordpress.example.com
    path: /
    target: http://wordpress:80
    middlewares:
      - enforceHttps
      #- rate-limit  # Uncomment to enable rate limiting

  - name: grafana
    hosts:
      - grafana.example.com
    path: /
    target: http://grafana:3000
    #disableMetrics: true # Uncomment to disable metrics collection for this route
    middlewares:
      - enforceHttps # ensures all traffic is redirected to HTTPS.
```

💡 **Tip**: You can split routes into multiple files when `extraConfig` and `watch` are enabled in `goma.yml`. Goma Gateway will automatically reload on changes — no restart needed.
Ideal for GitOps workflows!

⚡ **Redis Support**:
Redis is optional. Goma Gateway provides in-memory rate limiting and caching out of the box, but Redis is **recommended** for production setups to ensure persistence, scalability, and efficient distributed rate limiting.

⚡ **TLS Certificates**:

To enable **Let’s Encrypt** with Goma Gateway, add your email address under the `certManager` section in the `goma.yml` config.
Goma Gateway will automatically request, manage, and renew TLS certificates for you.

```yaml
certManager:
  acme:
    ## Add your email to enable Let's Encrypt (required by ACME)
    email: admin@example.com  # Contact email for ACME registration
    storageFile: /etc/letsencrypt/acme.json
```

## 6. Start the Stacks

Run all services:

```sh
sh deploy.sh all
```

If you can’t run `deploy.sh` or are unsure, you can also start services manually:

```sh
docker compose up -d
```

Check logs:

```sh
docker compose logs -f
```

---

## 7. Verify the Deployment

Open the following in your browser:

* [https://grafana.example.com](https://grafana.example.com) → Grafana dashboard
* [https://okapi.example.com](https://okapi.example.com) → Okapi example app
* [https://wordpress.example.com](https://wordpress.example.com) → WordPress site
* [https://metrics.example.com/metrics](https://metrics.example.com/metrics) → Prometheus metrics (optional)

---
### 8. Grafana Dashboard

Goma Gateway offers built-in monitoring capabilities to help you track the **health**, **performance**, and **behavior** of your gateway and its routes. Metrics are exposed in a **Prometheus-compatible** format and can be visualized using tools like **Prometheus** and **Grafana**.

A prebuilt **Grafana dashboard** is available to visualize metrics from Goma Gateway.

You can import it using dashboard ID: [23799](https://grafana.com/grafana/dashboards/23799)

## 9. Redis in Goma Gateway

Redis is used by Goma Gateway for:
* HTTP caching → Store and serve cached responses to improve performance.
* HTTP rate limiting → Protect your services from abuse by limiting request rates.

Redis is optional, but highly recommended if you want production-grade performance and security.

## 10. Screenshots

### Metrics

![Metrics](https://raw.githubusercontent.com/jkaninda/goma-gateway-production-deployment/main/screenshot-1.png)

### Grafana

![Grafana](https://raw.githubusercontent.com/jkaninda/goma-gateway-production-deployment/main/screenshot-2.png)

### Okapi Example

![Okapi Example](https://raw.githubusercontent.com/jkaninda/goma-gateway-production-deployment/main/screenshot-3.png)

### WordPress

![WordPress](https://raw.githubusercontent.com/jkaninda/goma-gateway-production-deployment/main/screenshot-4.png)

---

## Done!

You now have a **production-ready Goma Gateway stack** running with:

* API Gateway & Reverse Proxy (Goma Gateway)
* Monitoring (Prometheus + Grafana)
* Optional caching (Redis)
* Example applications (Okapi + WordPress)

---

👉 Next steps:

* Add your own applications to the routes
* Configure HTTPS with Let’s Encrypt or your certificate provider
* Hook into GitOps (push config changes to Git and let Goma reload them automatically)