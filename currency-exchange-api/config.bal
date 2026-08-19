import ballerina/os;

// Shared API key that every consumer must send in the X-API-Key header.
configurable string apiKey = os:getEnv("API_KEY");

// ExchangeRate-API credentials — see design.json's exchange-rate-provider dependency.
configurable string exchangeRateApiKey = os:getEnv("EXCHANGE_RATE_API_KEY");
configurable string exchangeRateApiBaseUrl = os:getEnv("EXCHANGE_RATE_API_BASE_URL");
