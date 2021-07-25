//
//  MSP.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/25/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import Foundation

enum MSP_Request_Replies: Int {
    case MSP_API_VERSION            = 1
    case MSP_FC_VARIANT             = 2
    case MSP_FC_VERSION             = 3
    case MSP_BOARD_INFO             = 4
    case MSP_BUILD_INFO             = 5
    case MSP_CALIBRATION_DATA       = 14
    case MSP_FEATURE                = 36
    case MSP_BOARD_ALIGNMENT       = 38
    case MSP_CURRENT_METER_CONFIG  = 40
    case MSP_RX_CONFIG             = 44
    case MSP_SONAR_ALTITUDE        = 58
    case MSP_ARMING_CONFIG         = 61
    case MSP_RX_MAP                = 64 // get channel map (also returns number of channels total)
    case MSP_LOOP_TIME             = 73 // FC cycle time i.e looptime parameter
    case MSP_STATUS               = 101
    case MSP_RAW_IMU              = 102
    case MSP_SERVO                = 103
    case MSP_MOTOR                = 104
    case MSP_RC                   = 105
    case MSP_RAW_GPS              = 106
    case MSP_COMP_GPS             = 107 // distance home, direction home
    case MSP_ATTITUDE             = 108
    case MSP_ALTITUDE             = 109
    case MSP_ANALOG               = 110
    case MSP_RC_TUNING            = 111 // rc rate, rc expo, rollpitch rate, yaw rate, dyn throttle PID
    case MSP_PID                  = 112 // P I D coeff
    case MSP_MISC                 = 114
    case MSP_SERVO_CONFIGURATIONS = 120
    case MSP_NAV_STATUS           = 121 // navigation status
    case MSP_SENSOR_ALIGNMENT     = 126 // orientation of acc,gyro,mag
    case MSP_STATUS_EX            = 150
    case MSP_SENSOR_STATUS        = 151
    case MSP_BOXIDS               = 119
    case MSP_UID                  = 160 // Unique device ID
    case MSP_GPSSVINFO            = 164 // get Signal Strength (only U-Blox)
    case MSP_GPSSTATISTICS        = 166 // get GPS debugging data
    case MSP_SET_PID              = 202 // set P I D coeff
}
enum MSP_Commands: Int {
    case MSP_SET_HEAD             = 211 // define a new heading hold direction
    case MSP_SET_RAW_RC           = 200 // 8 rc chan
    case MSP_SET_RAW_GPS          = 201 // fix, numsat, lat, lon, alt, speed
    case MSP_SET_WP               = 209 // sets a given WP (WP#, lat, lon, alt, flags)
}

enum MSP_Get_Active_Modes: Int {
    // bits of getActiveModes() return value
    case MSP_MODE_ARM          = 0
    case MSP_MODE_ANGLE        = 1
    case MSP_MODE_HORIZON      = 2
    case MSP_MODE_NAVALTHOLD   = 3 /* cleanflight BARO */
    case MSP_MODE_MAG          = 4
    case MSP_MODE_HEADFREE     = 5
    case MSP_MODE_HEADADJ      = 6
    case MSP_MODE_CAMSTAB      = 7
    case MSP_MODE_NAVRTH       = 8 /* cleanflight GPSHOME */
    case MSP_MODE_NAVPOSHOLD   = 9 /* cleanflight GPSHOLD */
    case MSP_MODE_PASSTHRU    = 10
    case MSP_MODE_BEEPERON    = 11
    case MSP_MODE_LEDLOW      = 12
    case MSP_MODE_LLIGHTS     = 13
    case MSP_MODE_OSD         = 14
    case MSP_MODE_TELEMETRY   = 15
    case MSP_MODE_GTUNE       = 16
    case MSP_MODE_SONAR       = 17
    case MSP_MODE_BLACKBOX    = 18
    case MSP_MODE_FAILSAFE    = 19
    case MSP_MODE_NAVWP       = 20 /* cleanflight AIRMODE */
    case MSP_MODE_AIRMODE     = 21 /* cleanflight DISABLE3DSWITCH */
    case MSP_MODE_HOMERESET   = 22 /* cleanflight FPVANGLEMIX */
    case MSP_MODE_GCSNAV      = 23 /* cleanflight BLACKBOXERASE */
    case MSP_MODE_HEADINGLOCK = 24
    case MSP_MODE_SURFACE     = 25
    case MSP_MODE_FLAPERON    = 26
    case MSP_MODE_TURNASSIST  = 27
    case MSP_MODE_NAVLAUNCH   = 28
    case MSP_MODE_AUTOTRIM    = 29
}

// MSP_API_VERSION reply
struct msp_api_version_t {
    var protocolVersion: UInt8
    var APIMajor: UInt8
    var APIMinor: UInt8
}


