#include <Arduino.h>
const int PI_COMM_PIN = 2; // Also LED_BUILTIN

struct Button {
  uint8_t PIN;
  uint8_t NUMBER;
};

uint8_t correct_num = 0;
const uint8_t password[] = {1, 9, 3, 2}; // Order doesn't matter, no duplicates.
bool password_hit[] = {false, false, false, false};
uint8_t leds[] = {19, 22, 21, 18};

Button button1 = {26, 1};
Button button2 = {12, 2};
Button button3 = {13, 3};
Button button4 = {4, 4};
Button button5 = {27, 5};
Button button6 = {16, 6};
Button button7 = {17, 7};
Button button8 = {15, 8};
Button button9 = {32, 9};
Button button10 = {33, 10};
Button button11 = {25, 11};
Button button12 = {14, 12};

const int NUM_BUTTONS = 12;
Button buttons[] = {button1, button2, button3, button4,  button5,  button6,
                    button7, button8, button9, button10, button11, button12};
bool pressed[] = {false, false, false, false, false, false,
                  false, false, false, false, false, false};
long long lastSignalChangeMs[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void pi_begin_sequence(bool begin) {
  if (begin) {
    digitalWrite(PI_COMM_PIN, LOW);
  } else {
    digitalWrite(PI_COMM_PIN, HIGH);
  }
}

void reset() {
  pi_begin_sequence(false);
  for (int i = 0; i < 4; i++) {
    digitalWrite(leds[i], LOW);
    password_hit[i] = false;
  }
  correct_num = 0;
}

void leds_lose() {
  for (int i = 0; i < 10; i++) {
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

void leds_win() {
  digitalWrite(leds[0], LOW);
  digitalWrite(leds[1], LOW);
  digitalWrite(leds[2], LOW);
  digitalWrite(leds[3], LOW);
  for (int i = 0; i < 3; i++) {
    digitalWrite(leds[0], HIGH);
    delay(100);
    digitalWrite(leds[1], HIGH);
    delay(100);
    digitalWrite(leds[2], HIGH);
    delay(100);
    digitalWrite(leds[3], HIGH);
    delay(100);
    digitalWrite(leds[0], LOW);
    digitalWrite(leds[1], LOW);
    digitalWrite(leds[2], LOW);
    digitalWrite(leds[3], LOW);
    delay(100);
  }
  delay(150);
  for (int i = 0; i < 3; i++) {
    digitalWrite(leds[0], HIGH);
    digitalWrite(leds[1], HIGH);
    digitalWrite(leds[2], HIGH);
    digitalWrite(leds[3], HIGH);
    delay(250);
    digitalWrite(leds[0], LOW);
    digitalWrite(leds[1], LOW);
    digitalWrite(leds[2], LOW);
    digitalWrite(leds[3], LOW);
    delay(250);
  }
}

bool next_button_correct(Button button) {
  for (int i = 0; i < 4; i++) {
    if (password[i] == button.NUMBER && !password_hit[i]) {
      password_hit[i] = true;
      return true;
    }
  }
  return false;
}

void check_code(Button button) {
  if (next_button_correct(button)) {
    digitalWrite(leds[correct_num], HIGH);
    correct_num++;
  } else {
    leds_lose();
    reset();
  }
  if (correct_num == 4) {
    Serial.println("Correct!");
    pi_begin_sequence(true);
    leds_win();
    reset();
  }
}

void setup() {
  // LEDS
  pinMode(PI_COMM_PIN, OUTPUT);
  pi_begin_sequence(false);
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

void loop() {
  for (int i = 0; i < NUM_BUTTONS; i++) {
    bool state = digitalRead(buttons[i].PIN);
    bool changed = state != pressed[i];
    bool ignore = millis() - lastSignalChangeMs[i] < 100;
    if (!ignore && changed) {
      pressed[i] = state;
      lastSignalChangeMs[i] = millis();
      if (state == LOW) {
        Serial.print("Pressed num:");
        Serial.print(buttons[i].NUMBER);
        Serial.print(", pin: ");
        Serial.println(buttons[i].PIN);

        check_code(buttons[i]);
      }
    }
  }
}
