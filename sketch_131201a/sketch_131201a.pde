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
    Rectangle[] faces = opencv.detect();
    noFill();
    stroke(255, 0, 0);
    image(opencv.getInput(), 0, 0);
    for (Rectangle face : faces)
    {
        negate(face);
        rect(face.x, face.y, face.width, face.height);
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
