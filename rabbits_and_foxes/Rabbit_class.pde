class Rabbit {


    // FIELDS


    String name, gender;
    float sight_radius;
    float accel_speed;
    float max_speed;
    float nervousness;
    float alertness;
    boolean alive;
    float hunger; int eating;
    PVector pos, vel, acc;
    float dir_tick = 0;
    color fur_col;


    // CONSTRUCTOR


    Rabbit(String name_, String gender_, float sight_radius_, float accel_speed_, float max_speed_, float nervousness_, float alertness_, float x_, float y_) {
        this.name = name_;
        this.gender = gender_;
        this.sight_radius = sight_radius_;
        this.accel_speed = accel_speed_;
        this.max_speed = max_speed_;
        this.nervousness = nervousness_;
        this.alertness = alertness_;

        this.alive = true;
        this.hunger = random(60, 100);
        this.eating = -1;

        this.pos = new PVector(x_, y_);
        this.vel = new PVector(0, 0);
        change_dir();

        if (this.gender == "male") {
            this.fur_col = color(random(100, 200), 57, 53);
        } else {
            this.fur_col = color(196, 194, 192);
        }
    }


    // METHODS


    void draw() {
        PVector mouse_pos = new PVector(mouseX, mouseY);
        if (PVector.dist(mouse_pos, this.pos) < 12 && this.alive) {
            fill(115, 232, 255, 10);
            strokeWeight(1);
            stroke(115, 232, 255, 20);
            circle(this.pos.x, this.pos.y, this.sight_radius*2);

            textAlign(LEFT, CENTER);
            textSize(15);

            fill(128, 255, 251);
            text(this.name, this.pos.x+16, this.pos.y-8);

            fill(255, 253, 122);
            text(round(this.hunger), this.pos.x+16, this.pos.y+6);
        }
        
        if (this.alive) {
            fill(this.fur_col);
        } else {
            fill(100, 100, 100);
        }
        strokeWeight(1);
        stroke(0, 0, 0);
        square(this.pos.x, this.pos.y, 16);
    }

    void move() {
        if (!this.alive) {return;}

        this.vel.add(this.acc);
        this.vel.mult(FRICTION_CONSTANT);
        PVector unit_vec = this.vel.copy(); unit_vec.normalize();
        this.vel = PVector.mult(unit_vec, min(this.vel.mag(), this.max_speed));

        this.pos.add(this.vel);
        this.clamp_pos();

        int closest_plant = target_plant();
        if (this.eating != -1) {
            this.eat();
        } else if (closest_plant == -1 || this.hunger > 60) {
            this.dir_tick -= 1;
            if (this.dir_tick <= 0) {
                change_dir();
                this.dir_tick = int(random(this.nervousness, this.nervousness+20));
            }
        } else {
            this.move_towards_plant(closest_plant);
        }

        int closest_fox = target_fox();
        if (closest_fox != -1 && random(100) < this.alertness) {
            this.move_away_from_fox(closest_fox);
        }
    }

    void update_status() {
        if (!this.alive) {
            this.hunger = 0;
            return;
        }
        this.hunger -= 0.15;
        if (this.hunger > 100) {
            this.hunger = 100;
            this.eating = -1;
        }
        if (this.hunger <= 0) {
            this.alive = false;
        }
    }

    void clamp_pos() {
        this.pos.x = constrain(this.pos.x, 0, width);
        this.pos.y = constrain(this.pos.y, 0, height);
    }

    void change_dir() {
        float rand_angle = random(0, TWO_PI);
        PVector unit_vec = new PVector(cos(rand_angle), sin(rand_angle));
        this.acc = PVector.mult(unit_vec, this.accel_speed);
    }

    int target_plant() {
        float closest_dist = sight_radius;
        int closest_index = -1;
        for (int i = 0; i < plants.length; i++) {
            float dist = PVector.sub(plants[i].pos, this.pos).mag();
            if (dist < closest_dist && plants[i].size >= plants[i].max_size-10) {
                closest_dist = dist;
                closest_index = i;
            }
        }
        return closest_index;
    }

    int target_fox() {
        float closest_dist = sight_radius;
        int closest_index = -1;
        for (int i = 0; i < foxes.length; i++) {
            float dist = PVector.sub(foxes[i].pos, this.pos).mag();
            if (dist < closest_dist && foxes[i].alive) {
                closest_dist = dist;
                closest_index = i;
            }
        }
        return closest_index;
    }

    void move_towards_plant(int index) {
        PVector target_vec = PVector.sub(plants[index].pos, this.pos);

        if (target_vec.mag() < plants[index].size) {
            this.eating = index;
        }

        float angle = target_vec.heading();
        PVector unit_vec = new PVector(cos(angle), sin(angle));
        this.acc = PVector.mult(unit_vec, this.accel_speed);

        float actual_dist = this.vel.magSq() / (2*this.acc.mag());
        if (actual_dist >= target_vec.mag() - plants[index].size) {
            this.acc.mult(-1);
        }
    }

    void move_away_from_fox(int index) {
        PVector target_vec = PVector.sub(this.pos, foxes[index].pos);

        float angle = target_vec.heading();
        PVector unit_vec = new PVector(cos(angle), sin(angle));
        this.acc = PVector.mult(unit_vec, this.accel_speed);
    }

    void eat() {
        this.acc = new PVector(0, 0);
        if (plants[this.eating].size == 1) {
            this.eating = -1;
        } else {
            this.hunger += 1;
            plants[this.eating].size -= 0.2;
        }
    }


}