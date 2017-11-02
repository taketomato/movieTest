import UIKit
import AVKit
import Photos
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?

    @IBOutlet var assetURLswitch: UISwitch!
    @IBOutlet weak var fileUrlLabel: UILabel!
    @IBOutlet weak var assetUrlLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PHPhotoLibrary.requestAuthorization { (_) in } // for iOS11
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if assetURLswitch.isOn {
            videoURL = info["UIImagePickerControllerReferenceURL"] as? URL // iOS11 で deprecated
        } else {
            videoURL = info["UIImagePickerControllerMediaURL"] as? URL
        }

        let completion: () -> () = { [weak self] in
            guard let url = self?.videoURL else { return }
            print(url)
            self?.playMovie(url)
        }

        imagePickerController.dismiss(animated: true, completion: completion)
    }
    
    // MARK: - Private

    fileprivate func playMovie(_ url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true){
            playerViewController.player?.play()
        }
    }
    
    fileprivate func updateLabel() {
        fileUrlLabel.isHidden = assetURLswitch.isOn
        assetUrlLabel.isHidden = !assetURLswitch.isOn
    }
    
    // MARK: - IB Action
    
    // カメラロールから動画を選択
    @IBAction func selectImage(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"] // 動画のみ表示
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func switched(_ sender: Any) {
        updateLabel()
    }
}
