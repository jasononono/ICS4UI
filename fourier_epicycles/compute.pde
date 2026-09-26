/*
this file contains the actual fourier series computations.

in general, if f(t) represents the target position (complex number in polar form) of the path-tracing cursor at time t (a full revolution is completed for every integer t), and c_n represents the scale (complex number in polar form) of circle n:

    c_n = int_0^1 [ e^(-i*2pi*n*t) * f(t) ] dt

to calculate that integral, subdivide each segment and take the average of the positions.
*/

void compute_fourier() { // compute the circle angles and radii based on the user's sketch
    if (state.equals("compute") || state.equals("display")) {
        return; // prevent calling this function redundantly if mouse_pressed is registered more than once
    } state = "compute";

    for (int n = -COMPONENTS; n <= COMPONENTS; n++) { // iterate over all circles
        circles[n+COMPONENTS] = get_integral(n); // use the formula above
    }

    state = "display"; // set state back to display mode
}

PVector get_integral(int n) { // evaluates the RHS of the above equation based on n, the revolution multiplier
    PVector sum = new PVector(float(0), float(0)); // polar coordinates
    for (int i = 0; i < path_length; i++) {
        PVector start = PVector.sub(path[i], FOURIER_CENTER); // start of the segment (relative to revolution center), cartesian
        PVector end = PVector.sub(path[(i+1) % path_length], FOURIER_CENTER); // end of the segment (relative to revolution center), cartesian
        PVector displacement = PVector.sub(end, start); // vector going from start to end, cartesian

        for (int s = 0; s < SUBDIVISIONS; s++) { // for each subdivision
            // compute actual coordinate, cartesian
            PVector position = PVector.add(start, PVector.mult(displacement, s/SUBDIVISIONS));
            
            // number of revolutions = (segment number) + subdivided part) / path length
            float t = (float(i) + float(s)/SUBDIVISIONS) / path_length;
            PVector scale = new PVector(float(1), -TWO_PI*t*n); // the e^(-i*...) part, polar coordinates

            sum = complex_add(sum, (complex_mul(scale, xy_to_polar(position)))); // add this to sum
        }
    }
    return new PVector(sum.x / (path_length*SUBDIVISIONS), sum.y); // the integral is just the averages of all point coordinates
}

PVector path_polar(int point) { // get the polar coordinates of a point in the sketch, relative to the revolution center
    PVector pos_rel = PVector.sub(path[point], FOURIER_CENTER);
    return xy_to_polar(pos_rel);
}