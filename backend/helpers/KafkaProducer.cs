using Confluent.Kafka;

public class KafkaProducer
{
    private readonly ProducerConfig _config;
    private const int MaxRetries = 3;
    private const int RetryDelayMs = 1000;

    public KafkaProducer(IConfiguration configuration)
    {
        _config = new ProducerConfig
        {
            BootstrapServers = configuration["Kafka:BootstrapServers"],
            MessageTimeoutMs = 5000,
            SocketTimeoutMs = 5000,
            MessageSendMaxRetries = 3,
            RetryBackoffMs = 1000
        };
    }

    public async Task<(bool success, string? error)> ProduceAsync(string topic, string message)
    {
        int attempts = 0;
        var backoffTime = RetryDelayMs;

        while (attempts < MaxRetries)
        {
            try
            {
                using var producer = new ProducerBuilder<Null, string>(_config).Build();
                var result = await producer.ProduceAsync(topic, new Message<Null, string> { Value = message });
                return (true, null);
            }
            catch (ProduceException<Null, string> ex) when (ex.Error.Code == ErrorCode.Local_Transport)
            {
                attempts++;
                if (attempts == MaxRetries)
                {
                    return (false, $"Kafka broker connection refused after {MaxRetries} attempts. Please check if Kafka is running.");
                }
                await Task.Delay(backoffTime);
                backoffTime *= 2; // Exponential backoff
            }
            catch (Exception ex)
            {
                return (false, $"Unexpected error: {ex.Message}");
            }
        }
        return (false, "Max retries exceeded");
    }
}