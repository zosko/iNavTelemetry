//
//  MSP.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/25/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import Foundation

let MSP_MAX_SUPPORTED_SERVOS: Int = 8
let MSP_MAX_SERVO_RULES: Int = (2 * MSP_MAX_SUPPORTED_SERVOS)
let MSP_MAX_SUPPORTED_MOTORS: Int = 8
let MSP_MAX_SUPPORTED_CHANNELS: Int = 16
let MSP_MAX_MAPPABLE_RX_INPUTS: Int = 8

enum MSP_Request_Replies: UInt8 {
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
    let protocolVersion: UInt8
    let APIMajor: UInt8
    let APIMinor: UInt8
}


// MSP_FC_VARIANT reply
struct msp_fc_variant_t {
    let flightControlIdentifier: [CChar] = [CChar](repeating: 0, count: 4)
}


// MSP_FC_VERSION reply
struct msp_fc_version_t {
    let versionMajor: Int8
    let versionMinor: Int8
    let versionPatchLevel: Int8
}


// MSP_BOARD_INFO reply
struct msp_board_info_t {
    let boardIdentifier: [CChar] = [CChar](repeating: 0, count: 4)
    let hardwareRevision: UInt16
}


// MSP_BUILD_INFO reply
struct msp_build_info_t {
    let buildDate: [CChar] = [CChar](repeating: 0, count: 11)
    let buildTime: [CChar] = [CChar](repeating: 0, count: 8)
    let shortGitRevision: [CChar] = [CChar](repeating: 0, count: 7)
}


// MSP_RAW_IMU reply
struct msp_raw_imu_t {
    let acc: [Int16] = [Int16](repeating: 0, count: 3) // x, y, z
    let gyro: [Int16] = [Int16](repeating: 0, count: 3) // x, y, z
    let mag: [Int16] = [Int16](repeating: 0, count: 3)  // x, y, z
}


enum MSP_Status_Sensor: Int {
    // flags for msp_status_ex_t.sensor and msp_status_t.sensor
    case MSP_STATUS_SENSOR_ACC    = 1
    case MSP_STATUS_SENSOR_BARO   = 2
    case MSP_STATUS_SENSOR_MAG    = 4
    case MSP_STATUS_SENSOR_GPS    = 8
    case MSP_STATUS_SENSOR_SONAR  = 16
}


// MSP_STATUS_EX reply
struct msp_status_ex_t {
    let cycleTime: UInt16
    let i2cErrorCounter: UInt16
    let sensor: UInt16                    // MSP_STATUS_SENSOR_...
    let flightModeFlags: UInt32           // see getActiveModes()
    let configProfileIndex: UInt8
    let averageSystemLoadPercent: UInt16  // 0...100
    let armingFlags: UInt16
    let accCalibrationAxisFlags: UInt8
}


// MSP_STATUS
struct msp_status_t {
    let cycleTime: UInt16
    let i2cErrorCounter: UInt16
    let sensor: UInt16                    // MSP_STATUS_SENSOR_...
    let flightModeFlags: UInt32           // see getActiveModes()
    let configProfileIndex: UInt8
}


// MSP_SENSOR_STATUS reply
struct msp_sensor_status_t {
    let isHardwareHealthy: UInt8  // 0...1
    let hwGyroStatus: UInt8
    let hwAccelerometerStatus: UInt8
    let hwCompassStatus: UInt8
    let hwBarometerStatus: UInt8
    let hwGPSStatus: UInt8
    let hwRangefinderStatus: UInt8
    let hwPitotmeterStatus: UInt8
    let hwOpticalFlowStatus: UInt8
}


// MSP_SERVO reply
struct msp_servo_t {
    let servo: [UInt16] = [UInt16](repeating: 0, count: MSP_MAX_SUPPORTED_SERVOS)
}


// MSP_SERVO_CONFIGURATIONS reply
struct msp_servo_configurations_t {
    
