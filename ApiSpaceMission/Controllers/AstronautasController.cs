using ApiSpaceMission.Data;
using ApiSpaceMission.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiSpaceMission.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AstronautasController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AstronautasController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Astronauta>>> GetAstronautas()
        {
            return await _context.Astronautas.Include(a => a.Missao).ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Astronauta>> GetAstronauta(int id)
        {
            var astronauta = await _context.Astronautas.Include(a => a.Missao).FirstOrDefaultAsync(a => a.Id == id);
            if (astronauta == null) return NotFound();
            return astronauta;
        }

        [HttpPost]
        public async Task<ActionResult<Astronauta>> PostAstronauta(Astronauta astronauta)
        {
            var missaoExiste = await _context.Missoes.AnyAsync(m => m.Id == astronauta.MissaoId);
            if (!missaoExiste) return BadRequest("Missão inválida.");

            _context.Astronautas.Add(astronauta);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetAstronauta), new { id = astronauta.Id }, astronauta);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> PutAstronauta(int id, Astronauta astronauta)
        {
            if (id != astronauta.Id) return BadRequest();
            _context.Entry(astronauta).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAstronauta(int id)
        {
            var astronauta = await _context.Astronautas.FindAsync(id);
            if (astronauta == null) return NotFound();
            _context.Astronautas.Remove(astronauta);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}