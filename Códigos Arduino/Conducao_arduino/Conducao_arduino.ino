// Biblioteca da interface da tela LCD http://blog.mklec.com/how-to-use-iici2c-serial-interface-module-for-1602-lcd-display
// Com base na biblioteca de: https://bitbucket.org/fmalpartida/new-liquidcrystal/downloads GNU General Public License, version 3 (GPL-3.0)
/*
   Conexões:
        SCL = A5
        SDA = A4
        VCC = 5V
        GND = GND
*/

// LCD
#include <Wire.h>
#include <LCD.h>
#include <LiquidCrystal_I2C.h>

// Biblioteca estatística http://playground.arduino.cc/Main/Statistics
#include "Statistic.h"

// Criação de variáveis das bibliotecas
LiquidCrystal_I2C  lcd(0x27, 2, 1, 0, 4, 5, 6, 7); // 0x27 is the I2C bus address for an unmodified module
Statistic dadosMensuradosA;
Statistic dadosMensuradosB;
Statistic dadosMensuradosC;
Statistic dadosMensuradosD;
Statistic dadosMensuradosE;
Statistic dadosMensuradosFria;
Statistic dadosMensuradosQuente;
Statistic dadosMensuradosGeral;


// Termopares
#include <SPI.h>

//Inicialização de variáveis
double tempA, tempB, tempC, tempD, tempE, tempFria, tempQuente;
int identificadorDaMedida = 1;
int contadorNumMedidas = 0;
int intervaloMedidas;