    struct config{
        let min: UInt16
        let max: UInt16
        let middle: UInt16
        let rate: UInt8
        let angleAtMin: UInt8
        let angleAtMax: UInt8
        let forwardFromChannel: UInt8
        let reversedSources: UInt32
    }
    
    let conf: [config] = [config](repeating: config(min: 0, max: 0, middle: 0, rate: 0, angleAtMin: 0, angleAtMax: 0, forwardFromChannel: 0, reversedSources: 0), count: MSP_MAX_SUPPORTED_SERVOS)
}


// MSP_SERVO_MIX_RULES reply
struct msp_servo_mix_rules_t {
    struct rules{
        let targetChannel: UInt8
        let inputSource: UInt8
        let rate: UInt8
        let speed: UInt8
        let min: UInt8
        let max: UInt8
    }
    
    let mixRule: [rules] = [rules](repeating: rules(targetChannel: 0, inputSource: 0, rate: 0, speed: 0, min: 0, max: 0), count: MSP_MAX_SERVO_RULES)
}



// MSP_MOTOR reply
struct msp_motor_t {
    let motor: [UInt16] = [UInt16](repeating: 0, count: MSP_MAX_SUPPORTED_MOTORS)
}

// MSP_RC reply
struct msp_rc_t {
    let channelValue: [UInt16] = [UInt16](repeating: 0, count: MSP_MAX_SUPPORTED_CHANNELS)
}


// MSP_ATTITUDE reply
struct msp_attitude_t {
    let roll: Int16
    let pitch: Int16
    let yaw: Int16
}


// MSP_ALTITUDE reply
struct msp_altitude_t {
    let estimatedActualPosition: Int32  // cm
    let estimatedActualVelocity: Int16  // cm/s
    let baroLatestAltitude: Int32
}


// MSP_SONAR_ALTITUDE reply
struct msp_sonar_altitude_t {
    let altitude: Int32
}


// MSP_ANALOG reply
struct msp_analog_t {
    let vbat: UInt8     // 0...255
    let mAhDrawn: UInt16 // milliamp hours drawn from battery
    let rssi: UInt16     // 0..1023
    let amperage: Int16 // send amperage in 0.01 A steps, range is -320A to 320A
}


// MSP_ARMING_CONFIG reply
struct msp_arming_config_t {
    let auto_disarm_delay: UInt8
    let disarm_kill_switch: UInt8
}


// MSP_LOOP_TIME reply
struct msp_loop_time_t {
    let looptime: UInt16
}


// MSP_RC_TUNING reply
struct msp_rc_tuning_t {
    let rcRate8: UInt8  // no longer used
    let rcExpo8: UInt8
    let rates: [UInt8] = [UInt8](repeating: 0, count: 3) // R,P,Y
    let dynThrPID: UInt8
    let thrMid8: UInt8
    let thrExpo8: UInt8
    let tpa_breakpoint: UInt16
    let rcYawExpo8: UInt8
}


// MSP_PID reply
struct msp_pid_t {
    let roll: [UInt8] = [UInt8](repeating: 0, count: 3)     // 0=P, 1=I, 2=D
    let pitch: [UInt8] = [UInt8](repeating: 0, count: 3)    // 0=P, 1=I, 2=D
    let yaw: [UInt8] = [UInt8](repeating: 0, count: 3)      // 0=P, 1=I, 2=D
    let pos_z: [UInt8] = [UInt8](repeating: 0, count: 3)    // 0=P, 1=I, 2=D
    let pos_xy: [UInt8] = [UInt8](repeating: 0, count: 3)   // 0=P, 1=I, 2=D
    let vel_xy: [UInt8] = [UInt8](repeating: 0, count: 3)   // 0=P, 1=I, 2=D
    let surface: [UInt8] = [UInt8](repeating: 0, count: 3)  // 0=P, 1=I, 2=D
    let level: [UInt8] = [UInt8](repeating: 0, count: 3)    // 0=P, 1=I, 2=D
    let heading: [UInt8] = [UInt8](repeating: 0, count: 3)  // 0=P, 1=I, 2=D
    let vel_z: [UInt8] = [UInt8](repeating: 0, count: 3)    // 0=P, 1=I, 2=D
}


