#include "TestSerial.h"
#include <Timer.h>

configuration TestSerialAppC {}
implementation {
    components TestSerialC as App, LedsC, MainC;
    components SerialActiveMessageC as AM;
    components new TimerMilliC();
    // components new DemoSensorC() as Sensor;
    // components new SensirionSht11C() as Sensor;
    components new HamamatsuS1087ParC() as Sensor;

    App.Boot -> MainC.Boot;
    App.Control -> AM;
    App.Receive -> AM.Receive[AM_TEST_SERIAL_MSG];
    App.AMSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
    App.Leds -> LedsC;
    App.MilliTimer -> TimerMilliC;
    App.Packet -> AM;
    // App.Read -> Sensor.Temperature;
    App.Read -> Sensor;
}
