namespace ApiSpaceMission.Models
{
    public class Astronauta
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Especialidade { get; set; } = string.Empty;

        // Relacionamento com Missao
        public int MissaoId { get; set; }
        public Missao? Missao { get; set; }
    }
}