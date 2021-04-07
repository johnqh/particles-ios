//
//  RealLocation.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/18/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import CoreLocation
import Utilities

open class RealLocation: NSObject, LocationProviderProtocol {
    @objc public dynamic var location: CLLocation?
    private var backgroundToken: NotificationToken?
    private var foregroundToken: NotificationToken?

    open var background: Bool = false {
        didSet {
            if background != oldValue {
                updateBackground()
            }
        }
    }

    open var updating: Bool = true {
        didSet {
            if updating != oldValue {
                updateUpdating()
            }
        }
    }

    public var authorization: LocationPermission? {
        didSet {
            changeObservation(from: oldValue, to: authorization, keyPath: #keyPath(PrivacyPermission.authorization)) { [weak self] _, _, _ in
                if let self = self {
                    if self.authorization?.authorization == .authorized {
                        self.locationManager = self.authorization?.locationManager ?? CLLocationManager()
                    } else {
                        self.locationManager = nil
                        self.location = nil
                    }
                }
            }
        }
    }

    public var locationManager: CLLocationManager? {
        didSet {
            if locationManager !== oldValue {
                oldValue?.stopUpdatingLocation()
                oldValue?.delegate = nil
                locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager?.delegate = self
                updateUpdating()
            }
        }
    }

    override public init() {
        super.init()
        backgroundToken = NotificationCenter.default.observe(notification: UIApplication.didEnterBackgroundNotification, do: { [weak self] _ in
            self?.background = true
        })

        foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
            self?.background = false
        })
    }

    open func updateBackground() {
        updating = !background
    }

    private func updateUpdating() {
        if updating {
            locationManager?.startUpdatingLocation()
        } else {
            locationManager?.stopUpdatingLocation()
        }
    }
}

extension RealLocation: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first, first.coordinate.latitude != 0.0, first.coordinate.longitude != 0.0 {
            location = first
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let circular = region as? CLCircularRegion {
            RegionMonitor.shared?.enter(lat: circular.center.latitude, lng: circular.center.longitude)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let circular = region as? CLCircularRegion {
            RegionMonitor.shared?.exit(lat: circular.center.latitude, lng: circular.center.longitude)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorization?.refreshStatus()
    }
}
