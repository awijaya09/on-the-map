//
//  GCDBlackBox.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

func performUpdateOnMain(updates: () -> Void){
    dispatch_async(dispatch_get_main_queue()){
        updates()
    }
}