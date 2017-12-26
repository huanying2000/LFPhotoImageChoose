//
//  LFPhotoClosure.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import Foundation
import UIKit

typealias id = Any

typealias PhotoBlock = (() -> Void)
typealias PhotoCompleteBlock0 = ((id) -> Void)
typealias PhotoCompleteBlock1 = ((id,id) -> Void)
typealias PhotoCompleteBlock2 = ((id,id,id,UInt) -> Void)
typealias PhotoCompleteBlock4 = ((id,id,Bool) -> Void)
typealias PhotoCompleteBlock5 = ((id,id,UInt) -> Void)
typealias PhotoCompleteBlock6 = ((Bool,UInt) -> Void)
typealias PhotoCompleteBlock7 = ((id,id,id,id,Int) -> Void)
typealias PhotoCompleteBlock8 = ((Bool,id) -> Void)
typealias PhotoCompleteBlock9 = ((Bool) -> Void)
