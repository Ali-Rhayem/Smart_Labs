using Confluent.Kafka;

namespace backend.helpers
{
    public interface IKafkaProducer
    {
        Task<(bool success, string? error)> ProduceAsync(string topic, string message);
    }
}