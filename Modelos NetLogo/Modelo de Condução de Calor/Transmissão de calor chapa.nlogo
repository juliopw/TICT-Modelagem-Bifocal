extensions[bitmap]

globals [
  temperatura-media
  temperatura-media-anterior
  temperatura-maxima
  temperatura-minima

  temperatura-A
  temperatura-B
  temperatura-C
  temperatura-D
  temperatura-E

  cor_minima
  cor_maxima
]

breed [ pedacosdechapa pedacochapa ]
breed [ pontos-frios ponto-frio ]
breed [ pontos-quentes ponto-quente ]
breed [ sensores sensor ]


pedacosdechapa-own [
  temperatura

  temperatura-acima
  temperatura-abaixo
  temperatura-esquerda
  temperatura-direita
]

pontos-quentes-own [
  temperatura
]

pontos-frios-own [
  temperatura
]

sensores-own [
  temperatura
  nome
]

to setup
  clear-all
  reset-ticks

  set cor_minima 12
  set cor_maxima 18

  set-patch-size tamanho-do-elemento
  resize-world -300 / tamanho-do-elemento 300 / tamanho-do-elemento -300 / tamanho-do-elemento 300 / tamanho-do-elemento

  ask patches [set pcolor white]

  if imagem-amostra = "Chapa 1" [
    import-pcolors "chapa.png"
  ]

  if imagem-amostra = "Chapa 2" [
    import-pcolors "chapa2.png"
  ]

  if imagem-amostra = "Chapa 3" [
    import-pcolors "chapa3.png"
  ]

  ;conversão de cores
  ask patches [
    if (pcolor < 1 and pcolor >= 0) or (pcolor < 11 and pcolor >= 10) or (pcolor < 21 and pcolor >= 20) or (pcolor < 41 and pcolor >= 40) or (pcolor < 51 and pcolor >= 50) or (pcolor < 61 and pcolor >= 60) or (pcolor < 61 and pcolor >= 60)or (pcolor < 71 and pcolor >= 70)or (pcolor < 81 and pcolor >= 80)or (pcolor < 91 and pcolor >= 90)  or (pcolor < 101 and pcolor >= 100) [ set pcolor 0 ];preto
    if pcolor >= 1 and pcolor < 10 [ set pcolor 9.9 ] ;branco
    if (pcolor >= 11 and pcolor < 19) or (pcolor >= 21 and pcolor < 29) or (pcolor >= 41 and pcolor < 49) [ set pcolor 14.9 ] ;quente
    if (pcolor >= 71 and pcolor < 79) or (pcolor >= 81 and pcolor < 89) or (pcolor >= 91 and pcolor < 99) or (pcolor >= 101 and pcolor < 109) [ set pcolor 95.1 ];frio
  ]


  criar-chapa

  ask turtles [
    set temperatura temperatura-inicial
  ]

  aplica-temperatura-nas-fontes

  ask pedacosdechapa [
    colorir
  ]

end

to go

  aplica-temperatura-nas-fontes

  if mouse-down? [
    ask pedacosdechapa with [round xcor = round mouse-xcor and round ycor = round mouse-ycor] [
      set temperatura temperatura-fonte-quente
      ask pedacosdechapa-on neighbors4 [
        set temperatura temperatura-fonte-quente
      ]
    ]
  ]

  calcula-temperatura

  ;if abs (temperatura-media - temperatura-media-anterior) <= 0.00001 [stop]
  set temperatura-media-anterior temperatura-media


  tick
  wait 0.01
end

to aplica-temperatura-nas-fontes
  ifelse fonte-quente-ligada = true [
    ask pontos-quentes [
      set temperatura temperatura-fonte-quente
    ]
  ] [
    ask pontos-quentes [
      if any? turtles-on neighbors4 [

      ;set heading random 360 ; futuramente o heading mostrará o fluxo de calor
      set temperatura mean [temperatura] of turtles-on neighbors4

      ]
    ]
  ]

  ifelse fonte-fria-aplicada = true [
    ask pontos-frios [
      set temperatura temperatura-fonte-fria
    ]
  ] [
    ask pontos-frios [
      if any? turtles-on neighbors4 [

      ;set heading random 360 ; futuramente o heading mostrará o fluxo de calor
      set temperatura mean [temperatura] of turtles-on neighbors4

      ]
    ]
  ]

end

