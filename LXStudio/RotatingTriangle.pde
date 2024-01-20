

import heronarts.lx.LX;
import heronarts.lx.LXCategory;
import heronarts.lx.model.LXPoint;
import heronarts.lx.parameter.CompoundParameter;
import heronarts.lx.pattern.LXPattern;

@LXCategory("My Patterns") public class RotatingTriangle extends LXPattern {

private
  final CompoundParameter pointRadius =
      new CompoundParameter("Radius", 0.06, 0.01, 0.1)
          .setDescription("The radius of the points");

private
  final CompoundParameter linkSize =
      new CompoundParameter("LinkSize", 0.04, 0.01, 0.1)
          .setDescription("The size of the link between points");

private
  final CompoundParameter speed =
      new CompoundParameter("Speed", 0.05, 0, 1).setDescription("Speed");

private
  float time = 0;

public
  RotatingTriangle(LX lx) {
    super(lx);
    addParameter(pointRadius);
    addParameter(linkSize);
    addParameter(speed);
  }

private
  float[] movePoint(float time, float xFactor, float yFactor, float zFactor) {
    float x = 0.5f + 0.32f * (float)Math.sin(xFactor * time);
    float y = 0.5f + 0.3f * (float)Math.sin(yFactor * time);
    float z = 1.0f + 0.4f * (float)Math.sin(zFactor * time);
    return new float[]{x, y, z};
  }

private
  float getU(LXPoint p) { return p.yn; }

private
  float getV(LXPoint p) { return p.azimuth / 2.0 / PI; }

private
  float smoothstep(float edge0, float edge1, float x) {
    x = Math.max(0, Math.min((x - edge0) / (edge1 - edge0), 1));
    return x * x * (3 - 2 * x);
  }

private
  float dot(float[] a, float[] b) { return a[0] * b[0] + a[1] * b[1]; }

private
  float[] normalize(float[] a) {
    float length = (float)Math.sqrt(a[0] * a[0] + a[1] * a[1]);
    return new float[]{a[0] / length, a[1] / length};
  }

private
  float distance(float[] a, float[] b) {
    float dx = a[0] - b[0];
    float dy = a[1] - b[1];
    return (float)Math.sqrt(dx * dx + dy * dy);
  }

  @Override public void run(double deltaMs) {
    time += deltaMs * speed.getValuef() * .01f;
    float[] pointR = movePoint(time, 1.32f, 1.03f, 1.32f);
    float[] pointG = movePoint(time, 0.92f, 0.99f, 1.24f);
    float[] pointB = movePoint(time, 1.245f, 1.41f, 1.11f);

    for (LXPoint p : model.points) {
      float u = getU(p);
      float v = getV(p);
      float[] uv = new float[]{u, v};

      float[] vecToR = new float[]{pointR[0] - u, pointR[1] - v};
      float[] vecToG = new float[]{pointG[0] - u, pointG[1] - v};
      float[] vecToB = new float[]{pointB[0] - u, pointB[1] - v};

      float[] dirToR = normalize(vecToR);
      float[] dirToG = normalize(vecToG);
      float[] dirToB = normalize(vecToB);

      float distToR = distance(uv, pointR);
      float distToG = distance(uv, pointG);
      float distToB = distance(uv, pointB);

      float dotRG = dot(dirToR, dirToG);
      float dotGB = dot(dirToG, dirToB);
      float dotBR = dot(dirToB, dirToR);

      float radiusR = pointRadius.getValuef() * pointR[2];
      float radiusG = pointRadius.getValuef() * pointG[2];
      float radiusB = pointRadius.getValuef() * pointB[2];

      float fragColorR = 1.0f - smoothstep(distToR, 0.0f, radiusR);
      float fragColorG = 1.0f - smoothstep(distToG, 0.0f, radiusG);
      float fragColorB = 1.0f - smoothstep(distToB, 0.0f, radiusB);

      float linkStrengthRG =
          1.0f -
          smoothstep(dotRG, -1.01f,
                     -1.0f + (linkSize.getValuef() * pointR[2] * pointG[2]));
      float linkStrengthGB =
          1.0f -
          smoothstep(dotGB, -1.01f,
                     -1.0f + (linkSize.getValuef() * pointG[2] * pointB[2]));
      float linkStrengthBR =
          1.0f -
          smoothstep(dotBR, -1.01f,
                     -1.0f + (linkSize.getValuef() * pointB[2] * pointR[2]));

      float sumDistRG = distToR + distToG;
      float sumDistGB = distToG + distToB;
      float sumDistBR = distToB + distToR;

      float contribRonRG = 1.0f - (distToR / sumDistRG);
      float contribRonBR = 1.0f - (distToR / sumDistBR);

      float contribGonRG = 1.0f - (distToG / sumDistRG);
      float contribGonGB = 1.0f - (distToG / sumDistGB);

      float contribBonGB = 1.0f - (distToB / sumDistGB);
      float contribBonBR = 1.0f - (distToB / sumDistBR);

      fragColorR +=
          (linkStrengthRG * contribRonRG) + (linkStrengthBR * contribRonBR);
      fragColorG +=
          (linkStrengthGB * contribGonGB) + (linkStrengthRG * contribGonRG);
      fragColorB +=
          (linkStrengthBR * contribBonBR) + (linkStrengthGB * contribBonGB);

      //   float brightness = Math.max(fragColorR, Math.max(fragColorG,
      //   fragColorB)); colors[p.index] = LX.hsb(0, 0, brightness * 100);
      colors[p.index] = LX.rgb((int)(fragColorR * 255), (int)(fragColorG * 255),
                               (int)(fragColorB * 255));
    }
  }
}
