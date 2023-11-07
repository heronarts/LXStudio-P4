import java.util.logging.Logger;
import java.util.logging.FileHandler;
import java.util.logging.SimpleFormatter;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Ascension") public static class RingPattern extends LXPattern {
  class MyFormatter extends Formatter {
    @Override public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  Logger logger;

  CompoundParameter sweepPeriod =
      new CompoundParameter("sweepPeriod", 1000, 100, 5000)
          .setDescription("sweepPeriod");

  CompoundParameter ringDistance =
      new CompoundParameter("ringDistance", 0, 0, 1)
          .setDescription("ringDistance");

  CompoundParameter width =
      new CompoundParameter("width", 0, 0, 1).setDescription("width");

  CompoundParameter fade =
      new CompoundParameter("fade", 0, 0, 1).setDescription("fade");

  ColorParameter myColor = new ColorParameter("Color", LXColor.RED);

  SawLFO centerY = new SawLFO("centerY", 1, 0, sweepPeriod);

public
  RingPattern(LX lx) {
    super(lx);
    this.setupLogger();

    addParameter("sweepPeriod", this.sweepPeriod);
    addParameter("ringDistance", this.ringDistance);
    addParameter("width", this.width);
    addParameter("fade", this.fade);
    addParameter("myColor", this.myColor);
    addModulator(centerY);
    centerY.start();
  }

  void setupLogger() {
    try {
      FileHandler fh;
      this.logger = Logger.getLogger("MyLog");
      fh = new FileHandler("/tmp/mylog.log", true);
      this.logger.addHandler(fh);
      MyFormatter formatter = new MyFormatter();
      fh.setFormatter(formatter);
      // fh.setFlushOnWrite(true);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  void log(String message) { this.logger.info(message); }

public
  void run(double deltaMs) {
    float centerY = this.centerY.getValuef();
    // float centerY = 0;
    if (centerY < .1) {

      log("centerY: " + centerY);
    }
    float ringDistance = this.ringDistance.getValuef();
    float width = this.width.getValuef();
    float fade = this.fade.getValuef();
    for (LXPoint p : model.points) {
      float distance = Math.abs(p.yn - centerY);
      distance = distance % ringDistance;
      if (distance > ringDistance / 2) {
        distance = ringDistance - distance;
      }
      if (distance < width) {
        colors[p.index] = LXColor.hsb(this.myColor.hue.getValuef(),
                                      this.myColor.saturation.getValuef(),
                                      this.myColor.brightness.getValuef());
      } else {
        // colors[p.index] = LXColor.gray(0);
        float fadeDistance = distance - width;
        float brightness = 100 - fadeDistance * 100 / fade;
        if (brightness < 0) {
          brightness = 0;
        }
        colors[p.index] =
            LXColor.hsb(this.myColor.hue.getValuef(),
                        this.myColor.saturation.getValuef(), brightness);
      }
    }
  }
}