to criar-chapa
  ask patches [
    if pcolor = black and (not any? turtles-here) [
      sprout-pedacosdechapa 1 [
        set color black


        if formato-do-elemento = "Círculo" [
          set shape "circle"
          set size 1
        ]

        if formato-do-elemento = "Quadrado" [
          set shape "square"
          set size 1
        ]
      ]
    ]

    if pcolor = 14.9 and (not any? turtles-here) [
      sprout-pontos-quentes 1 [
        set color red


        if formato-do-elemento = "Círculo" [
          set shape "circle"
          set size 1
        ]

        if formato-do-elemento = "Quadrado" [
          set shape "square"
          set size 1
        ]
      ]
    ]

    if pcolor = 95.1 and (not any? turtles-here) [
      sprout-pontos-frios 1 [
        set color blue

        if formato-do-elemento = "Círculo" [
          set shape "circle"
          set size 1
        ]

        if formato-do-elemento = "Quadrado" [
          set shape "square"
          set size 1
        ]
      ]
    ]
  ]
end

to calcula-temperatura

  ask sensores with [nome = "A"] [
    set temperatura mean [temperatura] of turtles-here
    set temperatura-A temperatura
  ]

  ask sensores with [nome = "B"] [
    set temperatura mean [temperatura] of turtles-here
    set temperatura-B temperatura
  ]

  ask sensores with [nome = "C"] [
    set temperatura mean [temperatura] of turtles-here
    set temperatura-C temperatura
  ]

  ask sensores with [nome = "D"] [
    set temperatura mean [temperatura] of turtles-here
    set temperatura-D temperatura
  ]

  ask sensores with [nome = "E"] [
    set temperatura mean [temperatura] of turtles-here
    set temperatura-E temperatura
  ]

  ask pedacosdechapa [
    if any? turtles-on neighbors4 and pcolor != red and pcolor != blue[

      ;set heading random 360 ; futuramente o heading mostrará o fluxo de calor
      set temperatura mean [temperatura] of turtles-on neighbors4



      colorir
    ]

  ]


  set temperatura-maxima max [temperatura] of pedacosdechapa
  set temperatura-minima min [temperatura] of pedacosdechapa

  set temperatura-media mean [temperatura] of pedacosdechapa

end

to inserir-sensores
  let coordenada-minima-x min [xcor] of pedacosdechapa
  let coordenada-maxima-x max [xcor] of pedacosdechapa
  let coordenada-minima-y min [ycor] of pedacosdechapa
  let coordenada-maxima-y max [ycor] of pedacosdechapa

  create-sensores 1 [
    set xcor round (coordenada-minima-x - (coordenada-minima-x * 2 / 5))
    set ycor round (coordenada-maxima-y - (coordenada-maxima-y * 2 / 5))
    set shape "A"
    set nome "A"
    set size world-width / 30
  ]

  create-sensores 1 [
    set xcor round ((coordenada-maxima-x - (coordenada-maxima-x * 2 / 5)))
    set ycor round (coordenada-maxima-y - (coordenada-maxima-y * 2 / 5))
    set shape "B"
    set nome "B"
    set size world-width / 30
  ]

  create-sensores 1 [
    set xcor 0
    set ycor 0
    set shape "C"
    set nome "C"
    set size world-width / 30
  ]

  create-sensores 1 [
    set xcor round ((coordenada-minima-x - (coordenada-minima-x * 2 / 5)))
    set ycor round (coordenada-minima-y - (coordenada-minima-y * 2 / 5))
    set shape "D"
    set nome "D"
    set size world-width / 30
  ]

  create-sensores 1 [
    set xcor round ((coordenada-maxima-x - (coordenada-maxima-x * 2 / 5)))
    set ycor round (coordenada-minima-y - (coordenada-minima-y * 2 / 5))
    set shape "E"
    set nome "E"
    set size world-width / 30
  ]
end

to colorir

  if temperatura != 0 and cores = "Contínuo (Tons de vermelho)" [
          set color abs ((cor_minima - cor_maxima) * ((temperatura - temperatura-maxima) / (temperatura-minima - temperatura-maxima)) + cor_maxima)
        ]

        if temperatura != 0 and cores = "Contínuo (Branco - Vermelho - Preto)" [
          set color scale-color red temperatura temperatura-minima temperatura-maxima
        ]

        if temperatura != 0 and cores = "10 Cores graduadas (Vermelho - Amarelo - Verde - Azul)" [
          temperatura-graduada1
        ]

        if temperatura != 0 and cores = "10 Cores graduadas (Amarelo - Vermelho - Azul)" [
          temperatura-graduada2
        ]

        if temperatura != 0 and cores = "20 Cores graduadas (Vermelho - Amarelo - Verde - Azul)" [
          temperatura-graduada3
        ]

        if temperatura != 0 and cores = "Tons de cinza" [
          temperatura-tons-de-cinza
        ]

        if temperatura != 0 and cores = "Cores desordenadas (apenas linhas isotérmicas)" [
          set color temperatura
        ]
