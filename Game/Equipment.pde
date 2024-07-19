final class Equipment extends Item {
  float def, str, spd, health; //Multipliers, buffs - non permanent (must be equipped)
  
  Equipment(int row, int col) {
    super(row, col, color(0, 255, 255));
    def = random(1);
    str = random(1);
    spd = random(1);
    health = str + (str * Math.round(random(10))); //Maximum 10 uses
  }
  
  void active() {
    user.attack(user.speed+(spd*user.speed), user.strength+(str*user.strength));
    health -= str;
  }
  
  
  float getDurability() {
    return health/str;
  }
}
