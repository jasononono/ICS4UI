class Plant {


    // FIELDS


    PVector pos;
    float growth_rate;
    float max_size, size;
    color plant_col;


    // CONSTRUCTOR


    Plant(float x_, float y_, float growth_rate_, float max_size_) {
        this.pos = new PVector(x_, y_);
        this.growth_rate = growth_rate_;
        this.max_size = max_size_;
        this.size = this.max_size;
        this.plant_col = color(55, 128+random(-10, 10), 62);
    }


    // METHODS


    void draw() {
        fill(this.plant_col);
        strokeWeight(1);
        stroke(47, 82, 51);
        circle(this.pos.x, this.pos.y, this.size);
    }

    void grow() {
        this.size += this.growth_rate;
        this.size = constrain(this.size, 1, this.max_size);
    }


}