end

to temperatura-graduada1

  if ( temperatura >= temperatura-minima ) and ( temperatura <= 0.1 * temperatura-maxima ) [
    ;set color scale-color blue temperatura ( 0.2 * temperatura-maxima ) ( 0.4 * temperatura-maxima )
    set color 105
  ]

  if ( temperatura > 0.1 * temperatura-maxima ) and ( temperatura <= 0.2 * temperatura-maxima ) [
    set color 95
  ]

  if ( temperatura > 0.2 * temperatura-maxima ) and ( temperatura <= 0.3 * temperatura-maxima ) [
    set color 85
  ]

  if ( temperatura > 0.3 * temperatura-maxima ) and ( temperatura <= 0.4 * temperatura-maxima ) [
    set color 75
  ]

  if ( temperatura > 0.4 * temperatura-maxima ) and ( temperatura <= 0.5 * temperatura-maxima ) [
    set color 65
  ]

  if ( temperatura > 0.5 * temperatura-maxima ) and ( temperatura <= 0.6 * temperatura-maxima ) [
    set color 55
  ]

  if ( temperatura > 0.6 * temperatura-maxima ) and ( temperatura <= 0.7 * temperatura-maxima ) [
    set color 45
  ]

  if ( temperatura > 0.7 * temperatura-maxima ) and ( temperatura <= 0.8 * temperatura-maxima ) [
    set color 25
  ]

  if ( temperatura > 0.8 * temperatura-maxima ) and ( temperatura <= 0.9 * temperatura-maxima ) [
    set color 14
  ]

  if ( temperatura > 0.9 * temperatura-maxima ) and ( temperatura <= 1.0 * temperatura-maxima ) [
    set color 15
  ]

end

to temperatura-graduada2

  if ( temperatura >= temperatura-minima ) and ( temperatura <= 0.1 * temperatura-maxima ) [
    set color 103
  ]

  if ( temperatura > 0.1 * temperatura-maxima ) and ( temperatura <= 0.2 * temperatura-maxima ) [
    set color 105
  ]

  if ( temperatura > 0.2 * temperatura-maxima ) and ( temperatura <= 0.3 * temperatura-maxima ) [
    set color 95
  ]

  if ( temperatura > 0.3 * temperatura-maxima ) and ( temperatura <= 0.4 * temperatura-maxima ) [
    set color 85
  ]

  if ( temperatura > 0.4 * temperatura-maxima ) and ( temperatura <= 0.5 * temperatura-maxima ) [
    set color 16
  ]

  if ( temperatura > 0.5 * temperatura-maxima ) and ( temperatura <= 0.6 * temperatura-maxima ) [
    set color 15
  ]

  if ( temperatura > 0.6 * temperatura-maxima ) and ( temperatura <= 0.7 * temperatura-maxima ) [
    set color 25
  ]

  if ( temperatura > 0.7 * temperatura-maxima ) and ( temperatura <= 0.8 * temperatura-maxima ) [
    set color 44
  ]

  if ( temperatura > 0.8 * temperatura-maxima ) and ( temperatura <= 0.9 * temperatura-maxima ) [
    set color 47
  ]

  if ( temperatura > 0.9 * temperatura-maxima ) and ( temperatura <= 1.0 * temperatura-maxima ) [
    set color 49
  ]

end