// MSP_MISC reply
struct msp_misc_t {
    let midrc: UInt16
    let minthrottle: UInt16
    let maxthrottle: UInt16
    let mincommand: UInt16
    let failsafe_throttle: UInt16
    let  gps_provider: UInt8
    let  gps_baudrate: UInt8
    let  gps_ubx_sbas: UInt8
    let  multiwiiCurrentMeterOutput: UInt8
    let  rssi_channel: UInt8
    let  dummy: UInt8
    let mag_declination: UInt16
    let  vbatscale: UInt8
    let  vbatmincellvoltage: UInt8
    let  vbatmaxcellvoltage: UInt8
    let  vbatwarningcellvoltage: UInt8
}


enum MSP_GPS: Int {
    // values for msp_raw_gps_t.fixType
    case MSP_GPS_NO_FIX = 0
    case MSP_GPS_FIX_2D = 1
    case MSP_GPS_FIX_3D = 2
}


// MSP_RAW_GPS reply
struct msp_raw_gps_t {
    let fixType: UInt8       // MSP_GPS_NO_FIX, MSP_GPS_FIX_2D, MSP_GPS_FIX_3D
    let numSat: UInt8
    let lat: Int32           // 1 / 10000000 deg
    let lon: Int32           // 1 / 10000000 deg
    let alt: Int16           // meters
    let groundSpeed: Int16   // cm/s
    let groundCourse: Int16  // unit: degree x 10
    let hdop: UInt16
}


// MSP_COMP_GPS reply
struct msp_comp_gps_t {
    let distanceToHome: Int16  // distance to home in meters
    let directionToHome: Int16 // direction to home in degrees
    let heartbeat: UInt8       // toggles 0 and 1 for each change
}


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


// MSP_NAV_STATUS reply
struct msp_nav_status_t {
    let mode: UInt8           // one of MSP_NAV_STATUS_MODE_XXX
    let state: UInt8          // one of MSP_NAV_STATUS_STATE_XXX
    let activeWpAction: UInt8 // combination of MSP_NAV_STATUS_WAYPOINT_ACTION_XXX
    let activeWpNumber: UInt8
    let error: UInt8          // one of MSP_NAV_STATUS_ERROR_XXX
    let magHoldHeading: UInt16
}


// MSP_GPSSVINFO reply
struct msp_gpssvinfo_t {
    let dummy1: UInt8
    let dummy2: UInt8
    let dummy3: UInt8
    let dummy4: UInt8
    let HDOP: UInt8
}


// MSP_GPSSTATISTICS reply
struct msp_gpsstatistics_t {
    let lastMessageDt: UInt16
    let errors: UInt32
    let timeouts: UInt32
    let packetCount: UInt32
    let hdop: UInt16
    let eph: UInt16
    let epv: UInt16
}


// MSP_UID reply
struct msp_uid_t {
    let uid0: UInt32
    let uid1: UInt32
    let uid2: UInt32
}

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


// MSP_FEATURE reply
struct msp_feature_t {
    let featureMask: UInt32 // combination of MSP_FEATURE_XXX
}


// MSP_BOARD_ALIGNMENT reply
struct msp_board_alignment_t {
    let rollDeciDegrees: Int16
    let pitchDeciDegrees: Int16
    let yawDeciDegrees: Int16
}


enum MSP_Current_Sensor: Int {
    // values for msp_current_meter_config_t.currentMeterType
    case MSP_CURRENT_SENSOR_NONE    = 0
    case MSP_CURRENT_SENSOR_ADC     = 1
    case MSP_CURRENT_SENSOR_VIRTUAL = 2
}


