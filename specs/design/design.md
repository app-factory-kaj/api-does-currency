# Currency Exchange API — Design

A single Ballerina service, `currency-exchange-api`, exposed directly to the internet. API Consumers call it with a shared API key to convert an amount in a given source currency to its USD equivalent, using current rates it fetches from an external exchange-rate provider. There is no persistence and no web UI — the service is stateless, fetching a fresh rate per request (or a short-lived cached one) from the upstream provider.

## Context (C1)

```mermaid
graph LR
    consumer["API Consumer<br/>(developer / system)"]
    api(("Currency Exchange API"))
    provider["Exchange Rate Provider<br/>(ExchangeRate-API)"]

    consumer -->|"API key + HTTPS"| api
    api -->|"fetch latest USD rates"| provider
```

## Domain model (ER)

```mermaid
erDiagram
    CONVERSION_REQUEST {
        string sourceCurrency
        decimal amount
    }
    CONVERSION_RESULT {
        string sourceCurrency
        decimal amount
        decimal rate
        decimal convertedAmount
        string targetCurrency
        datetime rateTimestamp
    }
    CURRENCY {
        string code
        string name
    }

    CONVERSION_REQUEST ||--|| CONVERSION_RESULT : "produces"
    CONVERSION_RESULT }o--|| CURRENCY : "sourceCurrency references"
```

## Key flows

```mermaid
sequenceDiagram
    participant C as API Consumer
    participant A as Currency Exchange API
    participant P as Exchange Rate Provider

    C->>A: POST /conversions {sourceCurrency, amount} + API key
    A->>A: validate API key
    alt invalid key
        A-->>C: 401 Unauthorized
    else valid key
        A->>A: validate currency code + amount
        alt unsupported currency or invalid amount
            A-->>C: 400 Bad Request (Error)
        else valid request
            A->>P: GET /v6/{API_KEY}/latest/USD
            P-->>A: conversion_rates map
            A->>A: compute USD amount using sourceCurrency rate
            A-->>C: 200 OK ConversionResult
        end
    end
```