//// MSP_FC_VARIANT reply
//struct msp_fc_variant_t {
//  char flightControlIdentifier[4];
//}
//
//
//// MSP_FC_VERSION reply
//struct msp_fc_version_t {
//  uint8_t versionMajor;
//  uint8_t versionMinor;
//  uint8_t versionPatchLevel;
//} __attribute__ ((packed));


//// MSP_BOARD_INFO reply
//struct msp_board_info_t {
//  char     boardIdentifier[4];
//  uint16_t hardwareRevision;
//} __attribute__ ((packed));
//
//
//// MSP_BUILD_INFO reply
//struct msp_build_info_t {
//  char buildDate[11];
//  char buildTime[8];
//  char shortGitRevision[7];
//} __attribute__ ((packed));
//
//
//// MSP_RAW_IMU reply
//struct msp_raw_imu_t {
//  int16_t acc[3];  // x, y, z
//  int16_t gyro[3]; // x, y, z
//  int16_t mag[3];  // x, y, z
//} __attribute__ ((packed));
//
//
//// flags for msp_status_ex_t.sensor and msp_status_t.sensor
//#define MSP_STATUS_SENSOR_ACC    1
//#define MSP_STATUS_SENSOR_BARO   2
//#define MSP_STATUS_SENSOR_MAG    4
//#define MSP_STATUS_SENSOR_GPS    8
//#define MSP_STATUS_SENSOR_SONAR 16
//
//
//// MSP_STATUS_EX reply
//struct msp_status_ex_t {
//  uint16_t cycleTime;
//  uint16_t i2cErrorCounter;
//  uint16_t sensor;                    // MSP_STATUS_SENSOR_...
//  uint32_t flightModeFlags;           // see getActiveModes()
//  uint8_t  configProfileIndex;
//  uint16_t averageSystemLoadPercent;  // 0...100
//  uint16_t armingFlags;
//  uint8_t  accCalibrationAxisFlags;
//} __attribute__ ((packed));
//
//
//// MSP_STATUS
//struct msp_status_t {
//  uint16_t cycleTime;
//  uint16_t i2cErrorCounter;
//  uint16_t sensor;                    // MSP_STATUS_SENSOR_...
//  uint32_t flightModeFlags;           // see getActiveModes()
//  uint8_t  configProfileIndex;
//} __attribute__ ((packed));
//
//
//// MSP_SENSOR_STATUS reply
//struct msp_sensor_status_t {
//  uint8_t isHardwareHealthy;  // 0...1
//  uint8_t hwGyroStatus;
//  uint8_t hwAccelerometerStatus;
//  uint8_t hwCompassStatus;
//  uint8_t hwBarometerStatus;
//  uint8_t hwGPSStatus;
//  uint8_t hwRangefinderStatus;
//  uint8_t hwPitotmeterStatus;
//  uint8_t hwOpticalFlowStatus;
//} __attribute__ ((packed));
//
//
//#define MSP_MAX_SUPPORTED_SERVOS 8
//
//// MSP_SERVO reply
//struct msp_servo_t {
//  uint16_t servo[MSP_MAX_SUPPORTED_SERVOS];
//} __attribute__ ((packed));
//
//
//// MSP_SERVO_CONFIGURATIONS reply
//struct msp_servo_configurations_t {
//  __attribute__ ((packed)) struct {
//    uint16_t min;
//    uint16_t max;
//    uint16_t middle;
//    uint8_t rate;
//    uint8_t angleAtMin;
//    uint8_t angleAtMax;
//    uint8_t forwardFromChannel;
//    uint32_t reversedSources;
//  } conf[MSP_MAX_SUPPORTED_SERVOS];
//} __attribute__ ((packed));
//
//
//#define MSP_MAX_SERVO_RULES (2 * MSP_MAX_SUPPORTED_SERVOS)
//
//// MSP_SERVO_MIX_RULES reply
//struct msp_servo_mix_rules_t {
//  __attribute__ ((packed)) struct {
//    uint8_t targetChannel;
//    uint8_t inputSource;
//    uint8_t rate;
//    uint8_t speed;
//    uint8_t min;
//    uint8_t max;
//  } mixRule[MSP_MAX_SERVO_RULES];
//} __attribute__ ((packed));
//
//
//#define MSP_MAX_SUPPORTED_MOTORS 8
//
//// MSP_MOTOR reply
//struct msp_motor_t {
//  uint16_t motor[MSP_MAX_SUPPORTED_MOTORS];
//} __attribute__ ((packed));
//
//
//#define MSP_MAX_SUPPORTED_CHANNELS 16
//
//// MSP_RC reply
//struct msp_rc_t {
//  uint16_t channelValue[MSP_MAX_SUPPORTED_CHANNELS];
//} __attribute__ ((packed));
//
//
//// MSP_ATTITUDE reply
//struct msp_attitude_t {
//  int16_t roll;
//  int16_t pitch;
//  int16_t yaw;
//} __attribute__ ((packed));
//
//
//// MSP_ALTITUDE reply
//struct msp_altitude_t {
//  int32_t estimatedActualPosition;  // cm
//  int16_t estimatedActualVelocity;  // cm/s
//  int32_t baroLatestAltitude;
//} __attribute__ ((packed));
//
//
//// MSP_SONAR_ALTITUDE reply
//struct msp_sonar_altitude_t {
//  int32_t altitude;
//} __attribute__ ((packed));
//
//
//// MSP_ANALOG reply
//struct msp_analog_t {
//  uint8_t  vbat;     // 0...255
//  uint16_t mAhDrawn; // milliamp hours drawn from battery
//  uint16_t rssi;     // 0..1023
//  int16_t  amperage; // send amperage in 0.01 A steps, range is -320A to 320A
//} __attribute__ ((packed));
//
//
//// MSP_ARMING_CONFIG reply
//struct msp_arming_config_t {
//  uint8_t auto_disarm_delay;
//  uint8_t disarm_kill_switch;
//} __attribute__ ((packed));
//
//
//// MSP_LOOP_TIME reply
//struct msp_loop_time_t {
//  uint16_t looptime;
//} __attribute__ ((packed));
//
//
//// MSP_RC_TUNING reply
//struct msp_rc_tuning_t {
//  uint8_t  rcRate8;  // no longer used
//  uint8_t  rcExpo8;
//  uint8_t  rates[3]; // R,P,Y
//  uint8_t  dynThrPID;
//  uint8_t  thrMid8;
//  uint8_t  thrExpo8;
//  uint16_t tpa_breakpoint;
//  uint8_t  rcYawExpo8;
//} __attribute__ ((packed));
//
//
//// MSP_PID reply
//struct msp_pid_t {
//  uint8_t roll[3];     // 0=P, 1=I, 2=D
//  uint8_t pitch[3];    // 0=P, 1=I, 2=D
//  uint8_t yaw[3];      // 0=P, 1=I, 2=D
//  uint8_t pos_z[3];    // 0=P, 1=I, 2=D
//  uint8_t pos_xy[3];   // 0=P, 1=I, 2=D
//  uint8_t vel_xy[3];   // 0=P, 1=I, 2=D
//  uint8_t surface[3];  // 0=P, 1=I, 2=D
//  uint8_t level[3];    // 0=P, 1=I, 2=D
//  uint8_t heading[3];  // 0=P, 1=I, 2=D
//  uint8_t vel_z[3];    // 0=P, 1=I, 2=D
//} __attribute__ ((packed));
//
//
//// MSP_MISC reply
//struct msp_misc_t {
//  uint16_t midrc;
//  uint16_t minthrottle;
//  uint16_t maxthrottle;
//  uint16_t mincommand;
//  uint16_t failsafe_throttle;
//  uint8_t  gps_provider;
//  uint8_t  gps_baudrate;
//  uint8_t  gps_ubx_sbas;
//  uint8_t  multiwiiCurrentMeterOutput;
//  uint8_t  rssi_channel;
//  uint8_t  dummy;
//  uint16_t mag_declination;
//  uint8_t  vbatscale;
//  uint8_t  vbatmincellvoltage;
//  uint8_t  vbatmaxcellvoltage;
//  uint8_t  vbatwarningcellvoltage;
//} __attribute__ ((packed));
//
//
//// values for msp_raw_gps_t.fixType
//#define MSP_GPS_NO_FIX 0
//#define MSP_GPS_FIX_2D 1
//#define MSP_GPS_FIX_3D 2
//
//
//// MSP_RAW_GPS reply
//struct msp_raw_gps_t {
//  uint8_t  fixType;       // MSP_GPS_NO_FIX, MSP_GPS_FIX_2D, MSP_GPS_FIX_3D
//  uint8_t  numSat;
//  int32_t  lat;           // 1 / 10000000 deg
//  int32_t  lon;           // 1 / 10000000 deg
//  int16_t  alt;           // meters
//  int16_t  groundSpeed;   // cm/s
//  int16_t  groundCourse;  // unit: degree x 10
//  uint16_t hdop;
//} __attribute__ ((packed));
//
//
//// MSP_COMP_GPS reply
//struct msp_comp_gps_t {
//  int16_t  distanceToHome;  // distance to home in meters
//  int16_t  directionToHome; // direction to home in degrees
//  uint8_t  heartbeat;       // toggles 0 and 1 for each change
//} __attribute__ ((packed));
//
//

