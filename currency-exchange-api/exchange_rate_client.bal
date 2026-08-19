import ballerina/http;

// ExchangeRate-API response for GET /{apiKey}/latest/{baseCode} — open record
// since the provider ships several fields (documentation, terms_of_use, ...)
// this service never reads.
public type ExchangeRateResponse record {
    string result;
    string base_code;
    string time_last_update_utc;
    map<decimal> conversion_rates;
};

final string exchangeRateProviderBaseUrl = exchangeRateApiBaseUrl != ""
    ? exchangeRateApiBaseUrl
    : "https://v6.exchangerate-api.com/v6";

final http:Client exchangeRateProviderClient = check new (exchangeRateProviderBaseUrl.endsWith("/")
    ? exchangeRateProviderBaseUrl.substring(0, exchangeRateProviderBaseUrl.length() - 1)
    : exchangeRateProviderBaseUrl);

function fetchLatestUsdRates() returns ExchangeRateResponse|error {
    ExchangeRateResponse ratesResponse = check exchangeRateProviderClient->/[exchangeRateApiKey]/latest/USD.get();
    return ratesResponse;
}
