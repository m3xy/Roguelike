abstract class Item {
  
  int row, col;
  Player user;
  color colour;
  float rotation;
  
  Item(int row, int col, int colour) {
    this.user = null;
    this.row = row;
    this.col = col;
    this.colour = colour;
    this.rotation = 0;
  }
 
   void acquire(Player user) {
     //Assign to user
     this.user = user;
     //No longer be picked up or displayed
     this.row = -1;
     this.col = -1;
     //Add to inventory
     this.user.inventory.add(this);
   }
 
  //Usage - active
  abstract void active();
  
  void draw() {
    game.pushMatrix();
    game.translate(col*unit, -unit/8, row*unit);
    game.rotateY(rotation+= 0.01);
    game.rotateX(rotation+= 0.01);
    game.rotateZ(rotation+= 0.01);
    game.fill(this.colour);
    game.stroke(255);
    game.strokeWeight(1);
    game.box(unit/4);
    game.sphere(unit/8);
    game.popMatrix();
  }
}
