/*
 * @brief Module to create an iPhone-shaped cutout
 * @details Create a 2D sketch in the shape of an iPhone with specified dimensions and corner curvature.
 *          The cutout is centered at the origin and extends from z=0 to z=depth.
 * @param length The length of the iPhone (along the x axis)
 * @param width The width of the iPhone (along the y axis)
 * @param curve The radius of the corner curves
 * @param smoothness The smoothness of the corner curves (higher values = smoother curves)
 */
module phone_2d_shape(length, width, curve, smoothness) {
    hull() {
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * (length/2 - curve), y * (width/2 - curve)])
                superellipse(curve, curve, smoothness);
        }
    }
}

/*
 * @brief Module to create a superellipse shape
 * @details Create a superellipse shape with the given parameters.
 * @param a The semi-major axis (along the x axis)
 * @param b The semi-minor axis (along the y axis)
 * @param n The exponent that defines the shape of the superellipse (n=2 is an ellipse, n>2 is a rectangle with rounded corners)
 */
module superellipse(a, b, n) {
    points = [for (t = [0:5:359]) [
        a * pow(abs(cos(t)), 2/n) * sign(cos(t)),
        b * pow(abs(sin(t)), 2/n) * sign(sin(t))
    ]];
    polygon(points);
}
