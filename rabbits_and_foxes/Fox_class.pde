class Fox {


    // FIELDS


    String gender;
    float sight_radius;
    float accel_speed;
    float max_speed;
    boolean alive;
    float hunger;
    PVector pos, vel, acc;
    float dir_tick = 0;


    // CONSTRUCTOR


    Fox(String gender_, float sight_radius_, float accel_speed_, float max_speed_, float x_, float y_) {
        this.gender = gender_;
        this.sight_radius = sight_radius_;
        this.accel_speed = accel_speed_;
        this.max_speed = max_speed_;

        this.alive = true;
        this.hunger = random(60, 100);

        this.pos = new PVector(x_, y_);
        this.vel = new PVector(0, 0);
        change_dir();
    }


    // METHODS


    void draw() {
        PVector mouse_pos = new PVector(mouseX, mouseY);
        if (PVector.dist(mouse_pos, this.pos) < 12 && this.alive) {
            fill(255, 232, 115, 10);
            strokeWeight(1);
            stroke(255, 232, 115, 20);
            circle(this.pos.x, this.pos.y, this.sight_radius*2);

            textAlign(LEFT, CENTER);
            textSize(15);

            fill(255, 253, 122);
            text(round(this.hunger), this.pos.x+16, this.pos.y+6);
        }
        
        if (this.alive) {
            fill(200, 150, 0);
        } else {
            fill(80, 80, 80);
        }
        strokeWeight(1);
        stroke(0, 0, 0);
        square(this.pos.x, this.pos.y, 20);
    }

    void move() {
        if (!this.alive) {return;}

        this.vel.add(this.acc);
        this.vel.mult(FRICTION_CONSTANT);
        PVector unit_vec = this.vel.copy(); unit_vec.normalize();
        this.vel = PVector.mult(unit_vec, min(this.vel.mag(), this.max_speed));

        this.pos.add(this.vel);
        this.clamp_pos();

        int closest_rabbit = target_rabbit();
        if (closest_rabbit == -1 || this.hunger > 60) {
            this.dir_tick -= 1;
            if (this.dir_tick <= 0) {
                change_dir();
                this.dir_tick = int(random(5, 40));
            }
        } else {
            this.move_towards_rabbit(closest_rabbit);
            if (PVector.dist(rabbits[closest_rabbit].pos, this.pos) < 8) {
                rabbits[closest_rabbit].alive = false;
                this.hunger += rabbits[closest_rabbit].hunger / 2;
            }
        }
    }

    void update_status() {
        if (!this.alive) {
            this.hunger = 0;
            return;
        }
        this.hunger -= 0.1;
        if (this.hunger > 100) {
            this.hunger = 100;
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

    int target_rabbit() {
        float closest_dist = sight_radius;
        int closest_index = -1;
        for (int i = 0; i < rabbits.length; i++) {
            float dist = PVector.sub(rabbits[i].pos, this.pos).mag();
            if (dist < closest_dist && rabbits[i].alive) {
                closest_dist = dist;
                closest_index = i;
            }
        }
        return closest_index;
    }

    void move_towards_rabbit(int index) {
        PVector target_vec = PVector.sub(rabbits[index].pos, this.pos);

        float angle = target_vec.heading();
        PVector unit_vec = new PVector(cos(angle), sin(angle));
        this.acc = PVector.mult(unit_vec, this.accel_speed);

        float actual_dist = this.vel.magSq() / (2*this.acc.mag());
        if (actual_dist >= target_vec.mag()) {
            this.acc.mult(-1);
        }
    }


}