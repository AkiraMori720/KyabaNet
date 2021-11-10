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
import CryptoSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Friends: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ userId: String) {

		let predicate = NSPredicate(format: "userId == %@ AND friendId == %@", AuthUser.userId(), userId)
		if let friend = realm.objects(Friend.self).filter(predicate).first {
			friend.update(isDeleted: false, completion: nil)
			return
		}

		let realm = try! Realm()
		try! realm.safeWrite {
			let friend = Friend()
			friend.objectId = "\(AuthUser.userId())-\(userId)".md5()
			friend.userId = AuthUser.userId()
			friend.friendId = userId
            friend.pending = true
			realm.add(friend, update: .modified)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ userId: String, isDeleted: Bool) {

		let predicate = NSPredicate(format: "userId == %@ AND friendId == %@", AuthUser.userId(), userId)
		if let friend = realm.objects(Friend.self).filter(predicate).first {
			friend.update(isDeleted: isDeleted, completion: nil)
		}
	}
    
    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func update(_ userId: String, isAccepted: Bool) {

        let predicate = NSPredicate(format: "userId == %@ AND friendId == %@", userId, AuthUser.userId())
        if let friend = realm.objects(Friend.self).filter(predicate).first {
            friend.update(isAccepted: isAccepted)
        }
    }

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isFriend(_ userId: String) -> Bool {

		let predicate = NSPredicate(format: "userId == %@ AND friendId == %@ AND isDeleted == NO", AuthUser.userId(), userId)
        
        let predicate1 = NSPredicate(format: "friendId == %@ AND userId == %@ AND isDeleted == NO", AuthUser.userId(), userId)
        
		return (realm.objects(Friend.self).filter(predicate).first != nil || realm.objects(Friend.self).filter(predicate1).first != nil)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func friendIds() -> [String] {

		let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO", AuthUser.userId())
		let friends = realm.objects(Friend.self).filter(predicate)

		var friendIds: [String] = []
		for friend in friends {
			friendIds.append(friend.friendId)
		}
		return friendIds
	}
    
    class func friendAcceptedIds() -> [String] {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO AND isAccepted == YES", AuthUser.userId())
        let predicate1 = NSPredicate(format: "friendId == %@ AND isDeleted == NO AND isAccepted == YES", AuthUser.userId())
        
        let friends = realm.objects(Friend.self).filter(predicate)
        let friends1 = realm.objects(Friend.self).filter(predicate1)

        var friendIds: [String] = []
        for friend in friends {
            friendIds.append(friend.friendId)
        }
        for friend in friends1 {
            friendIds.append(friend.userId)
        }
        return friendIds
    }
    
    class func friendPendingIds() -> [String] {

        let predicate = NSPredicate(format: "friendId == %@ AND isDeleted == NO And pending == YES", AuthUser.userId())
        let friends = realm.objects(Friend.self).filter(predicate)

        var friendIds: [String] = []
        for friend in friends {
            friendIds.append(friend.userId)
        }
        return friendIds
    }
    
    class func friendRequestIds() -> [String] {

        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO And pending == YES", AuthUser.userId())
        let friends = realm.objects(Friend.self).filter(predicate)

        var friendIds: [String] = []
        for friend in friends {
            friendIds.append(friend.friendId)
        }
        return friendIds
    }
    
    class func removeFriend(_ userId: String, completion: (()->())?) {

        let predicate = NSPredicate(format: "userId == %@ AND friendId == %@ AND isDeleted == NO AND isAccepted == YES", AuthUser.userId(), userId)
        
        let predicate1 = NSPredicate(format: "friendId == %@ AND userId == %@ AND isDeleted == NO AND isAccepted == YES", AuthUser.userId(), userId)
        
        let friend1 = realm.objects(Friend.self).filter(predicate).first
        let friend2 = realm.objects(Friend.self).filter(predicate1).first
        
        let _friend = friend1 != nil ? friend1 : ( friend2 != nil ? friend2 : nil )
        
        guard let friend = _friend else{
            return
        }
        friend.update(isDeleted: true, completion: completion)
    }
}
