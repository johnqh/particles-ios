//
//  Debouncer.swift
//  Utilities
//
//  Created by John Huang on 10/21/18.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Foundation

public typealias DebouncedFunction = () -> Void

public class Debouncer: NSObject {
    public var current: DebounceHandler? {
        didSet {
            if current !== oldValue {
                if current != nil {
                    previous = current
                }
            }
        }
    }

    internal var previous: DebounceHandler?

    public var fifo: Bool = false

    override public init() {
        super.init()
    }

    public init(fifo: Bool) {
        self.fifo = fifo
        super.init()
    }

    public func debounce() -> DebounceHandler? {
        if !fifo || current == nil {
            let debouncer = DebounceHandler(debouncer: self)
            current = debouncer
            return debouncer
        }
        return nil
    }

    @discardableResult internal func run(handler: DebounceHandler?, function: @escaping DebouncedFunction) -> Bool {
        if handler === current {
            handler?.reallyRun(function)
            return true
        }
        return false
    }
}

public class DebounceHandler: NSObject {
    private weak var debouncer: Debouncer?

    public init(debouncer: Debouncer) {
        self.debouncer = debouncer
        super.init()
    }

    public func run(_ function: @escaping DebouncedFunction, delay: TimeInterval?, finish: Bool = true) {
        let backgrounds: [DebouncedFunction?] = []
        run(backgrounds: backgrounds, final: function, delay: delay)
    }

    fileprivate func reallyRun(_ function: @escaping DebouncedFunction) {
        function()
    }

    public func run(background: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }

    public func run(background: @escaping DebouncedFunction, then: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background, then]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }

    public func run(background: @escaping DebouncedFunction, then: @escaping DebouncedFunction, then another: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background, then, another]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }
    

    public func run(backgrounds: [DebouncedFunction?], final: @escaping DebouncedFunction, delay: TimeInterval?) {
        if let delay = delay, delay != 0 {
            Console.shared.log("Debouncer: \(delay)")
        }
        if let first = backgrounds.first {
            var leftOver = backgrounds
            leftOver.removeFirst()
            if let first = first {
                DispatchQueue.global().asyncAfter(deadline: .now() + (delay ?? 0)) { [weak self] in
                    if let self = self {
                        let ran = self.debouncer?.run(handler: self, function: first)
                        if let ran = ran, ran {
                            self.run(backgrounds: leftOver, final: final, delay: 0)
                        }
                    }
                }
            } else {
                run(backgrounds: leftOver, final: final, delay: delay)
            }
        } else {
            let direct = Thread.isMainThread && delay == nil
            if direct {
                self.debouncer?.run(handler: self, function: final)
                if self.debouncer?.fifo ?? false {
                    self.debouncer?.current = nil
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (delay ?? 0)) { [weak self] in
                    if let self = self {
                        self.debouncer?.run(handler: self, function: final)
                        if self.debouncer?.fifo ?? false {
                            self.debouncer?.current = nil
                        }
                    }
                }
            }
        }
    }

    public func cancel() {
        if debouncer?.current == self {
            debouncer?.current = nil
        }
    }

    deinit {
    }
}
