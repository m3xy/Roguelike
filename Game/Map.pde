import java.util.Iterator;

int MAX_ATTEMPTS = 10; //For generating enemies
float MIN_FLOOD_THRESHOLD = 0.45; //Determines minimum floor area
float DIFFICULTY_SCALE = 1.5; //Factor to increase difficulty by
int MAX_MAP_HEIGHT = 100;
int MAX_MAP_WIDTH = 100;

final class Map {
  int[][] tiles;
  ArrayList<Enemy> enemies;
  ArrayList<Item> items;
  int level;
  int attempt;
  
  //PLAYER
  int startRow, startCol;
  int endRow, endCol;
  
  Map(int rows, int cols) {
    getLevel(rows, cols, 1);
  }
  
  private void getLevel(int rows, int cols, int level) {
    this.level = level;
    do{
      startRow = -1;
      startCol = -1;
      endRow = -1;
      endCol = -1;
      generate(rows, cols);
      flood((int)random(rows), (int)random(cols));
      fill();
    }while(!full());
      addEnemies();
      addItems();
  }
  
  private void generate(int rows, int cols) {
    tiles = new int[rows][cols];  //0 : wall, 1 : floor, 2 : floor filled
    
    //Dungeon generation - Cellular Automata for Open Dungeon
    //Setup random noise
    for(int row = 0; row < rows; row++){
      for(int col = 0; col < cols; col++){
        tiles[row][col] = Math.round(random(100)) < 50 ? 0 : -1; //Random chance - alive or dead cell
      }
    }
    
    int[][] tilesCopy = new int[rows][cols];
    for(int i = 0; i < 50; i++) { //Repeat more times for more open dungeon
      //Prepare step
      for(int row = 0; row < rows; row++)
        for(int col = 0; col < cols; col++)
          if(tiles[row][col] == 0)  //Alive: Wall
            tilesCopy[row][col] = (neighbours(row, col) >= 4) ? 0 : -1;  //Becomes wall if >= 4 neighbouring walls. Else floor
          else   //Dead: Floor
            tilesCopy[row][col] = (neighbours(row, col) >= 5) ? 0 : -1;  //Becomes wall if >= 5 neighbouring walls. Else floor

      //Step
      for(int row = 0; row < rows; row++)
        for(int col = 0; col < cols; col++)
          tiles[row][col] = tilesCopy[row][col];
    }
  }
  
  private void flood(int row, int col) {
    if(row < 0 || row >= tiles.length || col < 0 || col >= tiles[0].length) //Out of bounds
      return;
    if(row == 0 && startRow == -1 && tiles[row][col] == -1) {
      tiles[row][col] = 2; //Entrance
      startRow = row;
      startCol = col;
    }else if(row == tiles.length - 1 && endRow == -1 && tiles[row][col] == -1) {
      tiles[row][col] = 3; //Exit
      endRow = row;
      endCol = col;
    }else if(row == 0 || col == 0 || row == tiles.length - 1 || col == tiles[0].length - 1)
      tiles[row][col] = 0;
    if(tiles[row][col] == -1) {
      tiles[row][col] = 1;
      flood(row+1, col);
      flood(row-1, col);
      flood(row, col+1);
      flood(row, col-1);
    }
  }
  
  private void fill() {
    for(int row = 0; row < tiles.length; row++)
      for(int col = 0; col < tiles[0].length; col++)
        if(tiles[row][col] == -1)
          tiles[row][col] = 0;
  }
  
  private void addEnemies() {
    //Spawn enemies according to level
    enemies = new ArrayList<>();
    int enemyRow, enemyCol;
    for(int i = 0; i < level * (int)DIFFICULTY_SCALE; i++) { //Number of enemies proportional to level
      attempt = 0;
      do{
        enemyRow = (int)random(tiles.length);
        enemyCol = (int)random(tiles[0].length);
      }while(tiles[enemyRow][enemyCol] != 1 && attempt++ < MAX_ATTEMPTS);
      if(tiles[enemyRow][enemyCol] == 1 && enemyRow > tiles.length/3)
        enemies.add(new Enemy(enemyRow*unit, enemyCol*unit, this, level));
    }
  }
  
