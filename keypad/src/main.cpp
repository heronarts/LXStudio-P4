#include <Arduino.h>
const int PI_COMM_PIN = 2; // Also LED_BUILTIN

struct Button {
  uint8_t PIN;
  uint8_t NUMBER;
};

uint8_t correct_num = 0;
const uint8_t password[] = {1, 2, 3, 4}; // NO duplicates, I think
uint8_t leds[] = {18, 19, 21, 22};
Button button1 = {15, 1};
Button button2 = {4, 2};
Button button3 = {16, 3};
Button button4 = {17, 4};
Button button5 = {32, 5};
Button button6 = {33, 6};
Button button7 = {25, 7};
Button button8 = {26, 8};
Button button9 = {27, 9};
Button button10 = {14, 10};
Button button11 = {12, 11};
Button button12 = {13, 12};
const int NUM_BUTTONS = 12;
Button buttons[] = {button1, button2, button3, button4,  button5,  button6,
                    button7, button8, button9, button10, button11, button12};
bool pressed[] = {false, false, false, false, false, false,
                  false, false, false, false, false, false};
long long lastSignalChangeMs[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void reset() {
  // tmp
  // digitalWrite(PI_COMM_PIN, LOW);
  // digitalWrite(leds[0], LOW);
  // digitalWrite(leds[1], LOW);
  // digitalWrite(leds[2], LOW);
  // digitalWrite(leds[3], LOW);
  correct_num = 0;
}

void flash_leds() {
  return; // tmp
  for (int i = 0; i < 4; i++) {
    digitalWrite(leds[0], HIGH);
    digitalWrite(leds[1], HIGH);
    digitalWrite(leds[2], HIGH);
    digitalWrite(leds[3], HIGH);
    delay(100);
    digitalWrite(leds[0], LOW);
    digitalWrite(leds[1], LOW);
    digitalWrite(leds[2], LOW);
    digitalWrite(leds[3], LOW);
    delay(100);
  }
}

void check_code(Button button) {
  if (button.NUMBER == password[correct_num]) {
    // digitalWrite(leds[correct_num], HIGH); // tmp
    correct_num++;
  } else {
    reset();
    flash_leds();
  }
  if (correct_num == 4) {
    digitalWrite(PI_COMM_PIN, HIGH);
    Serial.println("Correct!");
  }
}

void setup() {
  // LEDS
  pinMode(PI_COMM_PIN, OUTPUT);
  pinMode(leds[0], OUTPUT);
  pinMode(leds[1], OUTPUT);
  pinMode(leds[2], OUTPUT);
  pinMode(leds[3], OUTPUT);

  // BUTTONS
  pinMode(button1.PIN, INPUT_PULLUP);
  pinMode(button2.PIN, INPUT_PULLUP);
  pinMode(button3.PIN, INPUT_PULLUP);
  pinMode(button4.PIN, INPUT_PULLUP);
  pinMode(button5.PIN, INPUT_PULLUP);
  pinMode(button6.PIN, INPUT_PULLUP);
  pinMode(button7.PIN, INPUT_PULLUP);
  pinMode(button8.PIN, INPUT_PULLUP);
  pinMode(button9.PIN, INPUT_PULLUP);
  pinMode(button10.PIN, INPUT_PULLUP);
  pinMode(button11.PIN, INPUT_PULLUP);
  pinMode(button12.PIN, INPUT_PULLUP);

  Serial.begin(115200);
  Serial.println("Hello");
}

void leds_on() {
  digitalWrite(leds[0], HIGH);
  digitalWrite(leds[1], HIGH);
  digitalWrite(leds[2], HIGH);
  digitalWrite(leds[3], HIGH);
}

void leds_off() {
  digitalWrite(leds[0], LOW);
  digitalWrite(leds[1], LOW);
  digitalWrite(leds[2], LOW);
  digitalWrite(leds[3], LOW);
}

void loop() {
  for (int i = 0; i < NUM_BUTTONS; i++) {
    bool state = digitalRead(buttons[i].PIN);
    bool changed = state != pressed[i];
    bool ignore = millis() - lastSignalChangeMs[i] < 100;
    if (!ignore && changed) {
      pressed[i] = state;
      lastSignalChangeMs[i] = millis();
      if (state == LOW) {
        Serial.print("Pressed: ");
        Serial.println(buttons[i].NUMBER);
        check_code(buttons[i]);
        digitalWrite(PI_COMM_PIN, HIGH); // tmp
        leds_on();
      } else {
        leds_off();
      }
    }
  }
}
