import heronarts.lx.LX;
import heronarts.lx.model.LXPoint;
import heronarts.lx.modulator.SawLFO;
import heronarts.lx.parameter.BoundedParameter;
import heronarts.lx.pattern.LXPattern;

public
class Jellyfish extends LXPattern {

private
  float speedMult = 1000;
  final BoundedParameter hue = new BoundedParameter("hue", 135, 0, 360);
  final BoundedParameter circleRadius =
      new BoundedParameter("circleRadius", .3, 1, 5);
  final BoundedParameter cy = new BoundedParameter("cy", 0.5, 0, 1.0);
  final BoundedParameter ca = new BoundedParameter("ca", 3, 0, 2 * PI);
  final BoundedParameter speedParam =
      new BoundedParameter("Speed", 1.5, 3, .01);
  final BoundedParameter glow = new BoundedParameter("glow", 100, 0, 400);
  final SawLFO wave = new SawLFO(0, 360, 1000);
  float total_ms = 0;
  int shrub_offset[];
private
  float max_height = 0.0f;

private
  float circleAz = 0f;
private
  float circleYN = 0f;
private
  double timeElapsed__ms = 5000;

public
  Jellyfish(LX lx) {
    super(lx);
    addModulator(wave).start();
    addParameter("hue", hue);
    addParameter("ca", ca);
    addParameter("cy", cy);
    addParameter("speed", speedParam);
    addParameter("glow", glow);
    addParameter("circleRadius", circleRadius);

    max_height = 0.0f;
    for (LXPoint cube : model.points) {
      if (max_height < cube.y) {
        max_height = cube.y;
      }
    }
  }

private
  float getCircleBrightness(LXPoint point, float circleAz, float circleYN) {
    // This is rough. We want the width and height of the circle to be about the
    // same. This assumes the circumference is the same as the height.
    float yn_to_az = 2 * PI;
    float az_wrapped_distance =
        Math.min(2 * PI - Math.abs(point.azimuth - circleAz),
                 Math.abs(point.azimuth - circleAz));
    float distance_to_center =
        (float)Math.sqrt(Math.pow(yn_to_az * (point.yn - circleYN), 2) +
                         Math.pow(az_wrapped_distance, 2));
    float brightCenter = 150;
    float brightness =
        brightCenter - distance_to_center * 100 / circleRadius.getValuef();
    if (brightness > 100) {
      return 100;
    }
    if (brightness < 0) {
      return 0;
    }
    // if (distance_to_center > circleRadius.getValuef()) {
    //   return 0;
    // }
    // return 100;
    return brightness;
  }

  @Override public void run(double deltaMs) {
    timeElapsed__ms += deltaMs * speedParam.getValuef();
    if (timeElapsed__ms > 2000) {
      timeElapsed__ms = 0;
      circleAz = (float)Math.random() * 2 * PI;
      circleYN = (float)Math.random() * 1; // normalized coords
    }

    for (LXPoint point : model.points) {
      //   float b = getCircleBrightness(point, circleAz, circleYN);
      float b = getCircleBrightness(point, ca.getValuef(), cy.getValuef());
      float h = hue.getValuef();
      colors[point.index] = LX.hsb(h, 100.0f, b);
    }
  }
}