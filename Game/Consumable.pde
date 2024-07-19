final class Consumable extends Item {
 
  //Buffs percentage of health, strength, speed - permanent
  float hp, str, spd;
  
  Consumable(int row, int col) {
    super(row, col, color(255, 0, 255));
    hp = random(1);
    str = random(1);
    spd = random(1);
  }
  
  void active() {
    user.inventory.remove(this);
    user.health += (hp*user.maxHP);
    user.strength += (str*user.strength);
    user.speed += (spd*user.speed);
    user.selected = 0;
  }
  
}
