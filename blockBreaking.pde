/*--------------- setup ---------------*/
void setup() {
  size(500, 600);
  read_highScore();
  minim = new Minim( this );
  se = minim.loadSample( "se.mp3" );
  //以下リトライ時変数初期化
  dx = 3;
  dy = 3;
  lifeMax = 3; //最初のライフの数(-1でGameOver)
  gameMode = "first";
  x = random(10, width - 10);
  y = 271;
  count = 0;
  lifeMiss = 0;
  score1 = 0;
} 
/*---------- Variable declaration ----------*/
import ddf.minim.*; //以下3つ音関連
Minim minim;
AudioSample se;
String gameMode; //ゲームのモード管理
float ballX = 10; //ボールのx軸の直径
float ballY = 10; //ボールのy軸の直径
float x; //ボールの中心x座標
float y; //ボールの中心y座標
float dx; //ボールがx軸方向に進む速度
float dy; //ボールがy軸方向に進む速度
int barLong = 50; //バーの横の長さ
int count; //反射バーに当たった回数
int score; //総合スコア
int score1; //ブロック破壊からくるスコア
int highScore = 0; //ハイスコア
int barX = 50; //バーの初期位置
int lifeNow; //今のライフ
int lifeMiss; //ミスの回数
int lifeMax ; //最初のライフの数
int Clear; //クリア判定
String line; //ハイスコアを読み込むときに使用
int [][] block = new int[6][8]; //ブロックに関する多重配列
/*---------------- function ----------------*/
/*------- title -------*/
void title() {
  redefinition(); //ブロックのライフを挿入
  background(0);
  fill(255, 255, 0);
  textAlign(CENTER);
  PFont font = createFont("PT Mono", 45); //文字化け対策1
  textFont(font); //文字化け対策2
  text("ブロック崩し", width/2, height/2 - 20);
  textSize(15);
  fill(255);
  text("Control type exists TWO!", width/2, height*2/3 - 27);
  text("Click start! Control : mouse pointer", width/2, height*2/3);
  text("Push space start! Control : RIGHT and LEFT key", width/2, height*2/3+20);
  textAlign(LEFT);
}
/*----- Game Mode Celect (Mouse)-----*/
void mousePressed() {
  if (gameMode == "first") { //titleのとき
    gameMode = "typeMouse"; //クリックでマウスモード
  }
}
/*----- Game Mode Celect (key)-----*/
void keyPressed() {
  if (gameMode == "first") { //titleのとき
    if (key == ' ' || key == '　') { //スペースキーでキーモード
      gameMode = "typeKey";
    }
  }
  if (gameMode == "typeKey") { //keyモードの時のバーの動かすコマンド
    if ((barX >= 1) &&( barX <= width - barLong - 1 )) {
      if (key == CODED) {
        if (keyCode == RIGHT) {
          barX += 17;
        } else if (keyCode == LEFT) {
          barX -= 17;
        }
      }
    }
  }
  if (gameMode == "typeGOver") { //ゲームオーバーのとき
    if (key == 'r' || key == 'R') { //Rキーでリトライ
      gameMode = "first"; //titleの呼び出し
      setup(); //数値の初期化
    } else if (key == 'e'|| key == 'E') { //Eキーで終了
      exit();
    }
  }
  if (gameMode == "typeGClear") { //ゲームクリアのとき
    if (key == 'n' || key == 'N') { //Nキーでニューゲーム
      gameMode = "first"; //titleの呼び出し
      setup(); //数値の初期化
    } else if (key == 'e'|| key == 'E') { //Eキーで終了
      exit();
    }
  }
}
/*----- wall reflect -----*/
void WReflect() {
  if (y > height - ballY/2) { //下
    x = random(10, width - 10); //Miss処理 ボールの位置を戻す
    y = 250;
    lifeMiss += 1; //Missカウント
  } else if (y < ballY/2 + 2) { //上
    dy *= -1;
    se.trigger(); //音の再生
  } else if (x > width - ballX/2 || x < ballX/2 - 2) { //左右
    dx *= -1;
    se.trigger(); //音の再生
  }
}
/*----- make block -----*/
void blockDraw() {
  int i, j;
  for (i = 0; i < 6; i++) { //ブロックライフ参照
    for (j = 0; j < 8; j++) {
      switch(block[i][j]) {
      case 1: //ライフが1のとき
        fill(250);
        break;
      case 2: //ライフが2のとき
        fill(150);
        break;
      case 3: //ライフが3のとき
        fill(50);
        break;
      }
      if (block[i][j] > 0) { //ライフが1以上ならブロックの表示
        rect(j * 50 + 55, i * 30 + 50, 40, 20);
        fill(255);
      }
    }
  }
}
/*-----block reflect -----*/
void BReflect() {
  for ( int i = 0; i < 6; i++ ) { //ブロック参照
    for ( int j = 0; j < 8; j++ ) {
      if ( block[i][j] > 0 ) {
        if ( x >= j * 50 + 53 && x <= j * 50 + 97 && y >= i * 30 + 43 && y <= i * 30 + 47 //上
        || x >= j * 50 + 53 && x <= j * 50 + 97 && y >= i * 30 + 73 && y <= i * 30 + 77) { //下
          dy *= -1;
          block[i][j] --; //ブロックのライフを1削る
          se.trigger(); //音の再生
        }
        if ( x >= j * 50 + 48 && x <= j * 50 + 53 && y >= i * 30 + 48 && y <= i * 30 + 72 //左
        || x >= j * 50 + 95 && x <= j * 50 + 101 && y>= i * 30 + 48 && y <= i * 30 + 72 ) { //右
          dx *= -1;
          block[i][j] --; //ブロックのライフを1削る
          se.trigger(); //音の再生
        }
        if ( x > j * 50 + 57 && x < j * 50 + 93 && y > i * 30 + 52 && y < i * 30 + 68) { //ブロックの中にめり込んだ場合
          dx *= -1;
          dy *= -1;
          block[i][j] --;
          se.trigger(); //音の再生
        }
      }
    }
  }
}
/*----- Redefinition -----*/
void redefinition() { //ゲーム開始時にブロックのライフを多重配列に数値を挿入
  int i, j;
  for (i = 0; i < 6; i++) {
    for (j = 0; j < 8; j++) {
      if (i == 0 || i == 1) {
        block[i][j] = 3;
      } else if (i == 2 || i == 3) {
        block[i][j] = 2;
      } else {
        block[i][j] = 1;
      }
    }
  }
}
/*-------.game type mouse-------*/
void game_typeMouse() { 
  noCursor() ; 
  background(192, 192, 255);
  ellipse(x, y, ballX, ballY);
  x += dx;
  y += dy;
  WReflect();
  BReflect();
  blockDraw();
  life();
  score();
  //反射バー typeMouse
  rect(mouseX - barLong/2, height - 40, barLong, 5, 7);
  barX = mouseX;
  if (y >= height - 47 && y <= height - 40) {
    if (x >= barX - barLong/2 - 5 && x <= barX + barLong - barLong/2 + 5 ) {
      if ((x < mouseX - barLong/2 + 5 && dx > 0)
        || (x > mouseX - barLong/2 + 45 && dx < 0)) { //バーの端なら逆反射
        dx *= -1;
      }
      dy = -(3 - abs(x - barX)*0.1) ; //ボールの接触位置で反射角度を変える(mouse用)
      count += 1;
      se.trigger(); //音の再生
    }
  }
  clearCheck();
}
/*----- game type key -----*/
void game_typeKey() {
  cursor();
  background(192, 192, 255);
  ellipse(x, y, ballX, ballY);
  x += dx;
  y += dy;
  WReflect();
  BReflect();
  blockDraw();
  life();
  score();
  //反射バー typeKey
  rect(barX, height - 40, barLong, 5, 7);
  if (y >= height - 47 && height - 40 <= y) {
    if ((x >= barX) && (x <= barX +barLong) ) {
      if (x < barX + 5 || x > barX + 45) { //バーの端なら逆反射
        dx *= -1;
      }
      dy = (3 - abs(x - barX + 25)*0.1); //ボールの接触位置で反射角度を変える(key用)
    }
    count += 1;
    se.trigger(); //音の再生
  }
  //key専用 反射バー側面めり込み対策
  if (barX <= 0) {
    barX = 1;
  }
  if ( barX >= width - barLong ) {
    barX = width - barLong - 1;
  }
  clearCheck();
}
/*------- score -------*/
/*-- calculate --*/
void score() {
  for ( int i = 0; i < 6; i++ ) {
    for ( int j = 0; j < 8; j++ ) {
      if ( block[i][j] == 0 ) { //ブロックのライフが0になったら
        score1 += 1500; //1500ポイント
        block[i][j] -= 1; //ライフを-1にしてスコア再加算防止
      }
    }
  }
  highScore = read_highScore(); //ハイスコア読み込み
  textSize(16);
  score = score1 + count * 100; //スコア計算
  text("SCORE", 5, 18);
  text(score, 70, 18);
  save_highScore(score); //ハイスコア記録
}
/*-- read --*/
int read_highScore() {
  BufferedReader reader = createReader("HighScore.txt");
  try {
    line = reader.readLine(); //1行ずつ読み込む
  }
  catch (IOException e) {
    line = null;
  }
  if (line == null) {
    noLoop(); //nullが返ってきたら終了する
  }
  return int(line);
}
/*-- save --*/
void save_highScore(int s) {
  if (highScore < s) {  //プレイスコアがハイスコアを超えた場合
    PrintWriter   Output;
    Output = createWriter("HighScore.txt");
    Output.print(s); //スコアを記録
    Output.flush(); //即時終了防止
    Output.close();
  }
}
/*----- life -----*/
void life() {
  lifeNow = lifeMax - lifeMiss ;
  textSize(16);
  text("LIFE", 5, 31);
  text(lifeNow + 1, 70, 31);
}
/*----- clear check -----*/
void clearCheck() {
  Clear = 1;
  for ( int i = 0; i < 6; i++ ) {
    for ( int j = 0; j < 8; j++ ) {
      if ( block[i][j] > 0 ) {
        Clear = 0; //ブロックのライフが残ってたら0にする
      }
    }
  }
}
/*----- game over -----*/
void gameOver() {
  cursor();
  text("LIFE  " + lifeNow, 10, 31);
  background(0);
  textAlign(CENTER);
  textSize(30);
  text("Game Over", width/2, height/2 -10);
  textSize(20);
  text("score "+score, width/2, height/2 + 30);
  text("Hisocre "+highScore, width/2, height/2 + 55);
  text("Retry R key!", width/2, height/2 + 90);
  text("Game End E key!", width/2, height/2 + 120);
}
/*----- game clear -----*/
void gameClear() {
  cursor();
  background(255);
  textAlign(CENTER);
  fill(0);
  textSize(30);
  text("Game Clear!!", width/2, height/2 -10);
  textSize(20);
  text("score "+score, width/2, height/2 + 30);
  text("Hisocre "+highScore, width/2, height/2 + 55);
  text("New Game : N key!", width/2, height/2 + 90);
  text("Game End E key!", width/2, height/2 + 120);
}
/*----------------- draw -----------------*/
void draw() {
  if (gameMode =="first") {
    title();
  }
  if (gameMode == "typeMouse") {
    game_typeMouse();
  }
  if (gameMode == "typeKey") {
    game_typeKey();
  }
  if (lifeNow == -1 && gameMode != "first") {
    gameMode = "typeGOver";
    gameOver();
  }
  if ( Clear == 1 && gameMode !="first") { 
    gameMode = "typeGClear";
    gameClear();
  }
}
