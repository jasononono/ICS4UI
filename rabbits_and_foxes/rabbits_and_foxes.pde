/*
RABBITS AND FOXES
*/


// USER PARAMETERS


int NUM_PLANTS = 20;
int NUM_RABBITS = 40;
int NUM_FOXES = 3;

float FRICTION_CONSTANT = 0.95;


// GLOBAL VARIABLES


Plant[] plants = new Plant[NUM_PLANTS];
Rabbit[] rabbits = new Rabbit[NUM_RABBITS];
Fox[] foxes = new Fox[NUM_FOXES];


// PROCESSING FUNCTIONS


void setup() {
    size(800, 600);
    frameRate(60);
    rectMode(CENTER);

    String gender;
    for (int i = 0; i < NUM_RABBITS; i++) {
        gender = random(100) < 50 ? "male" : "female";
        rabbits[i] = new Rabbit(nf(i), gender, random(75, 200), random(0.05, 0.2), random(1.5, 3.5), random(0, 100), random(0, 30), random(20, width-20), random(20, height-20));
    }
    for (int i = 0; i < NUM_FOXES; i++) {
        foxes[i] = new Fox("male", random(250, 400), random(0.1, 0.15), random(3, 4), random(20, width-20), random(20, height-20));
    }
    for (int i = 0; i < NUM_PLANTS; i++) {
        plants[i] = new Plant(random(20, width-20), random(20, height-20), random(0.01, 0.1), random(20, 30));
    }
}

void draw() {
    background(38, 92, 43);

    for (int i = 0; i < NUM_PLANTS; i++) {
        plants[i].draw();
        plants[i].grow();
    }

    for (int i = 0; i < NUM_RABBITS; i++) {
        rabbits[i].draw();
        rabbits[i].move();
        rabbits[i].update_status();
    }

    for (int i = 0; i < NUM_FOXES; i++) {
        foxes[i].draw();
        foxes[i].move();
        foxes[i].update_status();
    }
}