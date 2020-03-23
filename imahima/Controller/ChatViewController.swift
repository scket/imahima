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
    var partner: User = User(id: "", name: "", pictureUrl: "")
    
    var messageList: [MockMessage] = []
    let me: Me = Me.sharedInstance
    let fireStoreService = FireStoreService()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // メッセージ追加用のクロージャ
    func messageAdded (messageData: MessageData) {
        self.messageList.append(self.branchMessageData(messageData: messageData))
        self.messagesCollectionView.insertSections([self.messageList.count - 1])
        self.messagesCollectionView.scrollToBottom()
    }
    
    // メッセージを送信者によって振り分ける
    func branchMessageData (messageData: MessageData) -> MockMessage {
        if (messageData.from == self.me.getId()) {
            return self.createSelfMessage(text: messageData.message, date: messageData.createdAt)
        } else {
            return self.createOtherMessage(text: messageData.message, date: messageData.createdAt)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // メインスレッドで非同期にメッセージを取得
        DispatchQueue.main.async {
            self.fireStoreService.getMessageData(id: self.roomId, completion: self.messageAdded)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        fireStoreService.removeSnapshotListenr()
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
            return Date(timeIntervalSince1970: Double(timestamp)!)
        }
    }
}

// DataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: me.getId(), displayName: me.getName())
    }
    
    func otherSender() -> SenderType {
        return Sender(id: self.partner.id, displayName: self.partner.name)
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
        
        var pictureUrl = ""
        if (message.sender.senderId == me.getId()) {
            pictureUrl = me.getPictureUrl()
        } else {
            pictureUrl = self.partner.pictureUrl
        }

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
                self.messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])

            } else if let text = component as? String {

                let message = createSelfMessage(text: text)
//                self.messageList.append(message)
                fireStoreService.setMessageData(
                    id: self.roomId,
                    messageData: MessageData(
                        from: me.getId(),
                        createdAt: String(Int(message.sentDate.timeIntervalSince1970)),
                        message: text
                    )
                )
//                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