void setup()
{
  // Serial
  Serial.begin(115200);

  Serial.println("  |   Experimento de Condução de Calor - TICT de Julio Patron Witwytzkyj   |");
  Serial.println("  |     Curso de Engenharia Mecânica - Universidade do Vale do Itajaí      |\n");

  Serial.println("Inicializando interface SPI e MAX6675... ");

  // Espera pela conexão serial
  while (! Serial) {
    delay(1);
  }

  Serial.println("Inicializando led indicador de medida... ");
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("Inicializando biblioteca estatística... \n");
  dadosMensuradosA.clear(); // Limpa valores estatísticos

  // Termopares
  SPI.begin();
  pinMode(7, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(8, OUTPUT);
  digitalWrite(7, HIGH);
  digitalWrite(6, HIGH);
  digitalWrite(5, HIGH);
  digitalWrite(4, HIGH);
  digitalWrite(3, HIGH);
  digitalWrite(2, HIGH);
  digitalWrite(8, HIGH);

  // LCD
  lcd.setBacklightPin(3, POSITIVE);
  lcd.setBacklight(HIGH); // NOTE: You can turn the backlight off by setting it to LOW instead of HIGH
  lcd.begin(16, 2);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Aguardando");
  lcd.setCursor(0, 1);
  lcd.print("Serial");

  recebeNumMedidas();
  recebeIntervaloMedidas();

  Serial.println("\nNumero da medida  |    A    |    B    |    C    |    D    |    E    |  Fria   | Quente");

}

void loop()
{
  tempA = readCelsius(8);
  dadosMensuradosA.add(tempA); // Adiciona medida aos dados estatísticos do ponto A
  dadosMensuradosGeral.add(tempA); // Adiciona medida aos dados estatísticos gerais

  tempB = readCelsius(2);
  dadosMensuradosB.add(tempB); // Adiciona medida aos dados estatísticos do ponto B
  dadosMensuradosGeral.add(tempB); // Adiciona medida aos dados estatísticos gerais

  tempC = readCelsius(3);
  dadosMensuradosC.add(tempC); // Adiciona medida aos dados estatísticos do ponto C
  dadosMensuradosGeral.add(tempC); // Adiciona medida aos dados estatísticos gerais

  tempD = readCelsius(4);
  dadosMensuradosD.add(tempD); // Adiciona medida aos dados estatísticos
  dadosMensuradosGeral.add(tempD); // Adiciona medida aos dados estatísticos gerais

  tempE = readCelsius(5);
  dadosMensuradosE.add(tempE); // Adiciona medida aos dados estatísticos
  dadosMensuradosGeral.add(tempE); // Adiciona medida aos dados estatísticos gerais

  tempQuente = readCelsius(6);
  dadosMensuradosQuente.add(tempQuente); // Adiciona medida aos dados estatísticos
  dadosMensuradosGeral.add(tempQuente); // Adiciona medida aos dados estatísticos gerais

  tempFria = readCelsius(7);
  dadosMensuradosFria.add(tempFria); // Adiciona medida aos dados estatísticos
  dadosMensuradosGeral.add(tempFria); // Adiciona medida aos dados estatísticos gerais

  // Serial
  Serial.print(String("         ") + identificadorDaMedida + String("        |  "));
  Serial.print(tempA + String("  |  "));
  Serial.print(tempB + String("  |  "));
  Serial.print(tempC + String("  |  "));
  Serial.print(tempD + String("  |  "));
  Serial.print(tempE + String("  |  "));
  Serial.print(tempQuente + String("  |  "));
  Serial.println(tempFria) + String("\n");

  // LCD
  lcd.clear();
  lcd.setCursor(2, 0);
  lcd.print("Medida " + identificadorDaMedida);
  lcd.setCursor(0, 1);
  lcd.print("A: " + String(tempA));
  delay(intervaloMedidas / 4);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("B: " + String(tempB));
  lcd.setCursor(0, 1);
  lcd.print("C: " + String(tempC));
  delay(intervaloMedidas / 4);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("D: " + String(tempD));
  lcd.setCursor(0, 1);
  lcd.print("E: " + String(tempE));
  delay(intervaloMedidas / 4);

  lcd.clear();
  // fonte quente
  lcd.setCursor(2, 0);
  lcd.print("Quente: " + String(tempQuente));
  // Fonte fria
  lcd.setCursor(4, 1);
  lcd.print("Fria: " + String(tempFria));
  delay(intervaloMedidas / 4);

  identificadorDaMedida++;

  if (dadosMensuradosA.count() >= contadorNumMedidas) {
    estatistica();
    recebeNumMedidas();
    recebeIntervaloMedidas();
  }
}


// Aguarda até que o valor do número de medidas desejado seja enviado pela porta serial.
void recebeNumMedidas() {
  Serial.print("Envie o número de medidas desejado... ");
  lcd.clear();
  contadorNumMedidas = 0;
  while (contadorNumMedidas == 0) { // Espera até que um valor válido de medidas seja recebido
    while (!Serial.available()) {
      
      // fonte quente
      lcd.setCursor(1, 0);
      lcd.print("Quente: " + String(readCelsius(6)));
      // Fonte fria
      lcd.setCursor(3, 1);
      lcd.print("Fria: " + String(readCelsius(7)));
      delay(100);
    } // Espera pelo comando da porta serial
    contadorNumMedidas = Serial.parseInt(); // Recebe o número de medidas
  }

  Serial.println(contadorNumMedidas);
}

void recebeIntervaloMedidas() {
  Serial.print("Envie o intervalo entre medidas (ms)... ");

  intervaloMedidas = 0;
  while (intervaloMedidas == 0) { // Espera até que um valor válido intervalo seja recebido
    while (!Serial.available()) {} // Espera pelo comando da porta serial
    intervaloMedidas = Serial.parseInt(); // Recebe o intervalo
  }

  Serial.println(intervaloMedidas);
}

// Função para leitura de termopares. Fonte: https://arduino.stackexchange.com/questions/37193/multiple-3-wire-spi-sensor-interfacing-with-arduino
double readCelsius(uint8_t cs) {
  uint16_t v;

  digitalWrite(cs, LOW);
  delay(20);
  v = SPI.transfer(0x00);
  v <<= 8;
  v |= SPI.transfer(0x00);
  digitalWrite(cs, HIGH);
  delay(20);

  if (v & 0x4) {
    // Termopar não acoplado
    return NAN;
  }

  v >>= 3;

  return v * 0.25;
}

void estatistica() {
  {
    // refazer string

    // A
    Serial.print("\nResultados: \n");
    Serial.print(String("A   |   " + String(dadosMensuradosA.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosA.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosA.count() + "\n");       // Num medidas
    dadosMensuradosA.clear();

    // B
    Serial.print(String("B   |   " + String(dadosMensuradosB.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosB.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosB.count() + "\n");       // Num medidas
    dadosMensuradosB.clear();

    // C
    Serial.print(String("C   |   " + String(dadosMensuradosC.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosC.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosC.count() + "\n");       // Num medidas
    dadosMensuradosC.clear();

    // D
    Serial.print(String("D   |   " + String(dadosMensuradosD.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosD.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosD.count() + "\n");       // Num medidas
    dadosMensuradosD.clear();

    // E
    Serial.print(String("E   |   " + String(dadosMensuradosE.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosE.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosE.count() + "\n");       // Num medidas
    dadosMensuradosE.clear();

    // Fria
    Serial.print(String("Fria   |   " + String(dadosMensuradosFria.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosFria.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosFria.count() + "\n");       // Num medidas
    dadosMensuradosFria.clear();

    // Quente
    Serial.print(String("Quente   |   " + String(dadosMensuradosQuente.average(), 2) + "      |      "));    // Média, 2 casas decimais
    Serial.print((dadosMensuradosQuente.pop_stdev(), 2) + "     |        "); // Desvio padrão, 2 casas decimais
    Serial.println(dadosMensuradosQuente.count() + "\n\n");       // Num medidas
    dadosMensuradosQuente.clear();

    delay(3000);
    recebeNumMedidas();

  }

}
