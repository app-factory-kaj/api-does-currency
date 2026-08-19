# Currency Exchange API — PRD

## Problem Statement

Developers and systems that need to know the USD value of an amount held in another currency today either hard-code stale exchange rates, cobble together calls to inconsistent public sources, or build their own rate-fetching and conversion logic from scratch. This is error-prone, hard to keep current, and repeated by every team that needs the same simple capability.

## Solution

A backend API that converts a given amount in a specified source currency to its equivalent in USD, using the current exchange rate. The API is a pure machine-to-machine service — no web UI — built to be integrated directly into other systems and applications.

## Actors

- **API Consumer** — a developer or system that calls the API to convert an amount from a source currency to USD. Authenticates with a shared API key.

## User Stories

1. As an API Consumer, I want to convert a given amount in a specified source currency to USD using the current exchange rate, so that I can display or process USD-equivalent values in my application.
2. As an API Consumer, I want my request to be authenticated with an API key, so that only authorized callers can use the conversion service.
3. As an API Consumer, I want a clear error response when I submit an unsupported currency code or an invalid amount, so that I can handle failures in my integration.

## Product Decisions

- The API supports all major world currencies (ISO 4217) as source currencies for conversion to USD.
- The product depends on an external currency exchange rate data provider to source current rates (concrete provider selected at design time).
- Authentication uses a single shared API key issued to all consumers, sent with each request — not a per-consumer key.
- This is a pure API product: no web dashboard, and no end-user sign-in via SSO, since there are no human users of this product.

## Phasing

- **Phase 1 — Deliver current-rate USD conversion via a single authenticated API**: ship the conversion endpoint, shared-API-key authentication, and error handling for unsupported currencies or invalid input. Stories: 1, 2, 3.

## Out of Scope

- Batch conversion of multiple amounts/currencies in a single request.
- Historical exchange rate lookups (conversion using a rate from a past date).
- An endpoint to list or browse all supported currencies and their current rates.
- A developer dashboard or any web UI.
- Per-consumer API keys, usage metering, or key management.
- Rate alerts, webhooks, or notifications.
- Currency conversion between two non-USD currencies.

## Open Questions

None at this time.