// MSP_CURRENT_METER_CONFIG reply
struct msp_current_meter_config_t {
    let currentMeterScale: Int16
    let currentMeterOffset: Int16
    let currentMeterType: Int16 // MSP_CURRENT_SENSOR_XXX
    let batteryCapacity: Int16
}


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


// MSP_RX_CONFIG reply
struct msp_rx_config_t {
    let serialrx_provider: UInt8  // one of MSP_SERIALRX_XXX values
    let maxcheck: UInt16
    let midrc: UInt16
    let mincheck: UInt16
    let spektrum_sat_bind: UInt8
    let rx_min_usec: UInt16
    let rx_max_usec: UInt16
    let dummy1: UInt8
    let dummy2: UInt8
    let dummy3: UInt16
    let rx_spi_protocol: UInt8  // one of MSP_SPI_PROT_XXX values
    let rx_spi_id: UInt32
    let rx_spi_rf_channel_count: UInt8
}

// MSP_RX_MAP reply
struct msp_rx_map_t {
    let rxmap: [UInt8] = [UInt8](repeating: 0, count: MSP_MAX_MAPPABLE_RX_INPUTS)  // [0]=roll channel, [1]=pitch channel, [2]=yaw channel, [3]=throttle channel, [3+n]=aux n channel, etc...
}

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

// MSP_SENSOR_ALIGNMENT reply
struct msp_sensor_alignment_t {
    let gyro_align: UInt8   // one of MSP_SENSOR_ALIGN_XXX
    let acc_align: UInt8    // one of MSP_SENSOR_ALIGN_XXX
    let mag_align: UInt8    // one of MSP_SENSOR_ALIGN_XXX
}


// MSP_CALIBRATION_DATA reply
struct msp_calibration_data_t {
    let accZeroX: Int16
    let accZeroY: Int16
    let accZeroZ: Int16
    let accGainX: Int16
    let accGainY: Int16
    let accGainZ: Int16
    let magZeroX: Int16
    let magZeroY: Int16
    let magZeroZ: Int16
}

// MSP_SET_HEAD command
struct msp_set_head_t {
    let magHoldHeading: Int16 // degrees
}

// MSP_SET_RAW_RC command
struct msp_set_raw_rc_t {
    let channel: [UInt16] = [UInt16](repeating: 0, count: MSP_MAX_SUPPORTED_CHANNELS)
}

// MSP_SET_RAW_GPS command
struct msp_set_raw_gps_t {
    let  fixType: UInt8       // MSP_GPS_NO_FIX, MSP_GPS_FIX_2D, MSP_GPS_FIX_3D
    let  numSat: UInt8
    let  lat: Int32           // 1 / 10000000 deg
    let  lon: Int32           // 1 / 10000000 deg
    let  alt: Int16           // meters
    let  groundSpeed: Int16   // cm/s
}


// MSP_SET_WP command
// Special waypoints are 0 and 255. 0 is the RTH position, 255 is the POSHOLD position (lat, lon, alt).
struct msp_set_wp_t {
    let waypointNumber: UInt8
    let action: UInt8   // one of MSP_NAV_STATUS_WAYPOINT_ACTION_XXX
    let lat: Int32      // decimal degrees latitude * 10000000
    let lon: Int32      // decimal degrees longitude * 10000000
    let alt: Int32      // altitude (cm)
    let p1: Int16       // speed (cm/s) when action is MSP_NAV_STATUS_WAYPOINT_ACTION_WAYPOINT, or "land" (value 1) when action is MSP_NAV_STATUS_WAYPOINT_ACTION_RTH
    let p2: Int16       // not used
    let p3: Int16       // not used
    let flag: UInt8     // 0xa5 = last, otherwise set to 0
}


class MSP: NSObject {
    
