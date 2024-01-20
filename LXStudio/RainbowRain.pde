// Built from a shader by ChatGPT
import heronarts.lx.LX;
import heronarts.lx.pattern.LXPattern;
import heronarts.lx.model.LXPoint;

@LXCategory("Ascension") public
static class RainbowRain extends LXPattern {

private
  double timer = 0;
private
  float centerX = 0;
private
  float centerY = 0;

public
  RainbowRain(LX lx) { super(lx); }

  @Override public void run(double deltaMs) {
    // Update timer based on deltaMs
    timer += deltaMs;
    float iTime = (float)(timer / 1000.0);

    for (LXPoint p : model.points) {
      // Convert to 2D polar coordinates (r, theta)
      float x = p.xn - centerX;
      float y = p.yn - centerY;
      float r = (float)Math.sqrt(x * x + y * y);
      float theta =
          (float)Math.atan2(y, x) - (float)Math.sin(iTime) * r / 200.0f + iTime;

      float intensity = 0.5f + 0.25f * (float)Math.sin(15.0 * theta);

      // Adjust brightness to add blackness/darker areas
      float brightness =
          1.0f - smoothStep(0.4f, 0.6f, mod(theta / (float)Math.PI, 1.0f));

      // Set the color using LX.hsb
      colors[p.index] = LX.hsb(360 * theta / (float)Math.PI, 100 * intensity,
                               100 * brightness);
    }
  }

private
  float mod(float a, float b) { return (a % b + b) % b; }

private
  float smoothStep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0f, 1.0f);
    return x * x * (3 - 2 * x);
  }

private
  float clamp(float x, float lowerlimit, float upperlimit) {
    if (x < lowerlimit)
      x = lowerlimit;
    if (x > upperlimit)
      x = upperlimit;
    return x;
  }
}
