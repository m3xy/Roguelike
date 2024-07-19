float DAMPING = 0.5f;
float MAX_XP = 100; //XP to level up

abstract class Entity {
  //Static data: Position, Orientation. Kinematic data: Velocity, Rotation
  PVector pos, vel, ori, rot;
  float maxHP, health, strength, speed, experience;
  int level, wealth, capacity; 
  
  Entity(PVector pos, float maxHP, float health, float strength, float speed) {
    this(pos, new PVector(0,0,0), new PVector(0,PI,0), new PVector(0,0,0),maxHP, health, strength, speed);
  }
  
  Entity(PVector pos, PVector vel, PVector ori, PVector rot, float maxHP, float health, float strength, float speed){
    this.pos = pos;
    this.vel = vel;
    this.ori = ori;
    this.rot = rot;
    this.maxHP = maxHP;
    this.health = health;
    this.strength = strength;
    this.speed = speed; //Between 0.5 and 2
    
    //Initialise
    level = 1;
    wealth = 0;
    capacity = 5;
    experience = 0;
  }
  
  void update() {
    this.integrate();
    this.display();
  }
  
  void integrate() {
    //this.vel.mult(DAMPING);
    this.pos.add(vel);
  }
  
  void display() {
    game.pushMatrix();
    this.draw();
    game.popMatrix();
  }
  
  abstract void draw();
  
  boolean isDead() {
    return health <= 0; 
  }
  
  void hurt(Entity from, float damage) {
    this.health -= damage; //Inflict damage
    //Apply knockback
    if(from instanceof Player) {//Player attacking enemy
      if(map.tiles[Math.min(Math.max(0, Math.round((this.pos.z - unit * sin(from.ori.y+HALF_PI))/unit)), map.tiles.length - 1)]
      [Math.min(Math.max(Math.round((this.pos.x - unit * cos(from.ori.y+HALF_PI))/unit), 0), map.tiles[0].length - 1)] != 0) {  //Block behind is free
        this.pos.z += (int)(-unit * sin(from.ori.y+HALF_PI));
        this.pos.x += (int)(-unit * cos(from.ori.y+HALF_PI));
      }
    } else if(from instanceof Enemy){ //Enemy attacking player
      if(map.tiles[Math.min(Math.max(0, Math.round((this.pos.z - unit * sin(from.ori.y))/unit)), map.tiles.length - 1)]
      [Math.min(Math.max(Math.round((this.pos.x + unit * cos(from.ori.y))/unit), 0), map.tiles[0].length - 1)] != 0) {  //Block behind is free
        this.pos.z += (int)(-unit * sin(from.ori.y));
        this.pos.x += (int)(unit * cos(from.ori.y));
      }
    }

    
  }
}
