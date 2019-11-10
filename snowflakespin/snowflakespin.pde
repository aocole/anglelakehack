OPC opc;
PImage snowflake;
PShader blur;

void setup()
{
  size(640, 640, P3D);
  opc = new OPC(this, "127.0.0.1", 7890);
  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, true, false);

  snowflake = loadImage("snowflake2.png");
  blur = loadShader("blur.glsl");

  // Set up your LED mapping here
}

float rotation = 0;
void draw()
{
  background(0);
  translate(width/2, height/2);

  // Draw the image, centered at the mouse location
  float snowflakeSize = height * 0.7;
  rotation = (rotation + 0.5) % 360;
  rotate(radians(rotation));
  image(snowflake, -snowflakeSize/2, -snowflakeSize/2, snowflakeSize, snowflakeSize);
  for (int i = 0; i < 10; i++) {
    filter(blur);
  }
}
