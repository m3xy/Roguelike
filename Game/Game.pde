import java.awt.Robot;
import java.awt.AWTException;

//GAME
PGraphics hud, game;
boolean showInventory = true;
int score = 0, highscore = 0; //Initially

//BG
PShape bg;

//CAMERA
float cameraZ = ((height/2.0) / tan(PI*30.0/180.0)); //Camera-Character distance
float rx = 0; //Rotation around x axis (Up-down aim)
Robot robot; //Used to reset the cursor back to the middle of the screen (infinite turning)

//MAP
Map map;  //0 : wall, 1 : floor
float unit = 10;

//PLAYER
Player player;
float sensitivity = 0.25; //Mouse sensitivity, Assumes horizontal/vertical = 2/1 when converting from 2d sensitivity to 3d sensitivity


//ENEMY
Enemy enemy;

void setup() {
  //SCREEN
  fullScreen(P2D, SPAN);
  //size(1920, 1080, P2D);
  hud = createGraphics(width, height, JAVA2D);
  game = createGraphics(width, height, P3D);
  
  //INIT
  bg = loadShape("bg.obj");
  bg.setFill(color(255, 255, 255));
  try{
    robot = new Robot();
  }catch(AWTException e) {
    System.err.println("Error: Setting up robot");
  }
  noCursor();
  robot.mouseMove(width/2,height/2); //Move cursor to centre
  
  //START
  restart();
}

void draw() {
  background(255);
  hudDraw();
  gameDraw();
  image(game, 0, 0);
  image(hud, 0, 0);
  if(player.isDead())
    restart();
}

void gameDraw() {
  
  game.beginDraw();
  
  //BG
  game.background(0);
  game.lights(); //For background ambient lighting
  game.pushMatrix();
  game.translate(player.pos.x, player.pos.y, player.pos.z);
  game.scale(150);
  game.shape(bg);
  game.popMatrix();
  game.noLights();  //For background ambient lighting
  
  //PLAYER
  player.update();

  //DUNGEON: ENEMIES, LAND/WALLS
  map.update();
  
  game.endDraw();
  
  //CAMERA
  game.perspective(PI/3.0, float(width)/float(height), cameraZ/10.0, cameraZ*100.0); //Increase view distance
  rx -= map(mouseY - height/2, -height/2, height/2, -HALF_PI, HALF_PI) * sensitivity;
  rx = constrain(rx, -HALF_PI, 0);
  float xc = (cos(player.ori.y + HALF_PI) * unit * unit) + (player.pos.x);
  float zc = (sin(player.ori.y + HALF_PI) * unit * unit) + (player.pos.z);
  game.camera(xc, rx * unit * unit, zc, player.pos.x, player.pos.y, player.pos.z, 0, 1, 0); //Fixed to player
  robot.mouseMove(width/2,height/2); //Move cursor back to center
  
  score = (int)(((map.level-1)*100) + ((player.level-1)*100) + (int)player.experience + (int)player.wealth); //Based on how far the player gets, how many monsters they killed/damaged and money collected
  if(score > highscore) highscore = score;
  
}

