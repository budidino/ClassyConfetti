//
//  Confetti.swift
//  ClassyConfetti
//
//  Created by Sai Hari on 21/07/22.
//

import Foundation
import GameKit
import QuartzCore
import UIKit

class Confetti: CAEmitterLayer {

    private let colors: [UIColor]
    private let content: [Content]

    init(colors: [UIColor]?, content: [Content]? = nil) {
        self.colors = colors ?? [.red, .orange, .yellow, .green]
        self.content = content ?? [
            .shape(.circle, 5.0, 5.0),
            .shape(.square, 5.0, 5.0),
            .shape(.triangle, 5.0, 5.0)
        ]
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func emit(in view: UIView, position: Position, duration: CFTimeInterval = 1) {
        birthRate = 0
        emitterPosition = position.getPoint(view: view)
        configure(content: content, position: position)
        frame = view.bounds
        beginTime = CACurrentMediaTime()
        view.layer.addSublayer(self)
        addBirthrateAnimation(to: self, time: duration)
    }

    private func configure(content: [Content], position: Position) {
        var i = 0
        emitterCells = content.map { content in
            let cell = CAEmitterCell()

            cell.birthRate = 100.0
            cell.lifetime = 10.0
            cell.velocity = 150
            cell.velocityRange = 100
            cell.emissionRange = CGFloat(Double.pi)
            cell.spin = .pi
            cell.spinRange = .pi * 4
            cell.scaleRange = 0.25
            cell.scale = 1.0 - cell.scaleRange
            cell.contents = content.image.cgImage
            cell.color = nextColor(i: i)
            cell.yAcceleration = 150

            i += 1
            return cell
        }
    }

    private func nextColor(i: Int) -> CGColor {
        colors[i % colors.count].cgColor
    }

    private func addBirthrateAnimation(to layer: CALayer, time: CFTimeInterval) {
        let animation = CABasicAnimation()
        animation.duration = time
        animation.fromValue = 2
        animation.toValue = 0

        layer.add(animation, forKey: "birthRate")
    }
}

extension Confetti {

    enum Content {
        case shape(Shape, CGFloat, CGFloat)
        case image(UIImage)

        var image: UIImage {
            switch self {
            case .shape(let shape, let width, let height):
                return shape.image(width: width, height: height)
            case .image(let image):
                return image
            }
        }

        enum Shape {
            case circle, triangle, square

            func path(in rect: CGRect) -> CGPath {
                switch self {
                case .circle:
                    return CGPath(ellipseIn: rect, transform: nil)
                case .triangle:
                    let path = CGMutablePath()
                    path.addLines(between: [
                        CGPoint(x: rect.midX, y: 0),
                        CGPoint(x: rect.maxX, y: rect.maxY),
                        CGPoint(x: rect.minX, y: rect.maxY),
                        CGPoint(x: rect.midX, y: 0)
                    ])
                    return path
                case .square:
                    return CGPath(rect: rect, transform: nil)
                }
            }

            func image(width: CGFloat, height: CGFloat) -> UIImage {
                let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
                return UIGraphicsImageRenderer(size: rect.size).image { context in
                    context.cgContext.setFillColor(UIColor.white.cgColor)
                    context.cgContext.addPath(path(in: rect))
                    context.cgContext.fillPath()
                }
            }
        }
    }

    enum Position {
        case top, topLeft, topRight, bottom, bottomLeft, bottomRight, center

        func getPoint(view: UIView) -> CGPoint {
            switch self {
            case .top:
                return CGPoint(x: view.bounds.midX, y: 0)
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .topRight:
                return CGPoint(x: view.bounds.maxX, y: 0)
            case .bottom:
                return CGPoint(x: view.bounds.midX, y: view.bounds.maxY)
            case .bottomLeft:
                return CGPoint(x: view.bounds.minX, y: view.bounds.maxY)
            case .bottomRight:
                return CGPoint(x: view.bounds.maxX, y: view.bounds.maxY)
            case .center:
                return CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            }
        }
    }
}