to temperatura-graduada3

  if ( temperatura >= temperatura-minima ) and ( temperatura <= 0.05 * temperatura-maxima ) [
    set color 103
  ]

  if ( temperatura > 0.05 * temperatura-maxima ) and ( temperatura <= 0.1 * temperatura-maxima ) [
    set color 105
  ]

  if ( temperatura > 0.1 * temperatura-maxima ) and ( temperatura <= 0.15 * temperatura-maxima ) [
    set color 93
  ]

  if ( temperatura > 0.15 * temperatura-maxima ) and ( temperatura <= 0.2 * temperatura-maxima ) [
    set color 95
  ]

  if ( temperatura > 0.2 * temperatura-maxima ) and ( temperatura <= 0.25 * temperatura-maxima ) [
    set color 83
  ]

  if ( temperatura > 0.25 * temperatura-maxima ) and ( temperatura <= 0.3 * temperatura-maxima ) [
    set color 85
  ]

  if ( temperatura > 0.3 * temperatura-maxima ) and ( temperatura <= 0.35 * temperatura-maxima ) [
    set color 73
  ]

  if ( temperatura > 0.35 * temperatura-maxima ) and ( temperatura <= 0.4 * temperatura-maxima ) [
    set color 75
  ]

  if ( temperatura > 0.4 * temperatura-maxima ) and ( temperatura <= 0.45 * temperatura-maxima ) [
    set color 63
  ]

  if ( temperatura > 0.45 * temperatura-maxima ) and ( temperatura <= 0.5 * temperatura-maxima ) [
    set color 65
  ]

    if ( temperatura > 0.5 * temperatura-maxima ) and ( temperatura <= 0.55 * temperatura-maxima ) [
    set color 53
  ]

  if ( temperatura > 0.55 * temperatura-maxima ) and ( temperatura <= 0.6 * temperatura-maxima ) [
    set color 55
  ]

  if ( temperatura > 0.6 * temperatura-maxima ) and ( temperatura <= 0.65 * temperatura-maxima ) [
    set color 43
  ]

  if ( temperatura > 0.65 * temperatura-maxima ) and ( temperatura <= 0.7 * temperatura-maxima ) [
    set color 45
  ]

  if ( temperatura > 0.7 * temperatura-maxima ) and ( temperatura <= 0.75 * temperatura-maxima ) [
    set color 47
  ]

  if ( temperatura > 0.75 * temperatura-maxima ) and ( temperatura <= 0.8 * temperatura-maxima ) [
    set color 23
  ]

  if ( temperatura > 0.8 * temperatura-maxima ) and ( temperatura <= 0.85 * temperatura-maxima ) [
    set color 25
  ]

  if ( temperatura > 0.85 * temperatura-maxima ) and ( temperatura <= 0.9 * temperatura-maxima ) [
    set color 13
  ]

  if ( temperatura > 0.9 * temperatura-maxima ) and ( temperatura <= 0.95 * temperatura-maxima ) [
    set color 15
  ]

  if ( temperatura > 0.95 * temperatura-maxima ) and ( temperatura <= 1.0 * temperatura-maxima ) [
    set color 17
  ]

end

to temperatura-tons-de-cinza

  if ( temperatura >= temperatura-minima ) and ( temperatura <= 0.2 * temperatura-maxima ) [
    set color 2
  ]

  if ( temperatura > 0.2 * temperatura-maxima ) and ( temperatura <= 0.4 * temperatura-maxima ) [
    set color 4
  ]

  if ( temperatura > 0.4 * temperatura-maxima ) and ( temperatura <= 0.6 * temperatura-maxima ) [
    set color 6
  ]


  if ( temperatura > 0.6 * temperatura-maxima ) and ( temperatura <= 0.8 * temperatura-maxima ) [
    set color 8
  ]


  if ( temperatura > 0.8 * temperatura-maxima ) and ( temperatura <= 1 * temperatura-maxima ) [
    set color 9.9
  ]


end
@#$#@#$#@
GRAPHICS-WINDOW
367
22
980
636
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-60
60
-60
60
1
1
1
ticks
60.0

BUTTON
40
45
181
95
Configurar
setup
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

BUTTON
40
105
320
153
Iniciar
go
T
1
T
OBSERVER
NIL
I
NIL
NIL
1

MONITOR
40
495
324
540
Temperatura média
temperatura-media
3
1
11

MONITOR
195
440
324
485
Temperatura máxima
temperatura-maxima
3
1
11

MONITOR
40
440
165
485
Temperatura mínima
temperatura-minima
3
1
11

SWITCH
40
169
322
202
fonte-quente-ligada
fonte-quente-ligada
0
1
-1000

SLIDER
40
255
324
288
temperatura-fonte-quente
temperatura-fonte-quente
0
200
100.0
1
1
NIL
HORIZONTAL