enum MSP_Nav_Status_Mode: Int {
    // values for msp_nav_status_t.mode
    case MSP_NAV_STATUS_MODE_NONE   = 0
    case MSP_NAV_STATUS_MODE_HOLD   = 1
    case MSP_NAV_STATUS_MODE_RTH    = 2
    case MSP_NAV_STATUS_MODE_NAV    = 3
    case MSP_NAV_STATUS_MODE_EMERG  = 15
}

enum MSP_Nav_Status_State: Int {
    // values for msp_nav_status_t.state
    case MSP_NAV_STATUS_STATE_NONE                = 0  // None
    case MSP_NAV_STATUS_STATE_RTH_START           = 1  // RTH Start
    case MSP_NAV_STATUS_STATE_RTH_ENROUTE         = 2  // RTH Enroute
    case MSP_NAV_STATUS_STATE_HOLD_INFINIT        = 3  // PosHold infinit
    case MSP_NAV_STATUS_STATE_HOLD_TIMED          = 4  // PosHold timed
    case MSP_NAV_STATUS_STATE_WP_ENROUTE          = 5  // WP Enroute
    case MSP_NAV_STATUS_STATE_PROCESS_NEXT        = 6  // Process next
    case MSP_NAV_STATUS_STATE_DO_JUMP             = 7  // Jump
    case MSP_NAV_STATUS_STATE_LAND_START          = 8  // Start Land
    case MSP_NAV_STATUS_STATE_LAND_IN_PROGRESS    = 9  // Land in Progress
    case MSP_NAV_STATUS_STATE_LANDED             = 10  // Landed
    case MSP_NAV_STATUS_STATE_LAND_SETTLE        = 11  // Settling before land
    case MSP_NAV_STATUS_STATE_LAND_START_DESCENT = 12  // Start descent
}

