#include "Adafruit_VL53L0X.h" // Biblioteca do sensor de distância https://github.com/adafruit/Adafruit_VL53L0X
#include "Statistic.h" // Biblioteca estatística http://playground.arduino.cc/Main/Statistics

// Criação de variáveis das bibliotecas
Statistic dadosMensurados;
Adafruit_VL53L0X lox = Adafruit_VL53L0X();

// Inicialização de variáveis
int identificadorDaMedida = 1;
int contadorNumMedidas = 0;

void setup() {
  Serial.begin(115200);

  Serial.println("  |       Experimento de Flexão - TICT de Julio Patron Witwytzkyj       |");
  Serial.println("  |    Curso de Engenharia Mecânica - Universidade do Vale do Itajaí    |\n"); 

  Serial.println("Inicializando sensor de distância VL53L0X..."); 
  
  // Espera pela conexão serial
  while (! Serial) {
    delay(1);
  }
  
  if (!lox.begin()) {
    Serial.println(F("Falha ao inicializar o VL53L0X"));
    while(1);
  }

  Serial.println("Inicializando led indicador de medida... ");
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("Inicializando biblioteca estatística... \n");
  dadosMensurados.clear(); // Limpa valores estatísticos

  Serial.print("Envie o número de medidas desejado... ");
  recebeNumMedidas();
  Serial.println(contadorNumMedidas);

  Serial.println("\nEstrutura de dados:");
  Serial.println("Média (mm) | Desvio Padrão | Numero de medidas | Identificador");
}


void loop() {
  VL53L0X_RangingMeasurementData_t measure;

  lox.rangingTest(&measure, false); // pass in 'true' to get debug data printout!

  if (measure.RangeStatus != 4) {  // Merifica se a amostra está posicionada

      digitalWrite(LED_BUILTIN, HIGH); // Indica medida
      dadosMensurados.add(measure.RangeMilliMeter); // Adiciona medida aos dados estatísticos
      delay(200);
      digitalWrite(LED_BUILTIN, LOW);

  } else {
    Serial.println(" fora de alcance ");
    digitalWrite(LED_BUILTIN, HIGH);
    delay(2000);
    digitalWrite(LED_BUILTIN, LOW);
  }


  if (dadosMensurados.count() >= contadorNumMedidas) {

    Serial.print(dadosMensurados.average(), 2);     Serial.print("      |      "); // Média, 2 casas decimais
  
    Serial.print(dadosMensurados.pop_stdev(), 2);   Serial.print("     |        "); // Desvio padrão, 2 casas decimais

    Serial.print(dadosMensurados.count());          Serial.print("         |       "); // Num medidas

    Serial.print(identificadorDaMedida);            Serial.println();
    identificadorDaMedida++;
    
    dadosMensurados.clear();

    recebeNumMedidas();

  }
    
  delay(200);
}

// Aguarda até que o valor do número de medidas desejado seja enviado pela porta serial.
void recebeNumMedidas() {
  contadorNumMedidas = 0;
  while(contadorNumMedidas == 0) { // Espera até que um valor válido de medidas seja recebido
      while(!Serial.available()){} // Espera pelo comando da porta serial
      contadorNumMedidas = Serial.parseInt(); // Recebe o número de medidas
  }
}
