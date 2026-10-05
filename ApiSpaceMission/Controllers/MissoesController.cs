using ApiSpaceMission.Data;
using ApiSpaceMission.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiSpaceMission.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MissoesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MissoesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Missao>>> GetMissoes()
        {
            return await _context.Missoes.Include(m => m.Astronautas).ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Missao>> GetMissao(int id)
        {
            var missao = await _context.Missoes.Include(m => m.Astronautas).FirstOrDefaultAsync(m => m.Id == id);
            if (missao == null) return NotFound();
            return missao;
        }

        [HttpPost]
        public async Task<ActionResult<Missao>> PostMissao(Missao missao)
        {
            _context.Missoes.Add(missao);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetMissao), new { id = missao.Id }, missao);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> PutMissao(int id, Missao missao)
        {
            if (id != missao.Id) return BadRequest();
            _context.Entry(missao).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMissao(int id)
        {
            var missao = await _context.Missoes.FindAsync(id);
            if (missao == null) return NotFound();
            _context.Missoes.Remove(missao);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}