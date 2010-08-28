/*
  Copyright 2009-2010 Manuel Rábade <manuel@rabade.net>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <avr/pgmspace.h>
#include <Stepper.h>
#include "Conf.h"
#include "Font.h"

#define STATUSON  digitalWrite(STATUS, HIGH)
#define STATUSOFF digitalWrite(STATUS, LOW)

#define PAPERON  digitalWrite(EN1, HIGH)
#define PAPEROFF digitalWrite(EN1, LOW)
#define HEADON   digitalWrite(EN2, HIGH)
#define HEADOFF  digitalWrite(EN2, LOW)

Stepper motorPaper (SPRPAPER, IN1, IN2);
Stepper motorHead (SPRHEAD, IN1, IN2);

boolean feedBtn;
int headPos;
byte buffer[192];
prog_uchar ascii[] PROGMEM = { 
  FT0,   FT1,   FT2,   FT3,   FT4,   FT5,   FT6,   FT7,   FT8,   FT9, 
  FT10,  FT11,  FT12,  FT13,  FT14,  FT15,  FT16,  FT17,  FT18,  FT19, 
  FT20,  FT21,  FT22,  FT23,  FT24,  FT25,  FT26,  FT27,  FT28,  FT29, 
  FT30,  FT31,  FT32,  FT33,  FT34,  FT35,  FT36,  FT37,  FT38,  FT39, 
  FT40,  FT41,  FT42,  FT43,  FT44,  FT45,  FT46,  FT47,  FT48,  FT49, 
  FT50,  FT51,  FT52,  FT53,  FT54,  FT55,  FT56,  FT57,  FT58,  FT59, 
  FT60,  FT61,  FT62,  FT63,  FT64,  FT65,  FT66,  FT67,  FT68,  FT69, 
  FT70,  FT71,  FT72,  FT73,  FT74,  FT75,  FT76,  FT77,  FT78,  FT79, 
  FT80,  FT81,  FT82,  FT83,  FT84,  FT85,  FT86,  FT87,  FT88,  FT89, 
  FT90,  FT91,  FT92,  FT93,  FT94,  FT95,  FT96,  FT97,  FT98,  FT99, 
  FT100, FT101, FT102, FT103, FT104, FT105, FT106, FT107, FT108, FT109, 
  FT110, FT111, FT112, FT113, FT114, FT115, FT116, FT117, FT118, FT119, 
  FT120, FT121, FT122, FT123, FT124, FT125, FT126, FT127 };

void setup (void) {
  // pins setup
  pinMode(HOME, INPUT);
  pinMode(FEED, INPUT);
  pinMode(STATUS, OUTPUT);
  pinMode(EN1, OUTPUT);
  pinMode(EN2, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(CLK, OUTPUT);
  pinMode(DATA, OUTPUT);
  STATUSOFF;

  // software setup
  feedBtn = false;
  motorPaper.setSpeed(RPMPAPER);
  motorHead.setSpeed(RPMHEAD);

  // printer setup
  headOff();
  headPark();

  // serial setup
  Serial.begin(9600);
  Serial.println("+");
  Serial.print("? ");
  STATUSON;
}

void loop (void) {
  byte in;
  if (digitalRead(FEED) == HIGH) {
    feedBtn = true;
  }
  if (digitalRead(FEED) == LOW && feedBtn) {
    STATUSOFF;
    Serial.println();
    feedBtn = false;
    paperFeed();
    Serial.print("? ");
    STATUSON;
  }
  if (Serial.available() > 0) {
    STATUSOFF;
    in = Serial.read();
    Serial.println(in);
    switch (in) {
      // actions
    case 'p':
      headPark();
      break;
    case 'u':
      headUp();
      break;
    case 'm':
      headMax();
      break;
    case 'r':
      headReturn();
      break;
    case 'f':
      paperForward();
      break;
    case 'e':
      paperFeed();
      break;
      // tests
    case 'x':
      testBasic();
      break;
    case 'y':
      testGraphic();
      break;
    case 'z':
      testAscii();
      break;
      // modes
    case 'a':
      modeAscii();
      break;
    case 'b':
      modeBinary();
      break;
    case 's':
      Serial.println("!");
      break;
      // default
    default:
      modeHelp();
      break;
    }
    Serial.print("? ");
    STATUSON;
  }
}

/* modes */

void modeAscii (void) {
  boolean s;
  do {
    Serial.print("> ");
    s = _readAscii();
    Serial.println();
  } while (s);
}

boolean _readAscii (void) {
  byte in;
  int b = 0;
  while (1) {
    if (Serial.available() > 0) {
      in = Serial.read();
      if (in == 0x1B) {
        // exit on ESC
        return false;
      }
      Serial.print(in);
      bufferAscii(in, b * 6);
      b++;
      if (b == 32) {
        bufferPrint();
        return true;
      }
    }
  }
}

