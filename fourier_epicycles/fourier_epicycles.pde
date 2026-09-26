/*
FOURIER EPICYCLE VISUALIZER

After doing some research, I was fascinated by this video by 3Blue1Brown, so I decided to explore the process of fourier transforms via this program.

https://www.youtube.com/watch?v=r6sGWTCMz2k

most complex number calculations in the code will be done in polar coordinates (for convenience).
They will always be in the form PVector(magnitude, angle)
*/


/* SETTINGS */


PVector FOURIER_CENTER = new PVector(float(400), float(400)); // center of the first revolving circle
int COMPONENTS = 20; // there will be 2(COMPONENTS)+1 circles in total
int SUBDIVISIONS = 20; // how many (non-zero) measurements are taken for each segment (between two points)

float SAMPLE_RATE = 0.02; // number of seconds between each point is placed
int MAX_POINTS = 3000; // maximum number of points
float POINT_SIZE = 5; // visual diameter of each point
float LINE_WIDTH = 4; // visual width of the lines of the sketch

float CIRCLE_LINE_WIDTH = 1.5; // visual border width of the circles

int FOURIER_MAXLEN = 200; // length of path traced by circles
int FOURIER_TAIL = 100; // length of the transparent part of the circles' path
float FOURIER_LINE_WIDTH = 4; // visual width of the traced drawn by circles
float FOURIER_SPEED = 5; // how many segments the circles trace per second


/* GLOBAL VARIABLES */


String state = "start"; // the current state of the program, one of {"start", "draw", "compute", "display"}
float time_passed = 0; // time elapsed (seconds) since the start of the the program 
float dt; // time passed since last draw() called, refreshed each frame

float last_sampled = -SAMPLE_RATE; // time when last point was sampled
PVector[] path = new PVector[MAX_POINTS]; // path of the sketch (cartesian)
int path_length = 0; // actual number of dots in the path

PVector[] circles = new PVector[COMPONENTS * 2 + 1]; // modifier complex numbers of the circles (polar)

float display_time = 0; // time elapsed since circles started spinning
PVector[] fourier_path = new PVector[FOURIER_MAXLEN]; // path of the circles' path (cartesian)
int fourier_length = 0; // actual number of points in the circles' path

PFont FONT;


/* MAIN FUNCTIONS */


void setup() {
    size(800, 800);
    frameRate(60);

    FONT = createFont("trebuchet ms", 15);
}

void draw() {
    // update time parameters
    dt = 1 / frameRate;
    time_passed += dt;

    background(22, 24, 28);
    draw_text();
    draw_path();

    if (state.equals("draw")) {

        if (time_passed - last_sampled >= SAMPLE_RATE) { // measure the time since last sample
            sample_mouse(); // call this function to add a create point
        }
        if (path_length == MAX_POINTS) { // if path exceeds the length of the array, stop drawing to prevent overflow
            compute_fourier();
        }

    } else if (state.equals("display")) {

        // number of revolutions = (time elapsed * points per second) / total points
        float revolutions = display_time * FOURIER_SPEED / path_length;
        PVector point = draw_circles(revolutions);
        draw_fourier_path();
        shift_fourier_path(); // shifts the path data down one in the array to make room at the end
        
        fourier_path[FOURIER_MAXLEN-1] = point; // add a new point to the end of the array
        if (fourier_length < FOURIER_MAXLEN) {
            fourier_length++; // update the path length if necessary
        }
        display_time += dt; // update display time

    }
}

void draw_text() { // display all text info
    textFont(FONT);
    fill(255, 255, 255);

    text("Click and drag to sketch a path", 15, 30);
    text("If the approximation is rough,\ntry changing COMPONENTS or SUBDIVISIONS.", 15, 70);
}

void draw_path() { // display the user's sketch
    strokeWeight(LINE_WIDTH);

    for (int i = 0; i < path_length-1; i++) { // iterate through every segment and draw
        stroke(117, 127, 148);
        line(path[i].x, path[i].y, path[i+1].x, path[i+1].y);
    }
    if (path_length >= 2) { // draw the line connecting the first and the last point to form a closed loop
        if (state == "draw") { // make it transparent when the user is still drawing
            stroke(117, 127, 148, 100);
        }
        line(path[path_length-1].x, path[path_length-1].y, path[0].x, path[0].y);
    }

    fill(156, 164, 181);
    noStroke();

    for (int i = 0; i < path_length; i++) { // draw all points
        circle(path[i].x, path[i].y, POINT_SIZE);
    }
}

PVector draw_circles(float t) { // draw the rotating circles based on the number of base  revolutions, t
    PVector current_pos = new PVector(FOURIER_CENTER.x, FOURIER_CENTER.y); // cartesian

    strokeWeight(CIRCLE_LINE_WIDTH);
    noFill();

    for (int n = -COMPONENTS; n <= COMPONENTS; n++) { // n also denotes rotation speed multiplier
        float radius = circles[n+COMPONENTS].x;
        float angle = circles[n+COMPONENTS].y + TWO_PI*t*n; // 2pi * number of revolutions * speed multiplier
        PVector displacement = polar_to_xy(new PVector(radius, angle));

        stroke(255, 255, 255);
        circle(current_pos.x, current_pos.y, radius*2); // draw the circle

        stroke(138, 176, 255);
        line(current_pos.x, current_pos.y, // draw the rotated radius of the circle
             current_pos.x + displacement.x, current_pos.y + displacement.y);

        current_pos.add(displacement); // move the center to the end of the rotated radius
    }

    return current_pos;
}

void draw_fourier_path() { // display the circles' path
    strokeWeight(FOURIER_LINE_WIDTH);

    for (int i = 0; i < fourier_length-1; i++) { // iterate through all segments in the path array
        PVector pos1 = new PVector(fourier_path[FOURIER_MAXLEN-i-1].x, // first position
                                   fourier_path[FOURIER_MAXLEN-i-1].y);
        PVector pos2 = new PVector(fourier_path[FOURIER_MAXLEN-i-2].x, // second position
                                   fourier_path[FOURIER_MAXLEN-i-2].y);

        // alpha is a transparency value in the range [0, 1]
        // alpha = (minimum of tail length & distance to back of array) / tail size
        float alpha = float(min(FOURIER_TAIL, fourier_length-i)) / FOURIER_TAIL;
        stroke(255, 0, 0, 255 * alpha);

        line(pos1.x, pos1.y, pos2.x, pos2.y); // draw line
    }
}

void shift_fourier_path() { // shifts the entire circle path array to make room at the end
    int start = max(1, FOURIER_MAXLEN-fourier_length); // index of the back of the path
    for (int i = start; i < FOURIER_MAXLEN; i++) { // iterate through each point
        fourier_path[i-1] = fourier_path[i]; // shift point one index to the left (backwards)
    }
}