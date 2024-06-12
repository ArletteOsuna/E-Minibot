//
//  MiniBotBLEConnect.swift
//  MiniBot ESADE
//
//  Created by Arlette Osuna on 20/3/24.
//

import Foundation
import CoreBluetooth
import UIKit


/*
 * Protocol to detect the state of the connection..
 */
@objc protocol MiniBotBLEConnectDelegate {
    func connectionStatus(connected: Bool)
    @objc optional func batteryLevel(level: Int)
}


/*
 * Bluetooth robot class controller.
 */
class MiniBotBLEConnect: NSObject, ObservableObject {

    // MARK: - BLE
    private var centralQueue: DispatchQueue?
    
    // Delegate per detectar l'estat de la connexió.
    var delegate: MiniBotBLEConnectDelegate?

    private var serviceUUID:CBUUID!
    private var inputCharUUID:CBUUID!
    private var inputChar: CBCharacteristic?
    private var outputCharUUID:CBUUID! 
    private var outputChar: CBCharacteristic?
    
    // service and peripheral objects
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?

    
    // MARK: - Interface
    @Published var output = "Desconnetat "  // current text to display in the output field
    @Published var connected = false        // true when BLE connection is active
    
    // MARK: - Calculations
    private var operatorSymbol = ""
    
        
    
    /*
     * Constructor
     */
    init(bot:Int) {
        super.init()
        selectBot(bot: bot)
    }

    
    
    /*
     *
     */
    func selectBot(bot: Int) {
        switch bot {
            case 1:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0001")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0001")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0001")
            case 2:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0002")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0002")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0002")
            case 3:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0003")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0003")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0003")
            case 4:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0004")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0004")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0004")
            case 5:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0005")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0005")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0005")
            case 6:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0006")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0006")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0006")
            case 7:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0007")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0007")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0007")
            case 8:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0008")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0008")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0008")
            case 9:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0009")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0009")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0009")
            case 10:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0010")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0010")
                    outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0010")
            case 11:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0011")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0011")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0011")
            case 12:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0012")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0012")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0012")
            default:
                serviceUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0A0000")
                inputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0C0000")
                outputCharUUID = CBUUID(string: "EBC0FCC1-2FC3-44B7-94A8-A08D0A0B0000")
        }
    }
    
    
    
    /*
     * Send bytes.
     */
    func send(vals:[UInt8]) {
        guard let peripheral = connectedPeripheral,
              let inputChar = inputChar else {
            output = "Error de connexió !!!"
            return
        }
                
        peripheral.writeValue(Data(vals), for: inputChar, type: .withoutResponse)
    }
    
    
    
    /*
     * Send string.
     */
    func send(str: String) {
        let valueString = (str as String).data(using: .utf8)
        if let periferic = connectedPeripheral {
            if let txCharacteristic = inputChar {
                periferic.writeValue(valueString!, for: txCharacteristic, type: .withResponse)
            }
        }
    }

    
    
    /*
     *
     */
    func connectServer() {
        output = "Connecting ..."
        centralQueue = DispatchQueue(label: "test.discovery")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    
    
    /*
     *
     */
    func disconnectServer() {
        print("Disconnecting ...")
        guard let manager = centralManager,
              let peripheral = connectedPeripheral else { return }
        
        manager.cancelPeripheralConnection(peripheral)
    }
    
    
} // End MiniBotBLEConnect.

extension MiniBotBLEConnect: CBCentralManagerDelegate {

    /*
     * This method monitors the Bluetooth radios state
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                print("MiniBotBLEConnect -> Central Manager state: BLE is powered off.")
            case .poweredOn:
                print("MiniBotBLEConnect -> Central Manager state: BLE is poweredOn.")
                central.scanForPeripherals(withServices: [serviceUUID])
            case .resetting:
                print("MiniBotBLEConnect -> Central Manager state: BLE is resetting.")
            case .unauthorized:
                print("MiniBotBLEConnect -> Central Manager state: BLE is unauthorized.")
            case .unknown:
                print("MiniBotBLEConnect -> Central Manager state: BLE is unknown.")
            case .unsupported:
                print("MiniBotBLEConnect -> Central Manager state: BLE is unsupported.")
             default:
                print("MiniBotBLEConnect -> Central Manager state: Error !!")
        }
        
    }

    
    
    /*
     * Called for each peripheral found that advertises the serviceUUID.
     * This test program assumes only one peripheral will be powered up.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("MiniBotBLEConnect -> Discovered \(peripheral.name ?? "UNKNOWN")")
        central.stopScan()
        
        connectedPeripheral = peripheral
        central.connect(peripheral, options: nil)
    }

    
    /*
     * After BLE connection to peripheral, enumerate its services.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("MiniBotBLEConnect -> Connected to \(peripheral.name ?? "UNKNOWN")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        // Envia info al delegat true
        delegate?.connectionStatus(connected: true)
    }
    
    
    /*
     * After BLE connection, cleanup.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("MiniBotBLEConnect -> Disconnected from \(peripheral.name ?? "UNKNOWN")")
        
        centralManager = nil

        self.connected = false

        // Envia info al delegat false
        delegate?.connectionStatus(connected: false)
    }
    
} // End CBCentralManagerDelegate.

extension MiniBotBLEConnect : CBPeripheralDelegate {
    
    /*
     *
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("MiniBotBLEConnect -> Descobert servei pel perifèric -> \(peripheral.name ?? "DESCONEGUT !!")")
        
        if ((error) != nil) {
            print("MiniBotBLEConnect -> Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    
    /*
     *
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("MiniBotBLEConnect -> Descoberta característica pel perifèric -> \(peripheral.name ?? "DESCONEGUT !!")")
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for ch in characteristics {
            switch ch.uuid {
                case inputCharUUID:
                    inputChar = ch
                case outputCharUUID:
                    outputChar = ch
                    // subscribe to notification events for the output characteristic
                    peripheral.setNotifyValue(true, for: ch)
                default:
                    break
            }
        }
        
        DispatchQueue.main.async {
            self.connected = true
            self.output = "MiniBotBLEConnect -> Connected."
        }
    }
    
    
    
    /*
     *
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("MiniBotBLEConnect -> Notification state changed to \(characteristic.isNotifying)")
    }
    
    
    
    /*
     * Rep resposta del server ESP32.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("MiniBotBLEConnect -> Characteristic updated: \(characteristic.uuid)")
        if characteristic.uuid == outputCharUUID, let data = characteristic.value {
            // Sortida amb string
            let str = String(decoding: data, as: UTF8.self)
            print("MiniBotBLEConnect -> Bateria al \(str)%")
            // Envia info al delegat false
            delegate?.batteryLevel?(level: Int(str) ?? -1)
        }
    }

} // End CBPeripheralDelegate


