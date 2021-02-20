//generated config
const round = (v, n) => Math.round(v*n)/n
module.exports = {
  "global": {
    "onBuildSuccess": null
  },
  "mc": {
    "dev": true,
    "header": "#built using mc-build (https://github.com/mc-build/mc-build)",
    "internalScoreboard": "bw.i",
    "rootNamespace": null,
		round: round,
		moving_particle_circle: (name, c1, c2, count) => {
			const out = [];
			var angle = (2 * Math.PI / count);
			var i=0;
			for (var a = 0; a<(2*Math.PI); a+=angle) {
				i++;
				x1=round(c1.r*Math.sin(i), 1000) + c1.x;
				z1=round(c1.r*Math.cos(i), 1000) + c1.z;
				x2=round(c2.r*Math.sin(i), 1000) + c2.x;
				z2=round(c2.r*Math.cos(i), 1000) + c2.z;
				out.push(
					`particle ${name} ~${x1} ~${c1.y} ~${z1} ${x2} ${c2.y} ${z2} 1 0 force`
				);
			};
			return(out.join('\n'));
		},
		particle_line: (name, a, b, count) => {
			const out = [];
			l = Math.sqrt(((b.x - a.x)**2 + (b.y - a.y)**2 + (b.z - a.z)**2))
			d = l / count
			for (let i=0; i < l; i+=d){
				out.push(`particle ${name} ~ ~ ~`)
			}
		}
  }
}
