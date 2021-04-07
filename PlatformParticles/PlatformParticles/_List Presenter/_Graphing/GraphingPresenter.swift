//
//  GraphingPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 Qiang Huang. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIToolkits
import Utilities

open class GraphingPresenter: NSObject, ChartViewDelegate {
    @IBOutlet public var view: UIView?
    @IBOutlet public var chartView: LineChartView? {
        didSet {
            if chartView !== oldValue {
                chartView?.delegate = self
                chartView?.chartDescription?.enabled = false

                chartView?.leftAxis.enabled = false
                chartView?.rightAxis.drawAxisLineEnabled = false
                chartView?.xAxis.drawAxisLineEnabled = false

                chartView?.drawBordersEnabled = false
                chartView?.setScaleEnabled(true)

                if let legend = chartView?.legend {
                    legend.horizontalAlignment = .center
                    legend.verticalAlignment = .top
                    legend.orientation = .horizontal
                    legend.drawInside = false
                }
            }
        }
    }

    private var graphDebouncer: Debouncer = Debouncer()

    @IBOutlet open var presenters: [GraphingListPresenter]? {
        didSet {
            if let oldValue = oldValue {
                for presenter in oldValue {
                    changeObservation(from: presenter, to: nil, keyPath: #keyPath(GraphingListPresenter.graphing)) { _, _, _ in
                    }
                }
            }
            if let presenters = presenters {
                for presenter in presenters {
                    changeObservation(from: nil, to: presenter, keyPath: #keyPath(GraphingListPresenter.graphing)) { [weak self] _, _, _ in
                        self?.displayGraphing()
                    }
                }
            }
        }
    }

    private func displayGraphing() {
        let handler = graphDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.graph()
        }, delay: 0.0)
    }

    private func graph() {
        var datasets = [LineChartDataSet]()
        if let presenters = presenters {
            for presenter in presenters {
                if let graphing = presenter.graphing {
                    let set = LineChartDataSet(entries: graphing, label: presenter.label)
                    set.lineWidth = 2
                    set.circleRadius = 4
                    set.circleHoleRadius = 2
                    let color = presenter.color ?? UIColor.systemBlue
                    set.setColor(color)
                    set.setCircleColor(color)
                    datasets.append(set)
                }
            }
        }
        let chart = LineChartData(dataSets: datasets)
        chart.setValueFont(.systemFont(ofSize: 7, weight: .light))
        UIView.animate(chartView, type: .fade, direction: .none, duration: 0.1) { [weak self] in
            self?.chartView?.data = chart
        } completion: { _ in
        }

//        chartView?.chartAnimator?.animate(yAxisDuration: 0.1, easing: nil)
    }
}
