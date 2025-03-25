PImage[] textures; 
ArrayList<Ball> balls;  
int framectr = 0;
float gravity = 0.1;  
void setup() {
  size(1000, 1000, P3D); 
  textures = new PImage[4]; 
  textures[0] = loadImage("1.jpg");
  textures[1] = loadImage("2.jpg");
  textures[2] = loadImage("3.jpg");
  textures[3] = loadImage("4.jpg");
  balls = new ArrayList<Ball>();  
}

void put_a_cube_at_here() {
  fill(255, 0, 0); 
  beginShape();
  vertex(300, 300, -300);  
  vertex(-300, 300, -300);
  vertex(-300, 300, 300);
  vertex(300, 300, 300);
  endShape(CLOSE);  

  fill(0, 255, 0);
  beginShape();
  vertex(300, -300, 300);
  vertex(-300, -300, 300);
  vertex(-300, -300, -300);
  vertex(300, -300, -300);
  endShape(CLOSE);

  fill(0, 0, 255);
  beginShape();
  vertex(300, 300, 300);
  vertex(300, 300, -300);
  vertex(300, -300, -300);
  vertex(300, -300, 300);
  endShape(CLOSE);

  // Left face (yellow)
  fill(255, 255, 0);
  beginShape();
  vertex(-300, 300, 300);
  vertex(-300, 300, -300);
  vertex(-300, -300, -300);
  vertex(-300, -300, 300);
  endShape(CLOSE);

  fill(255, 0, 255);
  beginShape();
  vertex(-300, 300, -300);
  vertex(300, 300, -300);
  vertex(300, -300, -300);
  vertex(-300, -300, -300);
  endShape(CLOSE);
  noStroke();
  noFill();
}


void draw() {
  background(0);
  translate(width/2, height/2, 0);
  stroke(255);

  String title_name = "%s(%s)'s rotating cube";
  String student_name = "Zhengxiang Sun";
  String unikey = "520534353"; 
  surface.setTitle(String.format(title_name, student_name, unikey));

  put_a_cube_at_here();
  for (Ball ball : balls) {
    ball.update(balls);
    ball.display();
  }

  framectr++;
}

void mousePressed() {
  PImage randomTexture = textures[int(random(textures.length))];  
  Ball newBall = new Ball(mouseX - width/2, mouseY - height/2, 0, randomTexture);
  balls.add(newBall);  // Add new ball to the list
}

class Ball {
  float x, y, z;
  PVector velocity;  

  PImage texture;
  PVector rotation;
  PVector rotation_speed;
  float gravityEffect = 3; 
  float bounceFactor = 0.7;  
  float stopThreshold = 0.1;
  PShape globe;
  float damping = 0.95;
  float spring = 0.01;

  Ball(float x, float y, float z, PImage texture) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.texture = texture;
    rotation =  new PVector(0,0,0);
    
    noStroke();
    //noFill();
    fill(255);
    globe = createShape(SPHERE,50);
    globe.setTexture(texture);
    ini_dir(); 
  }

  void ini_dir() {
    velocity = PVector.random2D();  
    velocity.mult(10); 
    velocity.z = -5;
  }

  void update(ArrayList<Ball> allBalls) {
    x += velocity.x;
    y += velocity.y;
    z += velocity.z;
    PVector velocity_speed = PVector.mult(velocity, 0.01);
    rotation.add(velocity_speed);

    if (x >= 250){
      x = 250; 
      velocity.x *= -bounceFactor;  
      velocity.y *= -bounceFactor;
      velocity_speed.x *= -bounceFactor;  
      velocity_speed.y *= -bounceFactor;
      velocity.z *= -bounceFactor;
    }
    else if(x <= -250){  
      x = -250;  
      velocity.x *= -bounceFactor; 
      velocity.y *= -bounceFactor;
      velocity_speed.x *= -bounceFactor; 
      velocity_speed.y *= -bounceFactor;
      velocity.z *= -bounceFactor;
    }
    else if (z >= 250){ 
      z = 250; 
      velocity.x *= -bounceFactor; 
      velocity.y *= -bounceFactor;
      velocity_speed.x *= -bounceFactor; 
      velocity_speed.y *= -bounceFactor;
      velocity.z *= -bounceFactor;
    }
    else if( z <= -250){  
      z = -250; 
      velocity.x *= -bounceFactor;  
      velocity.y *= -bounceFactor;
      velocity_speed.x *= -bounceFactor;  
      velocity_speed.y *= -bounceFactor;
      velocity.z *= -bounceFactor;
    }
    else if (y < 250 && y> -250) {
       velocity.y += gravity;  
    }
    else if (y >= 250) {
       y = 250;
       velocity.y *= -bounceFactor;  
       velocity.x *= -bounceFactor;
       velocity.z *= -bounceFactor;
      velocity_speed.x *= -bounceFactor;  
      velocity_speed.y *= -bounceFactor;
       if (abs(velocity.y) < stopThreshold) {
          velocity.y = 0; 
       }
    } 
    else if (y <= -250) {  // Hit the ceiling
      y = -250;
      velocity.y *= -bounceFactor;
      velocity.x *= -bounceFactor;
      velocity.z *= -bounceFactor;  
      velocity_speed.x *= -bounceFactor;
      velocity_speed.y *= -bounceFactor;
    }
    for (Ball other : allBalls) {
      if (other != this) {
        float dx = other.x - x;
        float dy = other.y - y;
        float dz = other.z - z;
        float distance = dist(this.x, this.y, this.z, other.x, other.y, other.z); 
        float minDist = 50 + 50;  

        if (distance < minDist) {
          float angleXY = atan2(dy, dx); 
          float angleZ = atan2(dz, sqrt(dx * dx + dy * dy)); 

          float targetX = x + cos(angleXY) * minDist;
          float targetY = y + sin(angleXY) * minDist;
          float targetZ = z + sin(angleZ) * minDist;

          float ax = (targetX - other.x) * spring;
          float ay = (targetY - other.y) * spring;
          float az = (targetZ - other.z) * spring;


          velocity.x = (velocity.x - ax) * damping;
          velocity.y = (velocity.y - ay) * damping;
          velocity.z = (velocity.z - az) * damping;

          other.velocity.x = (other.velocity.x + ax) * damping;
          other.velocity.y = (other.velocity.y + ay) * damping;
          other.velocity.z = (other.velocity.z + az) * damping;
        }
      }
    }
    
  }

void display() {
  pushMatrix();
  translate(x, y, z);  
  rotateX(rotation.x);
  rotateY(rotation.y);
  rotateZ(rotation.z);
  noStroke();
  shape(globe);
  popMatrix();
}
}
