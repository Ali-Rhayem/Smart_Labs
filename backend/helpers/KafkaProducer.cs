using Confluent.Kafka;

public class KafkaProducer
{
    private readonly ProducerConfig _config;

    public KafkaProducer(IConfiguration configuration)
    {
        _config = new ProducerConfig
        {
            BootstrapServers = configuration["Kafka:BootstrapServers"]
        };
    }

    public async Task ProduceAsync(string topic, string message)
    {
        using var producer = new ProducerBuilder<Null, string>(_config).Build();
        var result = await producer.ProduceAsync(topic, new Message<Null, string> { Value = message });
        Console.WriteLine($"Message sent to {result.TopicPartitionOffset}");
    }
}