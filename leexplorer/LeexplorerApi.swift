//
//  LeexplorerApi.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class LeexplorerApi: AFHTTPSessionManager {
    
    typealias SuccessHandler = (operation: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void
    typealias FailHandler = (operation: NSURLSessionDataTask!, error: NSError!) -> Void
    
    class var shared : LeexplorerApi {
        struct Static {
            static let instance = LeexplorerApi(baseURL: NSURL(string: AppConstant.LEEXPLORER_ENDPOINT))
        }
        return Static.instance
    }
    
    override init!(baseURL url: NSURL!) {
        super.init(baseURL: url)
        self.requestSerializer = AFJSONRequestSerializer(writingOptions: nil)
        self.securityPolicy.validatesDomainName = false
    }
    
    override init!(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    override init!(sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(sessionConfiguration: configuration)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK - REQUEST INTERCEPTOR

    override func dataTaskWithRequest(request: NSURLRequest!, completionHandler: ((NSURLResponse!, AnyObject!, NSError!) -> Void)!) -> NSURLSessionDataTask! {
        var mutableRequest = request as NSMutableURLRequest
        
        mutableRequest.addValue("\(AppConstant.CLIENT_NAME)/\(AppConstant.CLIENT_VERSION)",
            forHTTPHeaderField: AppConstant.CLIENT_BUILD_HEADER_KEY)
        
        return super.dataTaskWithRequest(mutableRequest, completionHandler: completionHandler)
    }
    
    // MARK: - LE ENDPOINTS
    
    func getGalleries(success: (galleries: [Gallery]) -> Void, failure: FailHandler) {
        self.GET("/gallery", parameters: nil , success: { (_, collection) -> Void in
            LELog.d("galleries: \(collection.count)")
            var galleries: [Gallery] = []
            for galleryData in collection as [NSDictionary] {
                galleries.append(Gallery.createFromJSON(galleryData))
            }
            
            success(galleries: galleries)
            
        }, failure)
    }
    
    func getGalleryArtworks(gallery: Gallery, success: (artworks: [Artwork]) -> Void, failure: FailHandler) {
        self.GET("/gallery/\(gallery.id)/artworks", parameters: nil , success: { (_, collection) -> Void in
            var artworks: [Artwork] = []
            for artworkData in collection as [NSDictionary] {
                artworks.append(Artwork.createFromJSON(artworkData))
            }
            
            success(artworks: artworks)
            
        }, failure)
    }

   
    // MARK: - LE API
    
    override func GET(URLString: String!, parameters: AnyObject!, success: ((NSURLSessionDataTask!, AnyObject!) -> Void)!, failure: ((NSURLSessionDataTask!, NSError!) -> Void)!) -> NSURLSessionDataTask! {
        LELog.d("GET: \(self.baseURL)\(URLString)")
        LELog.d(parameters)
        return super.GET(URLString, parameters: parameters, success: success, failure: failure)
    }
    
}