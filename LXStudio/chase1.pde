import java.util.logging.Logger;
import java.util.logging.FileHandler;
import java.util.logging.SimpleFormatter;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory(
    "Form") public static class EthanChaseFirstPattern extends LXPattern {
  class MyFormatter extends Formatter {
    @Override public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  public final CompoundParameter centerDistance =
      new CompoundParameter("centerDistance", 0, 1)
          .setDescription("Blah center of the spiral");

  SawLFO saw1 = new SawLFO("blahSAW1", 0, 1, 3000);
  SawLFO saw2 = new SawLFO("blahSAW2", 0, 1, 3000);

  Logger logger;

public
  EthanChaseFirstPattern(LX lx) {
    super(lx);
    addParameter("centerDistance", this.centerDistance);
    addModulator(saw1);
    addModulator(saw2);
    saw1.start();
    saw2.start();
    LX.error("test2");
    this.setupLogger();
    log("hello test");
  }

  void setupLogger() {
    try {
      FileHandler fh;
      this.logger = Logger.getLogger("MyLog");
      fh = new FileHandler("mylog.log", true);
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
    float centerDistance = this.centerDistance.getValuef();
    float saw1Value = this.saw1.getValuef();
    float saw2Value = this.saw2.getValuef();
    log("saw1: " + saw1Value + " saw2: " + saw2Value +
        " centerDistance: " + centerDistance);

    float y_center = saw2Value;
    float theta_center = saw1Value * 2 * PI;
    float x_center = (float)(Math.sin(theta_center)) * .5 + .5;
    float z_center = (float)(Math.cos(theta_center)) * .5 + .5;
    float min_xn = 9999;
    float min_yn = 9999;
    float min_zn = 9999;
    float max_xn = -9999;
    float max_yn = -9999;
    float max_zn = -9999;
    for (LXPoint p : model.points) {
      float distance_to_center =
          sqrt(pow(p.xn - x_center, 2) + pow(p.yn - y_center, 2) +
               pow(p.zn - z_center, 2));
      if (distance_to_center < centerDistance) {
        float brightness = 100 - distance_to_center * 100 / centerDistance;
        colors[p.index] = LXColor.gray(brightness);
      } else {
        colors[p.index] = LXColor.gray(0);
      }

      // record max/min
      if (p.xn < min_xn) {
        min_xn = p.xn;
      }
      if (p.yn < min_yn) {
        min_yn = p.yn;
      }
      if (p.zn < min_zn) {
        min_zn = p.zn;
      }
      if (p.xn > max_xn) {
        max_xn = p.xn;
      }
      if (p.yn > max_yn) {
        max_yn = p.yn;
      }
      if (p.zn > max_zn) {
        max_zn = p.zn;
      }
    }

    log("min_xn: " + min_xn + " min_yn: " + min_yn + " min_zn: " + min_zn);
    log("max_xn: " + max_xn + " max_yn: " + max_yn + " max_zn: " + max_zn);
  }
}
