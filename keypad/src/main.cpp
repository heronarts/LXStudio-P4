#include <Arduino.h>
#define LED_BUILTIN 2

struct Button {
  uint8_t PIN;
  uint8_t NUMBER;
};

uint8_t correct = 0;
const uint8_t code[] = {1, 2, 3, 4}; // NO duplicates, I think
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

volatile uint8_t last_pressed = 0;
void reset() {
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(leds[0], LOW);
  digitalWrite(leds[1], LOW);
  digitalWrite(leds[2], LOW);
  digitalWrite(leds[3], LOW);
  correct = 0;
}

//void ARDUINO_ISR_ATTR isr(void *arg) {
void isr(void *arg) {
  Button *s = static_cast<Button *>(arg);
  last_pressed = s->PIN;
  if (s->NUMBER == code[correct]) {
    digitalWrite(leds[correct], HIGH);
    correct++;
  } else {
    reset();
    // TODO: FLASHING
  }
  if (correct == 4) {
    digitalWrite(LED_BUILTIN, HIGH);
    // TODO: MAKE THE SHIT HAPPEN
  }
}

void setup() {
  // LEDS
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(leds[0], OUTPUT);
  pinMode(leds[1], OUTPUT);
  pinMode(leds[2], OUTPUT);
  pinMode(leds[3], OUTPUT);

  // BUTTONS
  pinMode(button1.PIN, INPUT_PULLUP);
  attachInterruptArg(button1.PIN, isr, &button1, FALLING);
  pinMode(button2.PIN, INPUT_PULLUP);
  attachInterruptArg(button2.PIN, isr, &button2, FALLING);
  pinMode(button3.PIN, INPUT_PULLUP);
  attachInterruptArg(button3.PIN, isr, &button3, FALLING);
  pinMode(button4.PIN, INPUT_PULLUP);
  attachInterruptArg(button4.PIN, isr, &button4, FALLING);
  pinMode(button5.PIN, INPUT_PULLUP);
  attachInterruptArg(button5.PIN, isr, &button5, FALLING);
  pinMode(button6.PIN, INPUT_PULLUP);
  attachInterruptArg(button6.PIN, isr, &button6, FALLING);
  pinMode(button7.PIN, INPUT_PULLUP);
  attachInterruptArg(button7.PIN, isr, &button7, FALLING);
  pinMode(button8.PIN, INPUT_PULLUP);
  attachInterruptArg(button8.PIN, isr, &button8, FALLING);
  pinMode(button9.PIN, INPUT_PULLUP);
  attachInterruptArg(button9.PIN, isr, &button9, FALLING);
  pinMode(button10.PIN, INPUT_PULLUP);
  attachInterruptArg(button10.PIN, isr, &button10, FALLING);
  pinMode(button11.PIN, INPUT_PULLUP);
  attachInterruptArg(button11.PIN, isr, &button11, FALLING);
  pinMode(button12.PIN, INPUT_PULLUP);
  attachInterruptArg(button12.PIN, isr, &button12, FALLING);

  Serial.begin(115200);
  Serial.println("Hello");
}

void loop() {
  // if (button1.pressed) {
  //     Serial.printf("Button 1 has been pressed %u times\n",
  //     button1.numberKeyPresses); button1.pressed = false;
  // }
  digitalWrite(leds[0], LOW);
  digitalWrite(leds[1], LOW);
  digitalWrite(leds[2], LOW);
  digitalWrite(leds[3], LOW);
  delay(500);
  digitalWrite(leds[0], HIGH);
  digitalWrite(leds[1], HIGH);
  digitalWrite(leds[2], HIGH);
  digitalWrite(leds[3], HIGH);
  delay(500);
  if (last_pressed != 0) {
    Serial.print("Last: ");
    Serial.println(last_pressed);
    last_pressed = 0;
  }
}
