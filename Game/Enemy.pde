final class Enemy extends Entity {
  
  PShape model;
  AStarSearch pathFinder;
  ArrayList<AStarNode> result;
  PVector acc;
  Map map;
  color colour = color(128); //Initially
  float range;
  long cooldown;
  
  Enemy(float row, float col, Map map, int level) {
    super(new PVector(col, 6, row), 20 * level, 20 * level, 2 * level, 0.25 * level/2);
    model = loadShape("ghost.obj");
    acc = new PVector(0,0,0);
    this.map = map;
    pathFinder = new AStarSearch(this.map);
    this.range = this.level;
  }
  
  void draw() {
    model.setFill(colour);
    game.stroke(0);
    game.strokeWeight(50);
    game.translate(this.pos.x, this.pos.y, this.pos.z);
    game.rotateY(this.ori.y);
    game.rotateX(PI + this.ori.x);
    game.rotateZ(this.ori.z);
    game.scale(unit/100);
    game.shape(model);
  }
  
  void update() {
    
    //Enemy behaviour via decision trees
    this.ori.y = atan2(player.pos.x-this.pos.x, player.pos.z-this.pos.z) - HALF_PI; //Stares at player
    this.ori.x = 0;
    this.ori.z = 0;
    this.vel.mult(0);
    
    
    result = pathFinder.search(Math.round(this.pos.z/unit), Math.round(this.pos.x/unit), Math.round(player.pos.z/unit), Math.round(player.pos.x/unit));
     //<>//
    if(result != null) { 
      if(result.size() <= range) {      //Within range, attack
        attack();
      }else if (result.size() > range) {  //Get in range
        this.acc.z = (Math.round(this.pos.z/unit) - result.get(result.size() - 2).row);
        this.acc.x = (Math.round(this.pos.x/unit) - result.get(result.size() - 2).col);
        if(this.acc.z > 0){
          this.vel.z = -speed;
          this.ori.z = -QUARTER_PI/8;
        }else if(this.acc.z < 0) {
          this.vel.z = speed;
          this.ori.z = -QUARTER_PI/8;
        }else if (this.acc.x > 0) {
          this.vel.x = -speed;
          this.ori.z = -QUARTER_PI/8;
        }else if (this.acc.x < 0) {
          this.vel.x = speed;
          this.ori.z = -QUARTER_PI/8;
        }
      }
    }else{
    }
    super.update();
  }
    
  void attack() {
    float damage = this.strength;
    if(System.currentTimeMillis() - cooldown >= (1/speed) * 1000) {
      if(random(100) * 1/player.speed >= 50) {//Player can dodge
        for(Item item : player.inventory)
          if(item instanceof Equipment) {
            damage -= ((Equipment)item).def * damage; //Account for player's armour
            ((Equipment)item).health -= ((Equipment)item).str;
          }
        player.hurt(this, damage);
      }
      cooldown = System.currentTimeMillis();
    }
  }
  
  void hurt(Player from, float damage) {
    super.hurt(from, damage);
    //this.colour = lerpColor(colour, color(colour, 0), Math.abs((health/maxHP) - 1));
  }

}
