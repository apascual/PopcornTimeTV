import UIKit
import AVKit
import AVFoundation
import PopcornTorrent

import Alamofire

internal class PlayerView: AVPlayerViewController {

    // MARK: - Attributes
    
    internal var presenter: PlayerPresenter?
    var torrentUrl : String!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var started: Bool = false
        var u: NSURL? = nil
        
        print(self.torrentUrl)

        var localPath: NSURL?
        Alamofire.download(.GET,
            self.torrentUrl,
            destination: { (temporaryURL, response) in
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = response.suggestedFilename
                
                localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                return localPath!
        })
            .response { (request, response, _, error) in
//                print(response)
//                print("Downloaded file to \(localPath?.path!)")
                
                PTTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(localPath?.path, progress: { (status) -> Void in
                    print("Status: \(status)")
                    if started { return }
                    guard let _url = u else { return }
                    if status.totalProgreess < 0.01 { return }
                    self.player = AVPlayer(URL: _url)
                    self.player?.play()
                    started = true
                    }, readyToPlay: { (url) -> Void in
                        u = url
                        print("Ready to play \(url)")
                    }) { (error) -> Void in
                        print("Error: \(error)")
                }

                
        }
        
        
    }
    
    // MARK: - Internal
    
    

}

