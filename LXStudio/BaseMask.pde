public
class BaseMaskEffect extends LXEffect {

public
  BaseMaskEffect(LX lx) { super(lx); }

public
  void run(double deltaMs, double enabledAmount) {
    for (LXPoint p : model.points) {
      if (p.yn > 0) {
        colors[p.index] = LXColor.gray(0);
      }
    }
  }
}