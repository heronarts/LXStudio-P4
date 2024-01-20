public class Vec3 {
  public float x;
  public float y;
  public float z;

  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public Vec3 add(Vec3 other) {
    return new Vec3(this.x + other.x, this.y + other.y, this.z + other.z);
  }

  public Vec3 multiply(Vec3 other) {
    return new Vec3(this.x * other.x, this.y * other.y, this.z * other.z);
  }

  public Vec3 scale(float factor) {
    return new Vec3(this.x * factor, this.y * factor, this.z * factor);
  }

  public float length() { return (float)Math.sqrt(x * x + y * y + z * z); }
}