enum MSP_Nav_Status_Waypoint_Action: Int {
    // values for msp_nav_status_t.activeWpAction, msp_set_wp_t.action
    case MSP_NAV_STATUS_WAYPOINT_ACTION_WAYPOINT = 0x01
    case MSP_NAV_STATUS_WAYPOINT_ACTION_RTH      = 0x04
}

enum MSP_Nav_Status_Error: Int {
    // values for msp_nav_status_t.error
    case MSP_NAV_STATUS_ERROR_NONE               = 0   // All systems clear
    case MSP_NAV_STATUS_ERROR_TOOFAR             = 1   // Next waypoint distance is more than safety distance
    case MSP_NAV_STATUS_ERROR_SPOILED_GPS        = 2   // GPS reception is compromised - Nav paused - copter is adrift !
    case MSP_NAV_STATUS_ERROR_WP_CRC             = 3   // CRC error reading WP data from EEPROM - Nav stopped
    case MSP_NAV_STATUS_ERROR_FINISH             = 4   // End flag detected, navigation finished
    case MSP_NAV_STATUS_ERROR_TIMEWAIT           = 5   // Waiting for poshold timer
    case MSP_NAV_STATUS_ERROR_INVALID_JUMP       = 6   // Invalid jump target detected, aborting
    case MSP_NAV_STATUS_ERROR_INVALID_DATA       = 7   // Invalid mission step action code, aborting, copter is adrift
    case MSP_NAV_STATUS_ERROR_WAIT_FOR_RTH_ALT   = 8   // Waiting to reach RTH Altitude
    case MSP_NAV_STATUS_ERROR_GPS_FIX_LOST       = 9   // Gps fix lost, aborting mission
    case MSP_NAV_STATUS_ERROR_DISARMED          = 10   // NAV engine disabled due disarm
    case MSP_NAV_STATUS_ERROR_LANDING           = 11   // Landing
}


//// MSP_NAV_STATUS reply
//struct msp_nav_status_t {
//  uint8_t mode;           // one of MSP_NAV_STATUS_MODE_XXX
//  uint8_t state;          // one of MSP_NAV_STATUS_STATE_XXX
//  uint8_t activeWpAction; // combination of MSP_NAV_STATUS_WAYPOINT_ACTION_XXX
//  uint8_t activeWpNumber;
//  uint8_t error;          // one of MSP_NAV_STATUS_ERROR_XXX
//  int16_t magHoldHeading;
//} __attribute__ ((packed));
//
//
//// MSP_GPSSVINFO reply
//struct msp_gpssvinfo_t {
//  uint8_t dummy1;
//  uint8_t dummy2;
//  uint8_t dummy3;
//  uint8_t dummy4;
//  uint8_t HDOP;
//} __attribute__ ((packed));
//
//
//// MSP_GPSSTATISTICS reply
//struct msp_gpsstatistics_t {
//  uint16_t lastMessageDt;
//  uint32_t errors;
//  uint32_t timeouts;
//  uint32_t packetCount;
//  uint16_t hdop;
//  uint16_t eph;
//  uint16_t epv;
//} __attribute__ ((packed));
//
//
//// MSP_UID reply
//struct msp_uid_t {
//  uint32_t uid0;
//  uint32_t uid1;
//  uint32_t uid2;
//} __attribute__ ((packed));

struct MSP_Feature: OptionSet {
    let rawValue: UInt8
    
