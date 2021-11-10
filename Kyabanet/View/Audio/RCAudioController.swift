//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import AVKit
import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCAudioController: NSObject {

	private var messagesView: ChatViewController!
	private var audioPlayer: AVAudioPlayer?
	private var rcmessage: RCMessage?
	private var timer: Timer?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init<T: ChatViewController>(_ messagesView: T) {

		super.init()

		self.messagesView = messagesView
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		stopAudio()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func toggleAudio(_ indexPath: IndexPath) {

		if isCurrent(indexPath) {
			if isPlaying() { pauseAudio() }
			else if isPaused() { resumeAudio() }
		} else {
			stopAudio()
			playAudio(indexPath)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func stopAudio() {

		audioPlayer?.stop()
		audioPlayer = nil

		stopTimer()
		updateStatus(AudioStatus.AUDIOSTATUS_STOPPED)

		rcmessage = nil
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func playAudio(_ indexPath: IndexPath) {

		guard setupPlayer(indexPath) else { return }

		audioPlayer?.play()

		rcmessage = messagesView.rcmessageAt(indexPath)

		startTimer()
		updateStatus(AudioStatus.AUDIOSTATUS_PLAYING)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setupPlayer(_ indexPath: IndexPath) -> Bool {

		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .defaultToSpeaker)

		let rcmessage = messagesView.rcmessageAt(indexPath)
        if !rcmessage.audioPath.isEmpty {
			let url = URL(fileURLWithPath: rcmessage.audioPath)
			if let player = try? AVAudioPlayer(contentsOf: url) {
				audioPlayer = player
				audioPlayer?.delegate = self
				return true
			}
		}
		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func pauseAudio() {

		audioPlayer?.pause()

		stopTimer()
		updateStatus(AudioStatus.AUDIOSTATUS_STOPPED)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func resumeAudio() {

		audioPlayer?.play()

		startTimer()
		updateStatus(AudioStatus.AUDIOSTATUS_PLAYING)
	}
}

// MARK: -
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isCurrent(_ indexPath: IndexPath) -> Bool {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		return (self.rcmessage?.messageId == rcmessage.messageId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isPlaying() -> Bool {

		return (rcmessage?.audioStatus == AudioStatus.AUDIOSTATUS_PLAYING)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isPaused() -> Bool {

		return (rcmessage?.audioStatus == AudioStatus.AUDIOSTATUS_STOPPED)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateStatus(_ audioStatus: Int) {

		guard let rcmessage = rcmessage else { return }

		rcmessage.audioStatus = audioStatus
		if (audioStatus == AudioStatus.AUDIOSTATUS_STOPPED) {
			//rcmessage.audioDution = 0
		}

		messagesView.tableView.reloadData()
	}
}

// MARK: - Timer methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func startTimer() {

		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCell), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: .common)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func stopTimer() {

		timer?.invalidate()
		timer = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func updateCell() {

		guard let rcmessage = rcmessage else { return }
		guard let audioPlayer = audioPlayer else { return }

        //rcmessage.audioDuration = Int(audioPlayer.currentTime)

		if let indexPath = messagesView.indexPathBy(rcmessage) {
			if let visibleRows = messagesView.tableView.indexPathsForVisibleRows {
				if (visibleRows.contains(indexPath)) {
					if let cell = messagesView.tableView.cellForRow(at: indexPath) as? RCMessageAudioCell {
						//cell.updateProgress(rcmessage)
						//cell.updateDuration(rcmessage)

					}
				}
			}
		}
	}
}

// MARK: - AVAudioPlayerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController: AVAudioPlayerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

		stopAudio()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {

		stopAudio()
	}
}
