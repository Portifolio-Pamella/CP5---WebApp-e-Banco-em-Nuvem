using ApiSpaceMission.Models;
using Microsoft.EntityFrameworkCore;

namespace ApiSpaceMission.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Missao> Missoes { get; set; }
        public DbSet<Astronauta> Astronautas { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configuração explícita do relacionamento 1:N
            modelBuilder.Entity<Astronauta>()
                .HasOne(a => a.Missao)
                .WithMany(m => m.Astronautas)
                .HasForeignKey(a => a.MissaoId)
                .OnDelete(DeleteBehavior.Cascade);

            base.OnModelCreating(modelBuilder);
        }
    }
}