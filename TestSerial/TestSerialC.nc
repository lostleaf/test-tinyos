#include "Timer.h"
#include "TestSerial.h"

module TestSerialC {
    uses {
        interface SplitControl as Control;
        interface Leds;
        interface Boot;
        interface Receive;
        interface AMSend;
        interface Timer<TMilli> as MilliTimer;
        interface Packet;
        interface Read<uint16_t>;
        // interface Light<uint16_t>;
    }
}
implementation {

    message_t packet;

    bool locked = FALSE;
    uint16_t counter = 0;

    event void Boot.booted() {
        call Control.start();
    }

    event void MilliTimer.fired() {
        call Read.read();
        // call Light.read();
    }
    
    event void Read.readDone(error_t result, uint16_t data) 
    {
        if (result == SUCCESS){
            counter = data;
            if (locked) {
                return;
            }
            else {
                test_serial_msg_t* rcm = (test_serial_msg_t*)call Packet.getPayload(&packet, sizeof(test_serial_msg_t));
                if (rcm == NULL) {return;}
                if (call Packet.maxPayloadLength() < sizeof(test_serial_msg_t)) {
                    return;
                }

                rcm->counter = counter;
                if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
                    locked = TRUE;
                }
            }
            if (data & 0x0004)
                call Leds.led2On();
            else
                call Leds.led2Off();
            if (data & 0x0002)
                call Leds.led1On();
            else
                call Leds.led1Off();
            if (data & 0x0001)
                call Leds.led0On();
            else
                call Leds.led0Off();
        }
    }

    event message_t* Receive.receive(message_t* bufPtr, 
            void* payload, uint8_t len) {
        if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
        else {
            test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
            if (rcm->counter & 0x1) {
                call Leds.led0On();
            }
            else {
                call Leds.led0Off();
            }
            if (rcm->counter & 0x2) {
                call Leds.led1On();
            }
            else {
                call Leds.led1Off();
            }
            if (rcm->counter & 0x4) {
                call Leds.led2On();
            }
            else {
                call Leds.led2Off();
            }
            return bufPtr;
        }
    }

    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
        if (&packet == bufPtr) {
            locked = FALSE;
        }
    }

    event void Control.startDone(error_t err) {
        if (err == SUCCESS) {
            call MilliTimer.startPeriodic(1000);
        }
    }
    event void Control.stopDone(error_t err) {}
}




