final class Treasure extends Item {
  
  int value;
  
  Treasure(int row, int col) {
    super(row, col, color(255, 255, 0));
    value = (int)random(1, 100);
  }
  
  void acquire(Player user) {
     this.user = user;
     user.wealth += this.value;
     row = -1;
     col = -1;
  }
  
  void active() {/*Won't be within player's inventory*/}
}
