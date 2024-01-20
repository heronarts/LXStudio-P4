// https://www.shadertoy.com/view/mtyGWy
import heronarts.lx.LX;
import heronarts.lx.LXCategory;
import heronarts.lx.model.LXPoint;
import heronarts.lx.pattern.LXPattern;

@LXCategory("Ascension") public class GalaxySwim extends LXPattern {

public
  GalaxySwim(LX lx) { super(lx); }

private
  float time = 0;

private
  Vec3 palette(float t) {
    Vec3 a = new Vec3(0.5f, 0.5f, 0.5f);
    Vec3 b = new Vec3(0.5f, 0.5f, 0.5f);
    Vec3 c = new Vec3(1.0f, 1.0f, 1.0f);
    Vec3 d = new Vec3(0.263f, 0.416f, 0.557f);

    Vec3 ct = c.scale(t).add(d);
    Vec3 cosTerm = new Vec3((float)Math.cos(6.28318f * ct.x),
                            (float)Math.cos(6.28318f * ct.y),
                            (float)Math.cos(6.28318f * ct.z));

    return a.add(b.multiply(cosTerm));
  }

  @Override public void run(double deltaMs) {
    time += deltaMs / 1000.0f; // Update time

    Log.log("yrange " + model.yRange);
    for (LXPoint p : model.points) {
      Vec2 uv = new Vec2(1 - Vec2.getU(p), 1 - Vec2.getV(p));
      //   uv = uv.scale(2.0f).subtract(new Vec2(1.0f, model.yRange / 2.0f));
      //   uv = uv.scale(1.0f / model.yRange);

      Vec2 uv0 = new Vec2(uv.u, uv.v);
      Vec3 finalColor = new Vec3(0.0f, 0.0f, 0.0f);

      for (float i = 0.0f; i < 4.0f; i++) {
        uv = uv.scale(1.5f);
        uv = new Vec2(uv.u - (float)Math.floor(uv.u),
                      uv.v - (float)Math.floor(uv.v))
                 .subtract(new Vec2(0.5f, 0.5f));

        float d = uv.length() * (float)Math.exp(-uv0.length());

        Vec3 col = palette(uv0.length() + i * 0.4f + time * 0.4f);

        d = (float)Math.sin(d * 8.0f + time) / 8.0f;
        d = Math.abs(d);

        d = (float)Math.pow(0.01f / d, 1.2f);

        finalColor = finalColor.add(col.scale(d));
      }

      int retColor =
          LXColor.rgb(Math.min(255, Math.max(0, (int)(finalColor.x * 255))),
                      Math.min(255, Math.max(0, (int)(finalColor.y * 255))),
                      Math.min(255, Math.max(0, (int)(finalColor.z * 255))));

      colors[p.index] = retColor;
    }
  }
}
