/*
 * @brief 2D rounded rectangle (uniform corner radius)
 * @details Creates a flat 2D shape with rounded corners by taking the hull of
 *          four circles placed at the corner inset positions. The output is a
 *          single 2D region suitable for linear_extrude() or difference() ops.
 * @param size 2-element vector: [width, height]
 * @param radius Corner radius (uniform). Clamped to [0, min(size)/2].
 * @param center If true, shape is centered on the origin; otherwise bottom-left
 *               corner is at (0,0).
 * @param fn Optional override for circle resolution ($fn fallback if undef).
 *
 * Usage examples:
 *   round_rect([50, 30], 5);                // bottom-left origin
 *   round_rect([50, 30], 8, center=true);   // centered at (0,0)
 *   linear_extrude(height=10) round_rect([40,20], 4);
 */
module round_rect(size=[10,10], radius=2, center=false, fn=undef) {
  assert(len(size)==2, "size must be a 2-element vector [w,h]");
  w = size[0]; h = size[1];
  assert(w>0 && h>0, "width and height must be > 0");
  // Clamp radius to feasible range
  r = max(0, min(radius, min(w,h)/2));
  translate(center ? [-w/2, -h/2] : [0,0])
    hull() {
      for (x=[r, w-r], y=[r, h-r])
        translate([x,y])
          circle(r=r, $fn=is_undef(fn)?$fn:fn);
    }
}
