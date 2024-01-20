import heronarts.lx.model.LXPoint;
public class Vec2 {
  public float u;
  public float v;

  // Constructor
  public Vec2(float u, float v) {
    this.u = u;
    this.v = v;
  }

  public Vec2(LXPoint p) {
    this.u = Vec2.getU(p);
    this.v = Vec2.getV(p);
  }

  // Subtract another vector from this vector
  public Vec2 subtract(Vec2 other) {
    return new Vec2(this.u - other.u, this.v - other.v);
  }

  // Add another vector to this vector
  public Vec2 add(Vec2 other) {
    return new Vec2(this.u + other.u, this.v + other.v);
  }

  // Calculate the length of the vector
  public float length() { return (float)Math.sqrt(u * u + v * v); }

  // Normalize the vector
  public Vec2 normalize() {
    float len = length();
    return new Vec2(u / len, v / len);
  }
  public Vec2 rotate(float angle) {
    float c = (float)Math.cos(angle);
    float s = (float)Math.sin(angle);
    return new Vec2(c * this.u - s * this.v, s * this.u + c * this.v);
  }

  public static float getU(LXPoint p) { return p.yn; }

  public static float getV(LXPoint p) {
    return (float)(p.azimuth / (2.0f * Math.PI));
  }

  public Vec2 scale(float factor) {
    return new Vec2(this.u * factor, this.v * factor);
  }

  // Other vector operations can be added here as needed
}
