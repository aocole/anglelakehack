import codeanticode.syphon.*;

OPC opc;
PImage img;
SyphonClient client;

void setup() {
  size(340, 340, P3D);
  // Create syhpon client to receive frames 
  // from the first available running server: 
  client = new SyphonClient(this);
  setupFC();
}

void setupFC()
{
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, true, false);
}

void draw() {
  background(0);
  if (client.newFrame()) {
    // The first time getImage() is called with 
    // a null argument, it will initialize the PImage
    // object with the correct size.
    img = client.getImage(img); // load the pixels array with the updated image info (slow)
    //img = client.getImage(img, false); // does not load the pixels array (faster)    
  }
  if (img != null) {
    image(img, 0, 0, width, height);  
  }
}

void keyPressed() {
  if (key == ' ') {
    client.stop();  
  } else if (key == 'd') {
    println(client.getServerName());
  }
}
