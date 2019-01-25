LXModel buildModel() {
  // A three-dimensional grid model
  return new GridModel3D();
}

public static class GridModel3D extends LXModel {
  
  public final static int SIZE = 20;
  public final static int SPACING = 10;
  
  public GridModel3D() {
    super(new Fixture());
  }
  
  public static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int z = 0; z < SIZE; ++z) {
        for (int y = 0; y < SIZE; ++y) {
          for (int x = 0; x < SIZE; ++x) {
            addPoint(new LXPoint(x*SPACING, y*SPACING, z*SPACING));
          }
        }
      }
    }
  }
}
