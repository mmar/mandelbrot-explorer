//
//  ViewController.swift
//  Mandelbrot Explorer
//
//  Created by Matusalem Marques on 02/06/2019.
//  Copyright © 2019 Matusalem Marques. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var renderer: MandelbrotRenderer!

    var translationOrigin: CGPoint?
    var zoomSize: CGSize?
    var zoomOrigin: CGPoint?

    @IBAction func zoomIn(_ sender: NSMagnificationGestureRecognizer) {
        let magnification = 1.0 + sender.magnification
        switch sender.state {
        case .began:
            zoomSize = renderer.size
            zoomOrigin = renderer.origin
            fallthrough
        case .changed:
            if let zoomSize = zoomSize {
                renderer.size = CGSize(
                    width: zoomSize.width / magnification,
                    height: zoomSize.height / magnification
                )
            }
            break
        case .cancelled:
            if let zoomSize = zoomSize {
                renderer.size = zoomSize
            }
            if let zoomOrigin = zoomOrigin {
                renderer.origin = zoomOrigin
            }
            fallthrough
        default:
            sender.magnification = 0.0
            zoomSize = nil
            zoomOrigin = nil
        }
    }

    @IBAction func pan(_ sender: NSPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        switch sender.state {
        case .began:
            translationOrigin = renderer.origin
            fallthrough
        case .changed:
            if let translationOrigin = translationOrigin {
                renderer.origin = CGPoint(
                    x: translationOrigin.x - renderer.size.width * translation.x / view.bounds.size.width,
                    y: translationOrigin.y + renderer.size.height * translation.y / view.bounds.size.height
                )
            }
            break
        case .cancelled:
            if let translationOrigin = translationOrigin {
                renderer.origin = translationOrigin
            }
            fallthrough
        default:
            sender.setTranslation(.zero, in: view)
            translationOrigin = nil;
            break;
        }
    }

}



