import ballerina/http;
import ballerina/log;

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Convert an amount from a source currency to USD
    #
    # + return - returns can be any of following types
    # http:Ok (Conversion computed successfully)
    # http:BadRequest (Unsupported currency code or invalid amount)
    # http:Unauthorized (Missing or invalid API key)
    resource function post conversions(@http:Header string? x\-api\-key, @http:Payload json payload)
            returns ConversionResultOk|ErrorBadRequest|ErrorUnauthorized|http:InternalServerError {
        if x\-api\-key is () || x\-api\-key != apiKey {
            return <ErrorUnauthorized>{
                body: {code: 401, message: "Unauthorized", description: "Missing or invalid X-API-Key header"}
            };
        }

        ConversionRequest|error conversionRequest = payload.cloneWithType(ConversionRequest);
        if conversionRequest is error {
            return <ErrorBadRequest>{
                body: {
                    code: 400,
                    message: "Invalid request",
                    description: "sourceCurrency (string) and amount (positive number) are required"
                }
            };
        }

        string sourceCurrency = conversionRequest.sourceCurrency.trim().toUpperAscii();
        decimal amount = conversionRequest.amount;

        if !isoCurrencyCodes.hasKey(sourceCurrency) {
            return <ErrorBadRequest>{
                body: {
                    code: 400,
                    message: "Unsupported currency",
                    description: string `sourceCurrency '${sourceCurrency}' is not a supported ISO 4217 code`
                }
            };
        }
        if amount <= 0d {
            return <ErrorBadRequest>{
                body: {code: 400, message: "Invalid amount", description: "amount must be a positive number"}
            };
        }

        ExchangeRateResponse|error ratesResponse = fetchLatestUsdRates();
        if ratesResponse is error {
            log:printError("failed to fetch latest rates from exchange-rate-provider", 'error = ratesResponse);
            return <http:InternalServerError>{
                body: {
                    code: 500,
                    message: "Upstream provider error",
                    description: "Unable to fetch current exchange rates; try again later"
                }
            };
        }

        decimal? providerRate = ratesResponse.conversion_rates[sourceCurrency];
        if providerRate is () {
            return <ErrorBadRequest>{
                body: {
                    code: 400,
                    message: "Unsupported currency",
                    description: string `sourceCurrency '${sourceCurrency}' is not currently supported by the rate provider`
                }
            };
        }

        decimal rate = 1d / providerRate;
        decimal convertedAmount = amount * rate;

        return <ConversionResultOk>{
            body: {
                sourceCurrency: sourceCurrency,
                amount: amount,
                rate: rate,
                convertedAmount: convertedAmount,
                targetCurrency: "USD",
                rateTimestamp: ratesResponse.time_last_update_utc
            }
        };
    }
}