CHOOSER
39
383
324
428
cores
cores
"10 Cores graduadas (Vermelho - Amarelo - Verde - Azul)" "10 Cores graduadas (Amarelo - Vermelho - Azul)" "20 Cores graduadas (Vermelho - Amarelo - Verde - Azul)" "Tons de cinza" "Contínuo (Tons de vermelho)" "Contínuo (Branco - Vermelho - Preto)" "Cores desordenadas (apenas linhas isotérmicas)"
0

SLIDER
40
291
325
324
temperatura-inicial
temperatura-inicial
0
200
25.0
1
1
NIL
HORIZONTAL

SWITCH
40
207
322
240
fonte-fria-aplicada
fonte-fria-aplicada
0
1
-1000

MONITOR
39
706
181
751
Número de elementos
count turtles
0
1
11

CHOOSER
39
604
326
649
imagem-amostra
imagem-amostra
"Chapa 1" "Chapa 2" "Chapa 3"
2

CHOOSER
39
654
181
699
formato-do-elemento
formato-do-elemento
"Círculo" "Quadrado"
1

PLOT
1015
25
1435
195
Temperatura média
ticks
Temperatura média
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-media"

SLIDER
39
554
324
587
tamanho-do-elemento
tamanho-do-elemento
1
20
5.0
1
1
px
HORIZONTAL

BUTTON
190
45
320
95
Inserir sensores
inserir-sensores
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

PLOT
1015
205
1215
355
Temperatura em A
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-A"

PLOT
1235
205
1435
355
Temperatura em B
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-B"

PLOT
1015
365
1215
515
Temperatura em C
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-C"

PLOT
1235
365
1435
515
Temperatura D
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-D"

PLOT
1015
525
1215
675
Temperatura E
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot temperatura-E"

MONITOR
1235
525
1292
570
Temp A
temperatura-A
2
1
11

MONITOR
1380
525
1437
570
Temp B
temperatura-B
2
1
11

MONITOR
1310
575
1367
620
Temp C
temperatura-C
2
1
11

MONITOR
1235
630
1292
675
Temp D
temperatura-D
2
1
11

MONITOR
1380
630
1437
675
Temp E
temperatura-E
2
1
11

SLIDER
40
330
325
363
temperatura-fonte-fria
temperatura-fonte-fria
-10
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

a
false
0
Rectangle -16777216 true false 45 0 255 300
Rectangle -7500403 true true 90 195 90 270
Rectangle -1 true false 60 60 105 285
Rectangle -1 true false 105 15 195 60
Rectangle -1 true false 195 60 240 285
Rectangle -1 true false 90 150 210 195
Rectangle -1 true false 75 30 105 60
Rectangle -1 true false 195 30 225 60

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

b
false
0
Rectangle -16777216 true false 45 0 255 300
Rectangle -1 true false 75 15 120 285
Rectangle -1 true false 120 15 180 60
Rectangle -1 true false 120 240 180 285
Rectangle -1 true false 180 195 210 255
Rectangle -1 true false 180 45 210 105
Rectangle -1 true false 165 120 195 165
Rectangle -1 true false 120 135 165 165
Rectangle -1 true false 180 105 210 120
Rectangle -1 true false 165 165 195 180
Rectangle -1 true false 180 180 210 195
Rectangle -1 true false 165 60 180 75
Rectangle -1 true false 165 225 180 240

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

c
false
0
Rectangle -16777216 true false 60 0 240 300
Rectangle -1 true false 120 15 225 60
Rectangle -1 true false 75 45 120 255
Rectangle -1 true false 120 240 225 285

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

d
false
0
Rectangle -16777216 true false 45 0 255 300
Rectangle -1 true false 75 15 120 285
Rectangle -1 true false 120 15 180 60
Rectangle -1 true false 120 240 180 285
Rectangle -1 true false 180 195 210 255
Rectangle -1 true false 180 45 210 105
Rectangle -1 true false 180 120 210 165
Rectangle -1 true false 180 105 210 120
Rectangle -1 true false 180 165 210 180
Rectangle -1 true false 180 180 210 195
Rectangle -1 true false 165 60 180 75
Rectangle -1 true false 165 225 180 240

dot
false
0
Circle -7500403 true true 90 90 120

e
false
0
Rectangle -16777216 true false 45 0 255 300
Rectangle -1 true false 75 15 120 285
Rectangle -1 true false 120 15 210 60
Rectangle -1 true false 120 240 210 285
Rectangle -1 true false 120 135 165 165

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 0 0 300 300

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
