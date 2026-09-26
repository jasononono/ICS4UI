/*
this file handles all user inputs
*/


void sample_mouse() { // record a point on the mouse posiiton
    path[path_length] = new PVector(float(mouseX), float(mouseY));
    last_sampled = time_passed; // update last sample time
    path_length++; // update path length
}


// press the mouse to start drawing
void mousePressed() {
    if (state.equals("start")) {
        state = "draw";
    } else if (state.equals("display")) { // mouse pressed during display re-enters drawing mode
        // reset time and array length parameters
        last_sampled = -SAMPLE_RATE;
        path_length = 0;
        display_time = 0;
        fourier_length = 0;
        
        state = "draw";
    }
}

// release the mouse to end drawing and compute fourier stuff
void mouseReleased() {
    if (state.equals("draw")) {
        compute_fourier();
    }
}