//
// Copyright (c) 2020 Related Code 
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Friend: SyncObject {

	@objc dynamic var userId = ""
	@objc dynamic var friendId = ""

	@objc dynamic var isDeleted = false
    
    @objc dynamic var pending = true
    
    @objc dynamic var isAccepted = false

	//---------------------------------------------------------------------------------------------------------------------------------------------
    func update(isDeleted value: Bool, completion: ( ()->())?) {

		if (isDeleted == value) { return }

		let realm = try! Realm()
		try! realm.safeWrite {
			isDeleted = value
			syncRequired = true
			updatedAt = Date().timestamp()
            completion?()
		}
	}
    
    func update(isAccepted value: Bool) {

        if (isAccepted == value) { return }

        let realm = try! Realm()
        try! realm.safeWrite {
            pending = false
            isAccepted = value
            syncRequired = true
            updatedAt = Date().timestamp()
        }
    }
}