    // MSP_FEATURE mask
    static let MSP_FEATURE_RX_PPM              = (1 <<  0)
    static let MSP_FEATURE_VBAT                = (1 <<  1)
    static let MSP_FEATURE_UNUSED_1            = (1 <<  2)
    static let MSP_FEATURE_RX_SERIAL           = (1 <<  3)
    static let MSP_FEATURE_MOTOR_STOP          = (1 <<  4)
    static let MSP_FEATURE_SERVO_TILT          = (1 <<  5)
    static let MSP_FEATURE_SOFTSERIAL          = (1 <<  6)
    static let MSP_FEATURE_GPS                 = (1 <<  7)
    static let MSP_FEATURE_UNUSED_3            = (1 <<  8)         // was FEATURE_FAILSAFE
    static let MSP_FEATURE_UNUSED_4            = (1 <<  9)         // was FEATURE_SONAR
    static let MSP_FEATURE_TELEMETRY           = (1 << 10)
    static let MSP_FEATURE_CURRENT_METER       = (1 << 11)
    static let MSP_FEATURE_3D                  = (1 << 12)
    static let MSP_FEATURE_RX_PARALLEL_PWM     = (1 << 13)
    static let MSP_FEATURE_RX_MSP              = (1 << 14)
    static let MSP_FEATURE_RSSI_ADC            = (1 << 15)
    static let MSP_FEATURE_LED_STRIP           = (1 << 16)
    static let MSP_FEATURE_DASHBOARD           = (1 << 17)
    static let MSP_FEATURE_UNUSED_2            = (1 << 18)
    static let MSP_FEATURE_BLACKBOX            = (1 << 19)
    static let MSP_FEATURE_CHANNEL_FORWARDING  = (1 << 20)
    static let MSP_FEATURE_TRANSPONDER         = (1 << 21)
    static let MSP_FEATURE_AIRMODE             = (1 << 22)
    static let MSP_FEATURE_SUPEREXPO_RATES     = (1 << 23)
    static let MSP_FEATURE_VTX                 = (1 << 24)
    static let MSP_FEATURE_RX_SPI              = (1 << 25)
    static let MSP_FEATURE_SOFTSPI             = (1 << 26)
    static let MSP_FEATURE_PWM_SERVO_DRIVER    = (1 << 27)
    static let MSP_FEATURE_PWM_OUTPUT_ENABLE   = (1 << 28)
    static let MSP_FEATURE_OSD                 = (1 << 29)
}

//// MSP_FEATURE reply
//struct msp_feature_t {
//  uint32_t featureMask; // combination of MSP_FEATURE_XXX
//} __attribute__ ((packed));
//
//
//// MSP_BOARD_ALIGNMENT reply
//struct msp_board_alignment_t {
//  int16_t rollDeciDegrees;
//  int16_t pitchDeciDegrees;
//  int16_t yawDeciDegrees;
//} __attribute__ ((packed));


enum MSP_Current_Sensor: Int {
    // values for msp_current_meter_config_t.currentMeterType
    case MSP_CURRENT_SENSOR_NONE    = 0
    case MSP_CURRENT_SENSOR_ADC     = 1
    case MSP_CURRENT_SENSOR_VIRTUAL = 2
}


//// MSP_CURRENT_METER_CONFIG reply
//struct msp_current_meter_config_t {
//  int16_t currentMeterScale;
//  int16_t currentMeterOffset;
//  uint8_t currentMeterType; // MSP_CURRENT_SENSOR_XXX
//  uint16_t batteryCapacity;
//} __attribute__ ((packed));


enum MSP_SerialRx: Int {
    // msp_rx_config_t.serialrx_provider
    case MSP_SERIALRX_SPEKTRUM1024      = 0
    case MSP_SERIALRX_SPEKTRUM2048      = 1
    case MSP_SERIALRX_SBUS              = 2
    case MSP_SERIALRX_SUMD              = 3
    case MSP_SERIALRX_SUMH              = 4
    case MSP_SERIALRX_XBUS_MODE_B       = 5
    case MSP_SERIALRX_XBUS_MODE_B_RJ01  = 6
    case MSP_SERIALRX_IBUS              = 7
    case MSP_SERIALRX_JETIEXBUS         = 8
    case MSP_SERIALRX_CRSF              = 9
}

enum MSP_SPI_PROT_NRF24RX: Int {
    // msp_rx_config_t.rx_spi_protocol values
    case MSP_SPI_PROT_NRF24RX_V202_250K = 0
    case MSP_SPI_PROT_NRF24RX_V202_1M   = 1
    case MSP_SPI_PROT_NRF24RX_SYMA_X    = 2
    case MSP_SPI_PROT_NRF24RX_SYMA_X5C  = 3
    case MSP_SPI_PROT_NRF24RX_CX10      = 4
    case MSP_SPI_PROT_NRF24RX_CX10A     = 5
    case MSP_SPI_PROT_NRF24RX_H8_3D     = 6
    case MSP_SPI_PROT_NRF24RX_INAV      = 7
}



