
import heronarts.lx.LX;
import heronarts.lx.modulator.SinLFO;
import heronarts.lx.parameter.CompoundParameter;
import heronarts.lx.pattern.LXPattern;
import heronarts.lx.model.LXPoint;

public
static class Zebra extends LXPattern {

  CompoundParameter thickness = new CompoundParameter("THIC", 1, 0, 6);
  CompoundParameter period = new CompoundParameter("PERI", 1000, 300, 3000);
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
    addModulator(position).start();
    Log.log("zebra init");
  }

  @Override public void run(double deltaMs) {
    if (getChannel().fader.getNormalized() == 0)
      return;

    timer = timer + deltaMs;
    for (LXPoint p : model.points) {
      float hue = .4f;
      float saturation = 1;
      float brightness = 1;

      double pos1 = position.getValue();
      double pos2 = position.getValue() + PI;

      float theta_distance1 = (float)Math.abs(p.azimuth - pos1);
      float theta_distance2 = (float)Math.abs(p.azimuth - pos2);
      float min_distance = Math.min(theta_distance1, theta_distance2);
      float capped_distance =
          Math.min(min_distance, (float)thickness.getValuef());
      // min_distance is going from 0 to PI
      // remap from 0 to distance
      // then map it from 100 to 0
      brightness = 1 - (capped_distance / (float)thickness.getValuef());

      colors[p.index] = LX.hsb(360 * hue, 100 * saturation, 100 * brightness);
    }
  }
}