void modeBinary (void) {
  Serial.println("!");  
}

void modeHelp (void) {
  Serial.println("modes:");
  Serial.println("a - binary mode");
  Serial.println("b - ascii mode");
  Serial.println("s - status");
  Serial.println();
  Serial.println("tests:");
  Serial.println("x - basic test");
  Serial.println("y - graphic test");
  Serial.println("z - ascii test");
  Serial.println();
  Serial.println("actions:");
  Serial.println("p - head park");
  Serial.println("u - head up");
  Serial.println("m - head max");
  Serial.println("r - head return");
  Serial.println("f - paper forward");
  Serial.println("e - paper feed");
  Serial.println();
}

/* buffer */

void bufferPrint (void) {
  int i;
  headUp();
  HEADON;
  for (i = 0; i < BUFFER; i++) {
    headPrint(buffer[i]);
    headForward();
  }
  HEADOFF;
  headReturn();
  paperForward();
}

void bufferAscii (byte c, int p) {
  int i;
  for (i = 0; i < 5; i++) {
    buffer[p + i] = pgm_read_byte_near(ascii + c*5 + i);
  }
  buffer[p + 5] = 0x00;
}

/* basic actions */

void headPark (void) {
  HEADON;
  while (digitalRead(HOME)) {
    motorHead.step(-1);
  }
  motorHead.step(HEADHOME * -1);
  motorHead.step(HEADPARK);
  headPos = 0;
  HEADOFF;
}

void headUp (void) {
  int i;
  HEADON;
  for (i = 0; i < HEADMIN/2; i++) {
    delay(HEADWAIT);
    motorHead.step(2);
    delay(HEADWAIT);
  }
  headPos += HEADMIN;
  HEADOFF;
}

void headMax (void) {
  HEADON;
  motorHead.step(HEADMAX);
  headPos += HEADMAX;  
  HEADOFF;
}

void headForward (void) {
  //HEADON;
  motorHead.step(2);
  headPos += 2;
  //HEADOFF;
}

void headReturn (void) {
  HEADON;
  motorHead.step(headPos * -1);
  headPos = 0;
  HEADOFF;
}

void paperForward (void) {
  PAPERON;
  motorPaper.step(PAPERFWD * -1);
  PAPEROFF;
}

void paperFeed (void) {
  PAPERON;
  motorPaper.step(PAPERFEEDFWD * -1);
  motorPaper.step(PAPERFEEDREV);
  PAPEROFF;
}

/* thermal head */

void headPrint (byte b) {
  delay(HEADWAIT);
  shiftOut(DATA, CLK, MSBFIRST, b);
  delay(HEADPRN);
  shiftOut(DATA, CLK, MSBFIRST, 0x00);
  delay(HEADWAIT);
}

void headOff (void) {
  shiftOut(DATA, CLK, MSBFIRST, 0x00);
}


/* printer tests */

void testBasic (void) {
  int i;
  for (i = 0; i < 3; i++) {
    _testVertical();
  }
  paperForward();
}

void testGraphic (void) {
  _testVertical();
  _testHorizontal();
  _testPoint();
  _testBox();
  paperForward();
}

void testAscii (void) {
  int i, j;
  for (i = 0; i < 127; i) {
    for (j = 0; j < WIDTH; j++) {
      bufferAscii(i, j * 6);
      i++;
    }
    bufferPrint();
  }
  paperForward();
}

/* subtests */

void _testVertical (void) {
  int i;
  for (i = 0; i < BUFFER; i++) {
    if (i % 2 == 0) {
      buffer[i] = 0x0F;
    } else {
      buffer[i] = 0xF0;
    }
  }
  bufferPrint();
}

void _testHorizontal (void) {
  int i, j;
  for (i = 0; i < BUFFER; i) {
    for (j = 0; j < 6; j++) {
      buffer[i] = 0xAA;
      i++;
    }
    for (j = 0; j < 6; j++) {
      buffer[i] = 0x55;
      i++;
    }    
  }
  bufferPrint();
}

void _testPoint (void) {
  int i;
  for (i = 0; i < BUFFER; i++) {
    if (i % 2 == 0) {
      buffer[i] = 0xAA;
    } else {
      buffer[i] = 0x55;
    }
  }
  bufferPrint();
}

void _testBox (void) {
  int i, j, k;
  for (k = 0; k < 2; k++) {
    for (i = 0; i < BUFFER; i) {
      if (k == 0) {
        for (j = 0; j < 8; j++) {
          buffer[i] = 0x00;
          i++;
        }
      }
      for (j = 0; j < 16; j++) {
        buffer[i] = 0xFF;
        i++;
      }
      if (k == 1) {
        for (j = 0; j < 8; j++) {
          buffer[i] = 0x00;
          i++;
        }
      }
    }
    bufferPrint();
  }
}
