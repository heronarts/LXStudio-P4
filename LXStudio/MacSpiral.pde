// https://www.shadertoy.com/view/WsccDj
import heronarts.lx.LX;
import heronarts.lx.LXCategory;
import heronarts.lx.model.LXPoint;
import heronarts.lx.pattern.LXPattern;

@LXCategory("Ascension") public class MacSpiral extends LXPattern {

public
  MacSpiral(LX lx) { super(lx); }

private
  float time = 0;

  final int nSteps = 64;
  final float PI = 3.141592f;
  final Vec3 cm_A = new Vec3(0.5f, 0.5f, 0.5f);
  final Vec3 cm_B = new Vec3(0.5f, 0.5f, 0.5f);
  final Vec3 cm_C = new Vec3(1.0f, 1.0f, 0.5f);
  final Vec3 cm_D = new Vec3(0.8f, 0.9f, 0.3f);

  Vec2 rotate2D(Vec2 st, float angle) {
    st = st.subtract(new Vec2(0.5f, 0.5f));
    float cosA = (float)Math.cos(angle);
    float sinA = (float)Math.sin(angle);
    st = new Vec2(cosA * st.u - sinA * st.v, sinA * st.u + cosA * st.v);
    st = st.add(new Vec2(0.5f, 0.5f));
    return st;
  }

  float ring(float e0, float d, float f) {
    float inner = smoothstep(e0, e0 + d, f);
    float outer = smoothstep(e0 + d, e0 + 2 * d, f);
    return inner - outer;
  }

public
  float smoothstep(float edge0, float edge1, float x) {
    // Scale, and clamp x to 0..1 range
    x = clamp((x - edge0) / (edge1 - edge0), 0.0f, 1.0f);
    // Evaluate polynomial
    return x * x * (3 - 2 * x);
  }

public
  float clamp(float value, float minVal, float maxVal) {
    return Math.max(minVal, Math.min(maxVal, value));
  }

  Vec3 colormap(float t) {
    Vec3 term = cm_C.scale(t).add(cm_D);
    Vec3 cosTerm = new Vec3((float)Math.cos(2.0 * PI * term.x),
                            (float)Math.cos(2.0 * PI * term.y),
                            (float)Math.cos(2.0 * PI * term.z));
    return cm_A.add(cm_B.multiply(cosTerm));
  }

  @Override public void run(double deltaMs) {
    time += deltaMs / 1000.0f; // Update time

    for (LXPoint p : model.points) {
      Vec2 uv = new Vec2(Vec2.getU(p), Vec2.getV(p));
      // float ar = lx.width / lx.height;
      // uv.u = (uv.u - 0.5f) * ar + 0.5f;

      Vec2 pOrig = new Vec2(uv.u, uv.v);
      Vec3 col = new Vec3(0.0f, 0.0f, 0.0f);

      float cos_t = (float)Math.cos(time * 0.35f) * 64.0f;

      pOrig = pOrig.subtract(new Vec2(0.5f, 0.5f)).scale(1.35f);

      Vec2 polar =
          new Vec2(pOrig.length(), (float)Math.atan2(pOrig.v, pOrig.u) + PI);

      for (int i = 0; i < nSteps; ++i) {
        float rd = (float)(i + 1) / nSteps;
        float ring_x = (float)Math.sin(polar.v * 3.0f + rd * cos_t) - 2.0f;
        float f = ring(0.01f, 0.5f, polar.u + ring_x);

        col = col.add(colormap(rd * 2.0f + time * 0.3f).scale(f));
        polar.u *= 1.2f;
      }
      col = col.scale(0.5f);

      int retColor =
          LXColor.rgb(Math.min(255, Math.max(0, (int)(col.x * 255))),
                      Math.min(255, Math.max(0, (int)(col.y * 255))),
                      Math.min(255, Math.max(0, (int)(col.z * 255))));

      colors[p.index] = retColor;
    }
  }
}
