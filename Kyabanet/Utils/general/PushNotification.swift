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

import Foundation
//----
class PushNotification: NSObject {
    
    class func send(token: String, title: String, body: String, type: NotiType, chatId: String?) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let serverKey = "AAAAIZkKOHc:APA91bGqNc7KmYPdANG2BiTrzNOBLgiRCIuudPvGP7Nvpijtj8FlSqPRCNTEbPvf8GE4pTNDZbHdabcSDdue7wWDQByV9QPPZY7ycItfrqG2K48dBt4sWiz96J3IDovNYPzZtiLU_yJu"
        
        let userId = AuthUser.userId()
        let paramString: [String : Any] = [
            "to" : token,
            "notification" :
                [
                    "title" : title,
                    "body" : body,
                    "sound": "default"
                ],
            "data" : ["userId" : userId,
                      "chatId" : chatId ?? "",
                      "noti_type": type.rawValue]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
