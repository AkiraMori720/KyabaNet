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
class Groups: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ name: String, userIds: [String]) -> Group{

		let group = Group()

		group.chatId	= group.objectId

		group.name		= name
		group.ownerId	= AuthUser.userId()

		let realm = try! Realm()
		try! realm.safeWrite {
			realm.add(group, update: .modified)
		}

		Details.create(chatId: group.chatId, userIds: userIds)
		Members.create(chatId: group.chatId, userIds: userIds)
        
        return group
	}
    
    class func remove(_ group: Group){
        for userId in Members.userIds(chatId: group.chatId){
            let predicate = NSPredicate(format: "chatId == %@ AND userId == %@ AND isDeleted == NO", group.chatId, userId)
            let detail = realm.objects(Detail.self).filter(predicate).first
            
            let predicate1 = NSPredicate(format: "chatId == %@ AND userId == %@ AND isActive == YES", group.chatId, userId)
            let member = realm.objects(Member.self).filter(predicate1).first
            if detail != nil {
                detail?.update(isDeleted: true)
            }
            if member != nil {
                member?.update(isActive: false)
            }
        }
        
        group.update(isDeleted: true)
        
    }
    
    class func leaveGroup(_ group: Group){
        
        let predicate = NSPredicate(format: "chatId == %@ AND userId == %@ AND isDeleted == NO", group.chatId, AuthUser.userId())
        let detail = realm.objects(Detail.self).filter(predicate).first
        
        let predicate1 = NSPredicate(format: "chatId == %@ AND userId == %@ AND isActive == YES", group.chatId, AuthUser.userId())
        let member = realm.objects(Member.self).filter(predicate1).first
        if detail != nil {
            detail?.update(isDeleted: true)
        }
        if member != nil {
            member?.update(isActive: false)
        }
        
        
    }
    
    class func invitePersons(_ group:Group, newInvitePersonIds: [String]){
        Details.create(chatId: group.chatId, userIds: newInvitePersonIds)
        Members.create(chatId: group.chatId, userIds: newInvitePersonIds)
    }
}