//// MSP_RX_CONFIG reply
//struct msp_rx_config_t {
//  uint8_t   serialrx_provider;  // one of MSP_SERIALRX_XXX values
//  uint16_t  maxcheck;
//  uint16_t  midrc;
//  uint16_t  mincheck;
//  uint8_t   spektrum_sat_bind;
//  uint16_t  rx_min_usec;
//  uint16_t  rx_max_usec;
//  uint8_t   dummy1;
//  uint8_t   dummy2;
//  uint16_t  dummy3;
//  uint8_t   rx_spi_protocol;  // one of MSP_SPI_PROT_XXX values
//  uint32_t  rx_spi_id;
//  uint8_t   rx_spi_rf_channel_count;
//} __attribute__ ((packed));
//
//
//#define MSP_MAX_MAPPABLE_RX_INPUTS 8
//
//// MSP_RX_MAP reply
//struct msp_rx_map_t {
//  uint8_t rxmap[MSP_MAX_MAPPABLE_RX_INPUTS];  // [0]=roll channel, [1]=pitch channel, [2]=yaw channel, [3]=throttle channel, [3+n]=aux n channel, etc...
//} __attribute__ ((packed));

enum MSP_Sensor_Align: Int {
    // values for msp_sensor_alignment_t.gyro_align, acc_align, mag_align
    case MSP_SENSOR_ALIGN_CW0_DEG        = 1
    case MSP_SENSOR_ALIGN_CW90_DEG       = 2
    case MSP_SENSOR_ALIGN_CW180_DEG      = 3
    case MSP_SENSOR_ALIGN_CW270_DEG      = 4
    case MSP_SENSOR_ALIGN_CW0_DEG_FLIP   = 5
    case MSP_SENSOR_ALIGN_CW90_DEG_FLIP  = 6
    case MSP_SENSOR_ALIGN_CW180_DEG_FLIP = 7
    case MSP_SENSOR_ALIGN_CW270_DEG_FLIP = 8
}

//// MSP_SENSOR_ALIGNMENT reply
//struct msp_sensor_alignment_t {
//  uint8_t gyro_align;   // one of MSP_SENSOR_ALIGN_XXX
//  uint8_t acc_align;    // one of MSP_SENSOR_ALIGN_XXX
//  uint8_t mag_align;    // one of MSP_SENSOR_ALIGN_XXX
//} __attribute__ ((packed));
//
//
//// MSP_CALIBRATION_DATA reply
//struct msp_calibration_data_t {
//  int16_t accZeroX;
//  int16_t accZeroY;
//  int16_t accZeroZ;
//  int16_t accGainX;
//  int16_t accGainY;
//  int16_t accGainZ;
//  int16_t magZeroX;
//  int16_t magZeroY;
//  int16_t magZeroZ;
//} __attribute__ ((packed));
//
//
//// MSP_SET_HEAD command
//struct msp_set_head_t {
//  int16_t magHoldHeading; // degrees
//} __attribute__ ((packed));
//
//
//// MSP_SET_RAW_RC command
//struct msp_set_raw_rc_t {
//  uint16_t channel[MSP_MAX_SUPPORTED_CHANNELS];
//} __attribute__ ((packed));
//
//
//// MSP_SET_PID command
//typedef msp_pid_t msp_set_pid_t;
//
//
//// MSP_SET_RAW_GPS command
//struct msp_set_raw_gps_t {
//  uint8_t  fixType;       // MSP_GPS_NO_FIX, MSP_GPS_FIX_2D, MSP_GPS_FIX_3D
//  uint8_t  numSat;
//  int32_t  lat;           // 1 / 10000000 deg
//  int32_t  lon;           // 1 / 10000000 deg
//  int16_t  alt;           // meters
//  int16_t  groundSpeed;   // cm/s
//} __attribute__ ((packed));
//
//
//// MSP_SET_WP command
//// Special waypoints are 0 and 255. 0 is the RTH position, 255 is the POSHOLD position (lat, lon, alt).
//struct msp_set_wp_t {
//  uint8_t waypointNumber;
//  uint8_t action;   // one of MSP_NAV_STATUS_WAYPOINT_ACTION_XXX
//  int32_t lat;      // decimal degrees latitude * 10000000
//  int32_t lon;      // decimal degrees longitude * 10000000
//  int32_t alt;      // altitude (cm)
//  int16_t p1;       // speed (cm/s) when action is MSP_NAV_STATUS_WAYPOINT_ACTION_WAYPOINT, or "land" (value 1) when action is MSP_NAV_STATUS_WAYPOINT_ACTION_RTH
//  int16_t p2;       // not used
//  int16_t p3;       // not used
//  uint8_t flag;     // 0xa5 = last, otherwise set to 0
//} __attribute__ ((packed));
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//
//class MSP {
//
//  public:
//
//    void begin(Stream & stream, uint32_t timeout = 500);
//
//    // low level functions
//
//    void send(uint8_t messageID, void * payload, uint8_t size);
//    bool recv(uint8_t * messageID, void * payload, uint8_t maxSize, uint8_t * recvSize);
//
//    bool waitFor(uint8_t messageID, void * payload, uint8_t maxSize, uint8_t * recvSize = NULL);
//
//    bool request(uint8_t messageID, void * payload, uint8_t maxSize, uint8_t * recvSize = NULL);
//
//    bool command(uint8_t messageID, void * payload, uint8_t size, bool waitACK = true);
//
//    void reset();
//
//    // high level functions
//
//    bool getActiveModes(uint32_t * activeModes);
//
//
//  private:
//
//    Stream * _stream;
//    uint32_t _timeout;
//
//};


