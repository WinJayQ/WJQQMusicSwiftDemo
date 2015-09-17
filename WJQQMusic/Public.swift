//
//  Public.swift
//  WJQQMusic
//
//  Created by jh navi on 15/9/16.
//  Copyright (c) 2015年 WJ. All rights reserved.
//

import Foundation
import UIKit
/**
*获取网络图片
*/

func getImageWithUrl(urlString:NSString)->UIImage{
    //var url : NSURL = NSURL(string:urlString)!
    var strUrl: String = urlString as! String
    var url: NSURL = NSURL(string: strUrl)!
    var data : NSData = NSData(contentsOfURL:url)!
    var image : UIImage = UIImage(data:data, scale: 1.0)!
    return image
}
