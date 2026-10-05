using System.Text.Json.Serialization;

namespace ApiSpaceMission.Models
{
    public class Missao
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Destino { get; set; } = string.Empty;

        [JsonIgnore] // Evita loop de serialização no JSON
        public ICollection<Astronauta> Astronautas { get; set; } = new List<Astronauta>();
    }
}