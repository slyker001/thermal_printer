/*
  Copyright 2009-2010 Manuel Rodrigo Rábade García <manuel@rabade.net>

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

#define HOME   2
#define FEED   3
#define PAPER  4
#define STATUS 5 
#define EN1    6
#define EN2    7
#define IN1    8
#define IN2    9
#define CLK    10
#define DATA   11

#define RPMPAPER 60  // rev per min
#define RPMHEAD  120
#define SPRPAPER 380 // steps per rev
#define SPRHEAD  380

#define HEADHOME 3   // HP1
#define HEADPARK 5   // HP2
#define HEADMIN  68  // A
#define HEADMAX  384 // B
#define HEADPRN  15  // head hot time (ms)
#define HEADWAIT 5   // head cold time (ms)

#define PAPERFWD     36  // paper forward steps
#define PAPERFEEDFWD 400 // paper feed forward steps
#define PAPERFEEDREV 200 // paper feed reverse steps

#define BUFFER 192 // buffer length (HEADMAX/2)
#define WIDTH  32  // chars per line (BUFFER/6)