//-------

//void MSP::begin(Stream & stream, uint32_t timeout)
//{
//  _stream   = &stream;
//  _timeout  = timeout;
//}
//
//
//void MSP::reset()
//{
//  _stream->flush();
//  while (_stream->available() > 0)
//    _stream->read();
//}
//
//void MSP::send(uint8_t messageID, void * payload, uint8_t size)
//{
//  _stream->write('$');
//  _stream->write('M');
//  _stream->write('<');
//  _stream->write(size);
//  _stream->write(messageID);
//  uint8_t checksum = size ^ messageID;
//  uint8_t * payloadPtr = (uint8_t*)payload;
//  for (uint8_t i = 0; i < size; ++i) {
//    uint8_t b = *(payloadPtr++);
//    checksum ^= b;
//    _stream->write(b);
//  }
//  _stream->write(checksum);
//}
//
//
//// timeout in milliseconds
//bool MSP::recv(uint8_t * messageID, void * payload, uint8_t maxSize, uint8_t * recvSize)
//{
//  uint32_t t0 = millis();
//
//  while (1) {
//
//    // read header
//    while (_stream->available() < 6)
//      if (millis() - t0 >= _timeout)
//        return false;
//    char header[3];
//    _stream->readBytes((char*)header, 3);
//
//    // check header
//    if (header[0] == '$' && header[1] == 'M' && header[2] == '>') {
//      // header ok, read payload size
//      *recvSize = _stream->read();
//
//      // read message ID (type)
//      *messageID = _stream->read();
//
//      uint8_t checksumCalc = *recvSize ^ *messageID;
//
//      // read payload
//      uint8_t * payloadPtr = (uint8_t*)payload;
//      uint8_t idx = 0;
//      while (idx < *recvSize) {
//        if (millis() - t0 >= _timeout)
//          return false;
//        if (_stream->available() > 0) {
//          uint8_t b = _stream->read();
//          checksumCalc ^= b;
//          if (idx < maxSize)
//            *(payloadPtr++) = b;
//          ++idx;
//        }
//      }
//      // zero remaining bytes if *size < maxSize
//      for (; idx < maxSize; ++idx)
//        *(payloadPtr++) = 0;
//
//      // read and check checksum
//      while (_stream->available() == 0)
//        if (millis() - t0 >= _timeout)
//          return false;
//      uint8_t checksum = _stream->read();
//      if (checksumCalc == checksum) {
//        return true;
//      }
//
//    }
//  }
//
//}
//
//
//// wait for messageID
//// recvSize can be NULL
//bool MSP::waitFor(uint8_t messageID, void * payload, uint8_t maxSize, uint8_t * recvSize)
//{
//  uint8_t recvMessageID;
//  uint8_t recvSizeValue;
//  uint32_t t0 = millis();
//  while (millis() - t0 < _timeout)
//    if (recv(&recvMessageID, payload, maxSize, (recvSize ? recvSize : &recvSizeValue)) && messageID == recvMessageID)
//      return true;
//
//  // timeout
//  return false;
//}
//
//
//// send a message and wait for the reply
//// recvSize can be NULL
//bool MSP::request(uint8_t messageID, void * payload, uint8_t maxSize, uint8_t * recvSize)
//{
//  send(messageID, NULL, 0);
//  return waitFor(messageID, payload, maxSize, recvSize);
//}
//
//
//// send message and wait for ack
//bool MSP::command(uint8_t messageID, void * payload, uint8_t size, bool waitACK)
//{
//  send(messageID, payload, size);
//
//  // ack required
//  if (waitACK)
//    return waitFor(messageID, NULL, 0);
//
//  return true;
//}
//
//
//// map MSP_MODE_xxx to box ids
//// mixed values from cleanflight and inav
//static const uint8_t BOXIDS[30] PROGMEM = {
//  0,  //  0: MSP_MODE_ARM
//  1,  //  1: MSP_MODE_ANGLE
//  2,  //  2: MSP_MODE_HORIZON
//  3,  //  3: MSP_MODE_NAVALTHOLD (cleanflight BARO)
//  5,  //  4: MSP_MODE_MAG
//  6,  //  5: MSP_MODE_HEADFREE
//  7,  //  6: MSP_MODE_HEADADJ
//  8,  //  7: MSP_MODE_CAMSTAB
//  10, //  8: MSP_MODE_NAVRTH (cleanflight GPSHOME)
//  11, //  9: MSP_MODE_NAVPOSHOLD (cleanflight GPSHOLD)
//  12, // 10: MSP_MODE_PASSTHRU
//  13, // 11: MSP_MODE_BEEPERON
//  15, // 12: MSP_MODE_LEDLOW
//  16, // 13: MSP_MODE_LLIGHTS
//  19, // 14: MSP_MODE_OSD
//  20, // 15: MSP_MODE_TELEMETRY
//  21, // 16: MSP_MODE_GTUNE
//  22, // 17: MSP_MODE_SONAR
//  26, // 18: MSP_MODE_BLACKBOX
//  27, // 19: MSP_MODE_FAILSAFE
//  28, // 20: MSP_MODE_NAVWP (cleanflight AIRMODE)
//  29, // 21: MSP_MODE_AIRMODE (cleanflight DISABLE3DSWITCH)
//  30, // 22: MSP_MODE_HOMERESET (cleanflight FPVANGLEMIX)
//  31, // 23: MSP_MODE_GCSNAV (cleanflight BLACKBOXERASE)
//  32, // 24: MSP_MODE_HEADINGLOCK
//  33, // 25: MSP_MODE_SURFACE
//  34, // 26: MSP_MODE_FLAPERON
//  35, // 27: MSP_MODE_TURNASSIST
//  36, // 28: MSP_MODE_NAVLAUNCH
//  37, // 29: MSP_MODE_AUTOTRIM
//};
//
//
//// returns active mode (using MSP_STATUS and MSP_BOXIDS messages)
//// see MSP_MODE_... for bits inside activeModes
//bool MSP::getActiveModes(uint32_t * activeModes)
//{
//  // request status ex
//  msp_status_t status;
//  if (request(MSP_STATUS, &status, sizeof(status))) {
//    // request permanent ids associated to boxes
//    uint8_t ids[sizeof(BOXIDS)];
//    uint8_t recvSize;
//    if (request(MSP_BOXIDS, ids, sizeof(ids), &recvSize)) {
//      // compose activeModes, converting BOXIDS to bit map (setting 1 if related flag in flightModeFlags is set)
//      *activeModes = 0;
//      for (uint8_t i = 0; i < recvSize; ++i) {
//        if (status.flightModeFlags & (1 << i)) {
//          for (uint8_t j = 0; j < sizeof(BOXIDS); ++j) {
//            if (pgm_read_byte(BOXIDS + j) == ids[i]) {
//              *activeModes |= 1 << j;
//              break;
//            }
//          }
//        }
//      }
//      return true;
//    }
//  }
//
//  return false;
//}