  private void addItems() {
    items = new ArrayList<>();
    int itemRow, itemCol, itemType;
    for(int i = 0; i < this.level; i++) { //More chances for items with harder levels
      itemRow = (int)random(tiles.length);
      itemCol = (int)random(tiles[0].length);
      if(tiles[itemRow][itemCol] == 1){
        itemType = (int)random(3);
        switch(itemType) {
         case 0:
           items.add(new Equipment(itemRow, itemCol));
           break;
         case 1:
           items.add(new Consumable(itemRow, itemCol));
           break;
         case 2:
           items.add(new Treasure(itemRow, itemCol));
           break;
        }
      }
    }
  }
  
  private int neighbours(int row, int col) {
    int n = 0;
    //If neighbouring cell either out of bounds or alive, n++
    for(int r = row-1; r <= row+1; r++)
      for(int c = col-1; c <= col+1; c++)
        if((r < 0 || r >= tiles.length || c < 0 || c >= tiles[0].length) || ((r != row || c != col) && tiles[r][c] == 0)) n++;
    return n;
  }
  
  private boolean full() {
    int flooded = 0;
    boolean hasStart = false, hasExit = false;
    for(int row = 0; row < tiles.length; row++)
      for(int col = 0; col < tiles[0].length; col++)
        if(tiles[row][col] == 1)flooded++;
        else if(tiles[row][col] == 2) hasStart = true;
        else if(tiles[row][col] == 3) hasExit = true;
          
    return flooded >= MIN_FLOOD_THRESHOLD * (tiles.length*tiles[0].length) && hasStart && hasExit;
  }
  
  void update() {
    this.draw();
    
    for (Iterator<Enemy> iterator = enemies.iterator(); iterator.hasNext(); ) {
      Enemy enemy = iterator.next();
      enemy.update();
      if (enemy.isDead()) {
        player.experience += MAX_XP/player.level; //Harder to level up as level increases
        iterator.remove();
      }
        
    }
    
    for (Iterator<Item> iterator = items.iterator(); iterator.hasNext(); ) {
      Item item = iterator.next();
      if(item.user == null) item.draw();
      if(Math.round(player.pos.z/unit) == item.row && Math.round(player.pos.x/unit) == item.col && player.inventory.size() <= player.capacity) {
        iterator.remove();
        item.acquire(player);
      }
        
    }
    
    if(enemies.isEmpty() && Math.round(player.pos.z/unit) == endRow && Math.round(player.pos.x/unit) == endCol) {  //Cleared level
      this.level+=1;
      getLevel(Math.min((int)(tiles.length*DIFFICULTY_SCALE), MAX_MAP_HEIGHT), Math.min((int)(tiles[0].length*DIFFICULTY_SCALE), MAX_MAP_WIDTH), this.level);
      player.pos.z = startRow * unit;
      player.pos.x = startCol * unit;
    }
  }
  
  void draw() {
    for(int row = 0; row < this.tiles.length; row++) {
      for(int col = 0; col < this.tiles[0].length; col++) {
        if(tiles[row][col] == 0) {  //Wall
          game.pushMatrix();
          game.translate(col*unit, 0, row*unit);
          game.fill(color(128));
          game.noStroke();
          game.box(unit, unit*3, unit);
          game.popMatrix();
          
        }else if(tiles[row][col] == 1) {  //Floor
          game.pushMatrix();
          game.translate(col*unit, unit, row*unit);
          //game.fill(color(0,154,23)); //Grass green
          game.fill(color(128));
          game.noStroke();
          game.box(unit);
          game.popMatrix();
        }else if(tiles[row][col] == 2) {  //Entrance
          game.pushMatrix();
          game.translate(col*unit, unit, row*unit);
          game.fill(color(0));
          game.noStroke();
          game.box(unit);
          game.popMatrix();
        }else if(tiles[row][col] == 3) {  //Exit
          game.pushMatrix();
          game.translate(col*unit, unit, row*unit);
          if(enemies.isEmpty()) game.fill(color(255));
          else game.fill(color(0)); //Locked
          game.noStroke();
          game.box(unit);
          game.popMatrix();
        }
        
        //else if(map.tiles[row][col] == 4) {  //Item
        //  game.pushMatrix();
        //  game.translate(col*unit, unit, row*unit);
        //  game.fill(color(255));
        //  game.noStroke();
        //  game.box(unit);
        //  game.popMatrix();
        //  //map.tiles[x][z] = 1;
        //}
      }
    }
  }

  
}
