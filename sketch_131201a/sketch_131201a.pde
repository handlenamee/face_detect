import gab.opencv.*;

import java.awt.Rectangle;
import processing.video.*;

OpenCV opencv;
Capture capture;
OpenCV partlyImage;
int threshold = 25;
ArrayList<Contour> contours;

void setup()
{
    opencv = new OpenCV(this, 320, 240);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    size(opencv.width, opencv.height);
    frameRate(24);
    capture = new Capture(this, 320, 240);
    capture.start();
}

void draw()
{
    if (capture.available() == true)
    {
        capture.read();
    }
    opencv.loadImage(capture);
    //ビデオのピクセルを操作できるようにする
    Rectangle[] faces = opencv.detect();
    noFill();
    stroke(255, 0, 0);
    image(opencv.getInput(), 0, 0);
    for (Rectangle face : faces)
    {
        //negate(face);
        rect(face.x, face.y, face.width, face.height);
        detectContour(face);
    }
}

//色を反転する（なぜか効いてない）
void negate(Rectangle face)
{
    loadPixels();
    //1ピクセルごとに色を調べる。
    for (int y = face.y; y < face.y + face.height; y++)
    {
        for (int x = face.x; x < face.x + face.width; x++)
        {
            int pixelIndex = y * width + x;
            //ビデオのピクセルを抜き出す
            int pixelColor = pixels[pixelIndex];

            //赤、緑、青をそれぞれ抽出する。
            int r = (pixelColor >> 16) & 0xff;
            int g = (pixelColor >> 8 ) & 0xff;
            int b = pixelColor & 0xff;

            //ウィンドウのピクセルに当てはめる
            pixels[pixelIndex] = color(255-r, 255-g, 255-b);
        }
    }
    updatePixels();    //画像を更新
}

void detectContour(Rectangle face)
{
    PImage faceImage = capture.get(
      face.x,
      face.y,
      face.width,
      face.height
    );

    image(faceImage, face.x, face.y);    
    
    partlyImage = new OpenCV(this, face.width, face.height);
    partlyImage.loadImage(faceImage);

    partlyImage.gray();
    partlyImage.threshold(threshold);
    contours = partlyImage.findContours();
  
    noFill();
    strokeWeight(3);
    
    for (Contour contour : contours)
    {
      stroke(255, 0, 0);
  
      beginShape();
      
      ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
  
      for (PVector point : points)
      {
        vertex(point.x + face.x, point.y + face.y);
      }
  
      endShape();
    }
}

void keyPressed()
{
  String message = "";
  
  if (keyCode == UP)
  {
    threshold += 1;
    if (threshold > 100)
    {
      threshold = 100;
    }
    message = "threshold: " + threshold;
  }
  
  if (keyCode == DOWN)
  {
    threshold -= 1;
    if (threshold < 0)
    {
      threshold = 0;
    }
    message = "threshold: " + threshold;
  }
  
  if (keyCode == ENTER)
  {
    writeToSVG();
    message = "create SVG.";
  }

  println(message);  
}

void writeToSVG()
{
  String linesString = "";

  for (Contour contour : contours)
  {
    ArrayList<PVector> points = contour.getPolygonApproximation().getPoints();
    int pointsLength = points.size();

    for (int index = 0; index < pointsLength - 1; index++)
    {
      PVector point1 = points.get(index);
      PVector point2 = points.get(index + 1);
      linesString +=
        "<line x1=\""
        + (int) point1.x
        + "\" y1=\""
        + (int) point1.y
        + "\" x2=\""
        + (int) point2.x
        + "\" y2=\""
        + (int) point2.y
        + "\" />";
    }
  }

  String[] svg = new String[3];
  
  svg[0] = "<svg width=\"640\" height=\"480\" viewRect=\"320, 240\"><g stroke=\"black\" fill=\"transparent\" stroke-width=\"1\">";

  svg[1] = linesString;

  svg[2] = "</g></svg>";

  saveStrings("test.svg", svg);
}