//void loop() {
//  msp_status_ex_t status_ex;
//  if (msp.request(MSP_STATUS_EX, &status_ex, sizeof(status_ex))) {
//
//    uint32_t activeModes = status_ex.flightModeFlags;
//    if (activeModes>>MSP_MODE_ARM & 1)
//      Serial.println("ARMED");
//    else {
//      Serial.println("NOT ARMED");
//    }
//  }
//}


//void loop()
//{
//  msp_rc_t rc;
//  msp_attitude_t attitude;
//  msp_analog_t analog;
//  _delay_ms(500);
//  uint32_t * activeModes;
//  if (msp.request(MSP_ANALOG, &analog, sizeof(analog))) {
//    uint8_t  vbat     = analog.vbat;     // 0...255
//    uint16_t mAhDrawn = analog.mAhDrawn; // milliamp hours drawn from battery
//    uint16_t rssi     = analog.rssi;     // 0..1023
//    int16_t  amperage = analog.amperage; // send amperage in 0.01 A steps, range is -320A to 320A
//    mySerial.print("Batteria: " + String(vbat/10.0));
//    mySerial.print(" mAh: " + String(mAhDrawn));
//    //mySerial.print(" RSSI: " + String(rssi));
//    mySerial.println(" A: " + String(amperage/100.0));
//  }
//
//  if (msp.request(MSP_RC, &rc, sizeof(rc))) {
//    uint16_t roll     = rc.channelValue[0];
//    uint16_t pitch    = rc.channelValue[1];
//    uint16_t yaw      = rc.channelValue[2];
//    uint16_t throttle = rc.channelValue[3];
//    mySerial.print("RC-Roll: " + String(roll));
//    mySerial.print(" RC-Pitch: " + String(pitch));
//    mySerial.print(" RC-Throttle: " + String(throttle));
//    mySerial.println(" RC-Yaw: " + String(yaw));
//  }
//  
//  if (msp.request(MSP_ATTITUDE, &attitude, sizeof(attitude))) {
//    int16_t roll     = attitude.roll;
//    int16_t pitch    = attitude.pitch;
//    uint16_t yaw      = attitude.yaw;
//    mySerial.print("Att-Roll: " + String(roll/10.0));
//    mySerial.print(" Att-Pitch: " + String(pitch/10.0));
//    mySerial.println(" Att-Yaw: " + String(yaw));
//  }
//  
//    msp.getActiveModes(*activeModes);         //
//    mySerial.println(String(*activeModes));   //This line does not work!!
//}