void hudDraw() {
  hud.beginDraw();
  hud.background(0, 0); //Transparency 
  hud.stroke(0); //Outlines around shapes black
  hud.fill(0, 100); //Default


  //TOP - FPS, Score, Highscore
  hud.rect(0, 0, width, height/32);
  write((int)frameRate + " fps", 0, 0, LEFT, TOP, 15, color(255), color(0));
  write("Score: " + score, width/2, 0, CENTER, TOP, 15, color(255), color(0));
  write("High Score: " + highscore, width, 0, RIGHT, TOP, 15, color(255), color(0));
  
  //TOP LEFT - Attributes
  write("Health: " + (int)player.health + "/" + (int)player.maxHP, 0, 30, LEFT, TOP, 15, color(255), color(0));
  write("Strength: " + (int)player.strength, 0, 45, LEFT, TOP, 15, color(255), color(0));
  write("Speed: " + (double)Math.round(player.speed * 100) / 100, 0, 60, LEFT, TOP, 15, color(255), color(0));
  
  //TOP RIGHT - Controls
  write("Controls:\n" +
  "Movement: W | A | S | D\n" +
  "Attack: LMB\n" +
  "Cycle items: Scroll\n" +
  "Use item: RMB | Spacebar\n" +
  "Drop item: g\n" +
  "Hide items: TAB"
  , width - 180, 35, LEFT, TOP, 15, color(255), color(0));
  
  //TOP/BOTTOM MID = Levels
  write("Dungeon Level: " + map.level, width/2, 50, CENTER, TOP, 15, color(255), color(0));
  write("Player Level (XP): " + (int)player.level + " (" + (int)player.experience + "%)", width/2, height - height/4, CENTER, BOTTOM, 15, color(255), color(0));
  

  
  //BOTTOM - Inventory
  String itemType = "";
  if(showInventory){
    for(int i = 0; i < player.capacity; i++) {
      itemType = "Empty";
      hud.pushMatrix();
      hud.translate((width/player.capacity)*i, height);
      hud.rect(0, 0, width/player.capacity, -height/4);
      if(i < player.inventory.size()) {
        hud.fill(lerpColor(player.inventory.get(i).colour, color(255), 0.5));
        hud.circle((width/player.capacity)*0.5, -height/8, height/16);
        if(player.inventory.get(i) instanceof Equipment){
          itemType = "Equipment";
          write("Durability: " + (int)((Equipment)player.inventory.get(i)).getDurability(), (width/player.capacity)/2, -75, CENTER, CENTER, 15, color(255), color(0));
          write("Defence: " + (int)(((Equipment)player.inventory.get(i)).def * 100) + "% (Damage blocked)", (width/player.capacity)/2, -60, CENTER, CENTER, 15, color(255), color(0));
          write("Damage: " + (int)(player.strength+(((Equipment)player.inventory.get(i)).str*player.strength)) + " (Damage dealt)", (width/player.capacity)/2, -45, CENTER, CENTER, 15, color(255), color(0));
          write("Dexterity: " + (int)(player.speed+(((Equipment)player.inventory.get(i)).spd*player.speed)) + " (Damage range/evaded)", (width/player.capacity)/2, -30, CENTER, CENTER, 15, color(255), color(0));
          
        }
        else if(player.inventory.get(i) instanceof Consumable){
          itemType = "Consumable";
          write("+" + (int)(((Consumable)player.inventory.get(i)).hp*player.maxHP) + " HP", (width/player.capacity)/2, -60, CENTER, CENTER, 15, color(255), color(0));
          write("+" + (int)(((Consumable)player.inventory.get(i)).str*player.strength) + " Strength", (width/player.capacity)/2, -45, CENTER, CENTER, 15, color(255), color(0));
          write("+" + (double)Math.round((((Consumable)player.inventory.get(i)).spd*player.speed)*100)/100 + " Speed", (width/player.capacity)/2, -30, CENTER, CENTER, 15, color(255), color(0));
        }
      }
      write(itemType, (width/player.capacity)/2, -height/4, CENTER, TOP, 15, color(255), color(0));
      if(i == player.selected)
        write("Selected", (width/player.capacity)/2, 0, CENTER, BOTTOM, 15, color(255, 0, 0), color(0));
      hud.fill(0, 100); //Default
      hud.popMatrix();
    }
  }
  
  

  
  
  hud.endDraw();
}

//Writes text on HUD
void write(String text, float x, float y, int alignX, int alignY, float size, color colour, color bg)  {
  hud.fill(colour);
  hud.textSize(size);
  hud.textAlign(alignX, alignY);
  hud.text(text, x, y);
  hud.fill(bg, 100); //Default
}

void keyPressed() {
  switch (key) {  //Movement
    case 'w' :
      player.move = Move.UP;
      break;
    case 'a' :
      player.move = Move.LEFT;
      break;
    case 's' :
      player.move = Move.DOWN;
      break;
    case 'd' :
      player.move = Move.RIGHT;
      break;
    case ' ' :      //Attacking
      player.use();
      break;
    case TAB :   //INVENTORY
      showInventory = !showInventory;
      break;
    case 'g' : //Discard item
      player.drop();
      break;
  }
}

void keyReleased() {
  switch (key) {  //Movement
    case 'w' :
    case 's' :
    case 'a' :
    case 'd' :
      player.move = Move.NONE;
      break;
  }
}

void mousePressed() {
  switch(mouseButton) {
    case LEFT :
      player.attack();
      break;
    case RIGHT :
      player.use();
      break;
  }
}

void mouseWheel(MouseEvent event) {
   player.selected += -event.getCount();
   player.selected = constrain(player.selected, 0, Math.max(player.inventory.size() - 1, 0));
}

void restart() {
  //MAP
  map = new Map(8, 8);
  
  //PLAYER
  player = new Player(map.startRow, map.startCol);
}
