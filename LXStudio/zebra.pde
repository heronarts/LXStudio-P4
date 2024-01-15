
import heronarts.lx.LX;
import heronarts.lx.modulator.SinLFO;
import heronarts.lx.parameter.CompoundParameter;
import heronarts.lx.pattern.LXPattern;
import heronarts.lx.model.LXPoint;

// import entwined.core.CubeManager;

public
static class Zebra extends LXPattern {
  // public
  //   class Utils {
  //   public
  //     int cool() { return 3; }
  //   }

  CompoundParameter thickness = new CompoundParameter("THIC", 1, 0, 2);
  CompoundParameter period = new CompoundParameter("PERI", 1000, 300, 3000);
  CompoundParameter pos = new CompoundParameter("POS", 1, 0, 10);
  double timer = 0;

  SinLFO position = new SinLFO(0, PI, period);

  class MyFormatter extends Formatter {
    @Override public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  public Zebra(LX lx) {
    super(lx);
    addParameter("thickness", thickness);
    addParameter("period", period);
    addParameter("pos", pos);
    addModulator(position).start();
    Log.log("yayy");
    for (LXPoint p : model.points) {
      //   log("x, y, z, theta:" + p.xn + " " + p.yn + " " + p.zn + " " +
      //   p.theta);
    }
  }

  @Override public void run(double deltaMs) {
    if (getChannel().fader.getNormalized() == 0)
      return;

    timer = timer + deltaMs;
    for (LXPoint p : model.points) {
      float hue = .4f;
      float saturation;
      float brightness = 1;

      if (((position.getValue() + p.azimuth) % (PI)) > thickness.getValue()) {
        saturation = 0;
        brightness = 1;
      } else {
        saturation = 1;
        brightness = 0;
      }

      colors[p.index] = LX.hsb(360 * hue, 100 * saturation, 100 * brightness);
    }
  }
}
