// In this file you can define your own custom patterns

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory(
    "Form") public static class EthanChaseFirstPattern extends LXPattern {

public
  final CompoundParameter centerDistance =
      new CompoundParameter("centerDistance", 0, 1)
          .setDescription("Blah center of the spiral");

  SawLFO saw1 = new SawLFO("blahSAW1", 0, 1, 3000);
  SawLFO saw2 = new SawLFO("blahSAW2", 0, 1, 3000);

public
  EthanChaseFirstPattern(LX lx) {
    super(lx);
    addParameter("centerDistance", this.centerDistance);
    addModulator(saw1);
    addModulator(saw2);
    saw1.start();
    saw2.start();
    System.out.println("test1");
    LX.error("test2");
  }

public
  void run(double deltaMs) {
    float centerDistance = this.centerDistance.getValuef();
    float saw1Value = this.saw1.getValuef();
    float saw2Value = this.saw2.getValuef();
    System.out.println("saw1: " + saw1Value + " saw2: " + saw2Value +
                       " centerDistance: " + centerDistance);

    float n = 0;
    for (LXPoint p : model.points) {
      float theta_center = saw1Value * 2 * PI;
      float y_center = saw2Value;
      float x_center = (float)(Math.sin(theta_center)) * .5 + .5;
      float z_center = (float)(Math.cos(theta_center)) * .5 + .5;

      float distance_to_center =
          sqrt(pow(p.xn - x_center, 2) + pow(p.yn - y_center, 2) +
               pow(p.zn - z_center, 2));
      if (distance_to_center < centerDistance) {
        System.out.println("x, y, z" + x_center + " " + y_center + " " +
                           z_center);
        float brightness = 100 - distance_to_center * 100 / centerDistance;
        colors[p.index] = LXColor.gray(brightness);
      }
    }
  }
}
