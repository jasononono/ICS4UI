/*
functions that work with complex numbers
*/

PVector polar_to_xy(PVector c) { // convert polar coordinates to cartesian
    float mag = c.x;
    float angle = c.y; // in radians
    return new PVector(mag * cos(angle), mag * sin(angle));
}

PVector xy_to_polar(PVector c) { // convert cartesian to polar coordinates
    // atan2() is an extended version of tan() that checks and correctly handles instances where c.x is 0
    return new PVector(c.mag(), atan2(c.y, c.x));
}

PVector complex_mul(PVector a, PVector b) { // multiply polar complex numbers using de moivre's thm
    float magnitude = a.x * b.x;
    float angle = (a.y + b.y) % TWO_PI; // mod 360 degrees
    return new PVector(magnitude, angle);
}

PVector complex_add(PVector a, PVector b) { // add polar complex numbers
    // convert into cartesian coordinates, then add
    PVector result_pos = PVector.add(polar_to_xy(a), polar_to_xy(b));
    return xy_to_polar(result_pos); // back to polar
}