    func send(messageID: MSP_Request_Replies, payload: [UInt8] = [], size: UInt8 = 0){
        var buffCount = 0
        var buffer : [UInt8] = [UInt8](repeating: 0, count: payload.count + 6)
        buffer[0] = 36 // "$"
        buffer[1] = 77 // "M"
        buffer[2] = 60 // "<"
        buffer[3] = size
        buffer[4] = messageID.rawValue
        
        var checksum = size ^ messageID.rawValue
        
        buffCount = 5
        payload.forEach { b in
            checksum ^= b
            buffer[buffCount] = b
            buffCount += 1
        }
        buffer[buffCount] = checksum
        
        print(buffer)
    }
    
    func process_incoming_bytes(incomingData: Data) -> Bool {
        if incomingData.count < 6 {
            return false
        }
        
        let bytes: [UInt8] = incomingData.map{ $0 }
        
        print("bytes recv: \(bytes)")
        
        let h1 = 36 // "$"
        let h2 = 77 // "M"
        let h3 = 62 // ">"
        
        // check header
        if bytes[0] == h1 && bytes[1] == h2 && bytes[2] == h3 {
            // header ok, read payload size
            
            let recvSize = bytes[3]
            let messageID = bytes[4]
            print("Recived size: \(recvSize)")
            print("Message ID: \(messageID)")
            
            var payload: [UInt8] = [UInt8](repeating: 0, count: Int(recvSize))
            
            var checksumCalc: UInt8 = recvSize ^ messageID
            
            // read payload
            var idx = 5 // start from byte 5
            while (idx < recvSize) {
                let b: UInt8 = bytes[idx]
                checksumCalc ^= b;
                payload[idx] = b
                idx += 1;
            }
            
            // read and check checksum
            let checksum: UInt8 = bytes[idx]
            print("checksumCalc: \(checksumCalc)  ==  checksum: \(checksum)")
            if checksumCalc == checksum {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    func request(messageID: MSP_Request_Replies) {
        send(messageID: messageID)
    }
    
    
    // map MSP_MODE_xxx to box ids
    // mixed values from cleanflight and inav
    let BOXIDS: [UInt8] = [
        0,  //  0: MSP_MODE_ARM
        1,  //  1: MSP_MODE_ANGLE
        2,  //  2: MSP_MODE_HORIZON
        3,  //  3: MSP_MODE_NAVALTHOLD (cleanflight BARO)
        5,  //  4: MSP_MODE_MAG
        6,  //  5: MSP_MODE_HEADFREE
        7,  //  6: MSP_MODE_HEADADJ
        8,  //  7: MSP_MODE_CAMSTAB
        10, //  8: MSP_MODE_NAVRTH (cleanflight GPSHOME)
        11, //  9: MSP_MODE_NAVPOSHOLD (cleanflight GPSHOLD)
        12, // 10: MSP_MODE_PASSTHRU
        13, // 11: MSP_MODE_BEEPERON
        15, // 12: MSP_MODE_LEDLOW
        16, // 13: MSP_MODE_LLIGHTS
        19, // 14: MSP_MODE_OSD
        20, // 15: MSP_MODE_TELEMETRY
        21, // 16: MSP_MODE_GTUNE
        22, // 17: MSP_MODE_SONAR
        26, // 18: MSP_MODE_BLACKBOX
        27, // 19: MSP_MODE_FAILSAFE
        28, // 20: MSP_MODE_NAVWP (cleanflight AIRMODE)
        29, // 21: MSP_MODE_AIRMODE (cleanflight DISABLE3DSWITCH)
        30, // 22: MSP_MODE_HOMERESET (cleanflight FPVANGLEMIX)
        31, // 23: MSP_MODE_GCSNAV (cleanflight BLACKBOXERASE)
        32, // 24: MSP_MODE_HEADINGLOCK
        33, // 25: MSP_MODE_SURFACE
        34, // 26: MSP_MODE_FLAPERON
        35, // 27: MSP_MODE_TURNASSIST
        36, // 28: MSP_MODE_NAVLAUNCH
        37, // 29: MSP_MODE_AUTOTRIM
    ]
}


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
