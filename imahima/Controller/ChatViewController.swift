//
//  ChatViewController.swift
//  imahima
//
//  Created by Shota Takeshima on 2019/12/11.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    var roomId: String = ""
    
    var messageList: [MockMessage] = []
    let me: Me = Me.sharedInstance
    let fireStoreService = FireStoreService()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        let messageDateList: Array<MessageData> = fireStoreService.getMessageData(id: self.roomId)
        
        // メインスレッドで非同期にメッセージを取得
        DispatchQueue.main.async {
            for messageData in messageDateList {
                if (messageData.from == self.me.getId()) {
                    self.messageList.append(self.createSelfMessage(text: messageData.message, date: messageData.createdAt))
                } else {
                    self.messageList.append(self.createOtherMessage(text: messageData.message, date:     messageData.createdAt))
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // メインスレッドで非同期にメッセージを取得
//        DispatchQueue.main.async {
//            // messageListにメッセージの配列をいれて
//            self.messageList = self.getMessages()
//            // messagesCollectionViewをリロードして
//            self.messagesCollectionView.reloadData()
//            // 一番下までスクロールする
//            self.messagesCollectionView.scrollToBottom()
//        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self as InputBarAccessoryViewDelegate
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.sendButton.tintColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.becomeFirstResponder()
    }
    
    // サンプル用メッセージ
    func getMessages() -> [MockMessage] {
        return [
            createOtherMessage(text: "あ"),
            createOtherMessage(text: "い"),
            createOtherMessage(text: "う"),
            createOtherMessage(text: "え"),
            createOtherMessage(text: "お"),
            createOtherMessage(text: "か"),
            createOtherMessage(text: "き"),
            createOtherMessage(text: "く"),
            createOtherMessage(text: "け"),
            createOtherMessage(text: "こ"),
            createOtherMessage(text: "さ"),
            createOtherMessage(text: "し"),
            createOtherMessage(text: "すせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"),
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// メッセージのclass管理用のextension
extension ChatViewController {
    func createSelfMessage (text: String, date: String! = nil) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),.foregroundColor: UIColor.white])
        return MockMessage(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: switchUnixToDate(timestamp: date))
    }
    
    func createSelfMessage (image: UIImage, date: String! = nil) -> MockMessage {
        return MockMessage(image: image, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: switchUnixToDate(timestamp: date))
    }
    
    func createOtherMessage(text: String, date: String! = nil) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),.foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: otherSender() as! Sender , messageId: UUID().uuidString, date: switchUnixToDate(timestamp: date))
    }
    
    func createOtherMessage (image: UIImage, date: String! = nil) -> MockMessage {
        return MockMessage(image: image, sender: otherSender() as! Sender , messageId: UUID().uuidString, date: switchUnixToDate(timestamp: date))
    }
    
    func switchUnixToDate (timestamp: String! = nil) -> Date {
        if (timestamp == nil) {
            return Date()
        } else {
            var int64 = Int64(timestamp) ?? 0
            int64 = int64 / 1000
            let timeIterval = TimeInterval(integerLiteral: int64)
            return Date(timeIntervalSince1970: timeIterval)
        }
    }
}

// DataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: me.getId(), displayName: me.getName())
    }
    
    func otherSender(id: String = "hoge", displayName: String = "you") -> SenderType {
        return Sender(id: id, displayName: displayName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // TODO: message.sentDateが1個前のメッセージより1日経過してたら日付出すようにしたい
        
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// Delegate
extension ChatViewController: MessagesDisplayDelegate {
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameから送信者の名前を取得して、imageを出し分ける
        let avatar: Avatar
        
        let me: Me = Me.sharedInstance
        let pictureUrl = me.getPictureUrl()
        
        if let url = URL(string: pictureUrl) {
              do {
                 let imageData = try Data(contentsOf: url)
                 let image = UIImage(data: imageData)
                 avatar = Avatar(image: image, initials: "Me")
              } catch {
                 avatar = Avatar(image: nil, initials: "人")
              }
           } else {
              avatar = Avatar(image: nil, initials: "人")
           }
           avatarView.set(avatar: avatar)
    }
}

// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {

                let imageMessage = createSelfMessage(image: image)
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])

            } else if let text = component as? String {

                let message = createSelfMessage(text: text)
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
