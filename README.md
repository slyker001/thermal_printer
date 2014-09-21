Impresora Térmica
=================

Este proyecto implementa una impresora térmica controlada por un
[Arduino](http://arduino.cc) alrededor del módulo [Panasonic
EPT-1019HW2](doc/EPT-1019HW2.pdf).

El módulo de impresión utiliza papel térmico de 2" (58 mm) y tiene una
resolución horizontal de 96 puntos. Este proyecto incluye una
tipografía de 6x8 puntos que permite imprimir 32 caracteres por linea.

### Mecanica del módulo de impresión

Cada punto de impresión (vertical y horizontal) corresponde a dos pasos
de los motores. Los limites del módulo de impresión, expresados en
pasos de motor, son:

```
3     5     68                                                      384
|.....|.....|.........................................................|
 home  head  min                                                     max
       park
```

Prototipo
---------

Esquematicos
------------

Dibujados con [gschem](http://www.gpleda.org) 1.6:

**[sch/motors.sch](sch/motors.sch)**

![motors.png](sch/motors.png "motors.png")

_Sección de potencia y control para los motores a pasos._

![dtp.png](sch/dtp.png "dtp.png")

_`sch/dtp.sch': Fuente de poder; sección de potencia y control para el cabezal
térmico; conexiones con Arduino y módulo Panasonic; botones y leds._

Firmware
--------

Para Arduino 0018:

**[sketch/DTP/Conf.h](sketch/DTP/Conf.h)**

Definición de puertos y características mecánicas del módulo de impresión.

**[sketch/DTP/Font.h](sketch/DTP/Font.h)**

Definición de la tipografía.

**[sketch/DTP/DTP.pde](sketch/DTP/DTP.pde)**

Código fuente del firmware.

### Tipografía

Definida en [sketch/DTP/Font.h](sketch/DTP/Font.h), eseta indexada por
su código ASCII.

5 columnas de bytes, por ejemplo para la A (índice 97):

`#define FT97  0x1F, 0x24, 0x44, 0x24, 0x1F`

Y corresponde a:

```       
MSB  .....
     ..X..
     .X.X. 
     X...X
     X...X
     XXXXX
     X...X
LSB  X...X
```

Al momento de imprimir se agrega automáticamente una columna en blanco
para separar los caracteres, así tenemos una tipografía de 6x8 puntos.

### Comandos

Comunicación vía serial a 9600 bps, comandos disponibles:

**Acciones básicas**

   p - Head park
   u - Head up
   m - Head max
   r - Head return
   f - Paper forward
   e - Paper feed

**Pruebas**

   x - Basic
   y - Graphics
   z - Typography

**Modo de operación**

   a - ASCII
   b - Binary
   s - Status

El modo ASCII tiene un buffer de 32 caracteres que corresponden a una
linea. Para cancelar la linea y regresar al modo comando enviar ESC
(0x1B).

Autor
-----

Manuel Rábade <[manuel@rabade.net](mailto:manuel@rabade.net)>

Licencia
--------

Esta obra está bajo una [licencia de Creative Commons
Reconocimiento-CompartirIgual 4.0
Internacional](http://creativecommons.org/licenses/by-sa/4.0/).
