import gab.opencv.*;

import java.awt.Rectangle;
import processing.video.*;

OpenCV opencv;
Capture capture;

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
    image(opencv.getInput(), 0, 0);
    Rectangle[] faces = opencv.detect();
    noFill();
    stroke(255, 0, 0);
    capture.loadPixels();
    for (Rectangle face : faces)
    {
        rect(face.x, face.y, face.x + face.width, face.y + face.height);
        negate(face);
    }
}

//色を反転する（なぜか効いてない）
void negate(Rectangle face)
{
    //1ピクセルごとに色を調べる。
    for (int y = 0; y < face.height; y++)
    {
        for (int x = 0; x < face.width; x++)
        {
            //ビデオのピクセルを抜き出す
            int pixelColor = capture.pixels[y*face.width + x];

            //赤、緑、青をそれぞれ抽出する。
            int r = (pixelColor >> 16) & 0xff;
            int g = (pixelColor >> 8 ) & 0xff;
            int b = pixelColor & 0xff;

            //ウィンドウのピクセルに当てはめる
            capture.pixels[y*face.width + x] = color(255-r, 255-g, 255-b);
        }
    }
    updatePixels();    //画像を更新
}
