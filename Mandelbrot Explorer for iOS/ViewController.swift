//
//  ViewController.swift
//  Mandelbrot Explorer for iOS
//
//  Created by Matusalem Marques on 10/06/2019.
//  Copyright © 2019 Matusalem Marques. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var renderer: MandelbrotRenderer!

    var panOrigin: CGPoint?

    @IBAction func zoomIn(_ sender: UIPinchGestureRecognizer) {
        // TODO
    }

    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        // TODO
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

