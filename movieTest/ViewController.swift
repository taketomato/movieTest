import UIKit
import AVKit
import Photos
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePickerController = UIImagePickerController()
    var videoURL: URL? {
        didSet {
            playButton.isEnabled = videoURL != nil
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var assetURLswitch: UISwitch!
    @IBOutlet var playButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playButton.isEnabled = videoURL != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PHPhotoLibrary.requestAuthorization { (_) in } // for iOS11
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }

        if assetURLswitch.isOn {
            videoURL = info["UIImagePickerControllerReferenceURL"] as? URL
        } else {
            videoURL = info["UIImagePickerControllerMediaURL"] as? URL
        }

        guard let url = videoURL else { return }
        print(url)

        if let i = previewImageFromVideo(url) {
            imageView.image = i
        }
    }
    
    // MARK: - Private

    // 動画からサムネイルを生成
    fileprivate func previewImageFromVideo(_ url: URL) -> UIImage? {
        let asset = AVAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value,2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
    // MARK: - IB Action
    
    // カメラロールから動画を選択
    @IBAction func selectImage(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"] // 動画のみ表示
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func playMovie(_ sender: Any) {
        guard let url = videoURL else { return }

        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        present(playerViewController, animated: true){
            playerViewController.player?.play()
        }
    }
}
