final class Player extends Entity {
  
  PVector pos2; //Future tile
  PShape model;
  //Current moving direction
  boolean forwards, backwards, left, right, none;
  
  //Inventory
  ArrayList<Item> inventory;
  int selected;
  color colour = color(255);
  
  Player(float row, float col) {
    super(new PVector(col*unit, 0, row*unit), 10, 10, 5, 0.5);  //-6 from height of model
    model = loadShape("hero.obj");
    //this.move = Move.NONE;
    forwards = backwards = left = right = none = false;
    this.pos2 = this.pos.copy();
    
    //Inventory
    inventory = new ArrayList<>();
    selected = 0;
    
  }
  
  void draw() {
    model.setFill(colour);
    game.translate(this.pos.x, this.pos.y, this.pos.z);  
    game.rotateY(-this.ori.y);
    game.rotateX(PI + this.ori.x);  
    game.rotateZ(this.ori.z);
    game.scale(unit/100);
    game.lightFalloff(0.1, 0.0, 0.0001); //Slower falloff
    game.pointLight(255, 255, 255, 0, height, 0);  //Vision light
    //  game.lightFalloff(0.5, 0.0, 0.0); //Slower falloff
    //  game.spotLight(255, 255, 255, 0, 0, 0, 0, 0, 1, QUARTER_PI/4, 1);  //Flashlight light
    //  game.lightFalloff(1.0, 0.0, 0.000005); //Faster falloff
    game.shape(model);
  }
  
  void update() {
    
    this.ori.y += map(mouseX - width/2, -width/2, width/2, -PI, PI) * sensitivity; //Model face in direction player is facing
    this.pos2 = this.pos.copy();
    this.vel.mult(0);
    //Movement
      if(this.forwards) {
        this.vel.z += -speed * sin(this.ori.y + HALF_PI);
        this.vel.x += -speed * cos(this.ori.y + HALF_PI);
        this.pos2.z += -unit * sin(this.ori.y + HALF_PI);
        this.pos2.x += -unit * cos(this.ori.y + HALF_PI);
        this.ori.x = QUARTER_PI/8;
        this.ori.z = 0;
      } 
      if(this.backwards) {
        this.vel.z += speed * sin(this.ori.y + HALF_PI) * 0.5;
        this.vel.x += speed * cos(this.ori.y + HALF_PI) * 0.5;
        this.pos2.z += unit * sin(this.ori.y + HALF_PI);
        this.pos2.x += unit * cos(this.ori.y + HALF_PI);
        this.ori.x = -QUARTER_PI/8;
        this.ori.z = 0;
      }
      if(this.left) {
        this.vel.z += -speed * sin(this.ori.y) * 0.75;
        this.vel.x += -speed * cos(this.ori.y) * 0.75;
        this.pos2.z += -unit * sin(this.ori.y);
        this.pos2.x += -unit * cos(this.ori.y);
        this.ori.z = QUARTER_PI/8;
        this.ori.x = 0;
      }
      if(this.right) {
        this.vel.z += speed * sin(this.ori.y) * 0.75;
        this.vel.x += speed * cos(this.ori.y) * 0.75;
        this.pos2.z += unit * sin(this.ori.y);
        this.pos2.x += unit * cos(this.ori.y);
        this.ori.z = -QUARTER_PI/8;
        this.ori.x = 0;
      }
      
      //Don't normalise speed
      
      //if(this.none) {
      //  this.vel.mult(0);
      //  this.ori.x = 0;
      //  this.ori.z = 0;
      //}
    
    //Collision detection/resolution
    //Keep within bounds of map
    this.pos.z = constrain(this.pos.z, 0, (map.tiles.length - 1) * unit);
    this.pos.x = constrain(this.pos.x, 0, (map.tiles[0].length - 1) * unit);
    //Detect collision with walls by checking tile in front
    this.pos2.z = constrain(this.pos2.z, 0, (map.tiles.length - 1) * unit);
    this.pos2.x = constrain(this.pos2.x, 0, (map.tiles[0].length - 1) * unit);
    if(map.tiles[Math.round(this.pos2.z/unit)][Math.round(this.pos2.x/unit)] == 0) {
      //this.vel.mult(0);
      this.vel.add(new PVector(-this.vel.x, -this.vel.y, -this.vel.z)); //Force in opposite drection
    }
    
    //Attributes
    this.health = constrain(this.health, 0, this.maxHP);
    if(this.experience >= MAX_XP) {
      this.maxHP += (1/this.level) * this.maxHP;
      this.level += 1;
      this.experience = 0;
    }
    
    //Items
    //Check durability of equipment
    for (Iterator<Item> iterator = this.inventory.iterator(); iterator.hasNext(); ) {
      Item item = iterator.next();
      if(item instanceof Equipment && ((Equipment)item).health <= 0){
        iterator.remove();
        this.selected = 0;
      }

    }
    super.update();
  }
  
  void attack() { //Basic melee attack, no weapons
    attack(this.speed, this.strength);
  }
  
  void attack(float range, float damage) {
    //Melee
    float row = this.pos.z, col = this.pos.x;
    for(int i = 0; i <= range*2; i++) {
      for(Enemy enemy : map.enemies)
        if(Math.round(enemy.pos.z/unit) == Math.round(row/unit) && Math.round(enemy.pos.x/unit) == Math.round(col/unit))
          enemy.hurt(this, damage);
      row -= unit * sin(this.ori.y + HALF_PI);
      col -= unit * cos(this.ori.y + HALF_PI);
    }
  }
  
  void use() {
    if(!inventory.isEmpty() && selected < inventory.size()){
      inventory.get(selected).active();
    }
  }
  
  void drop() {
    if(selected < inventory.size()) {
       inventory.get(selected).user = null;
       this.pos2 = this.pos.copy();
       this.pos2.z += -unit * sin(this.ori.y + HALF_PI);
       this.pos2.x += -unit * cos(this.ori.y + HALF_PI);
       inventory.get(selected).row = constrain(Math.round(this.pos2.z/unit), 0,  map.tiles.length);
       inventory.get(selected).col = constrain(Math.round(this.pos2.x/unit), 0,  map.tiles[0].length);
       map.items.add(inventory.remove(selected));
    }
  }
  

}
