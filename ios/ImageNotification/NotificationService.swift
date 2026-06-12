import UserNotifications

/// ดาวน์โหลดรูปจาก FCM payload แล้วแนบก่อนแสดง notification (จำเป็นสำหรับรูปบน iOS)
class NotificationService: UNNotificationServiceExtension {
  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let bestAttemptContent else {
      contentHandler(request.content)
      return
    }

    guard let imageURLString = Self.imageURL(from: request.content.userInfo),
          let imageURL = URL(string: imageURLString)
    else {
      contentHandler(bestAttemptContent)
      return
    }

    URLSession.shared.downloadTask(with: imageURL) { location, _, _ in
      defer { contentHandler(bestAttemptContent) }

      guard let location else { return }

      let tmpPath = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("fcm-\(UUID().uuidString).jpg")

      do {
        try FileManager.default.moveItem(at: location, to: tmpPath)
        let attachment = try UNNotificationAttachment(
          identifier: "fcm-image",
          url: tmpPath,
          options: nil
        )
        bestAttemptContent.attachments = [attachment]
      } catch {
        // แสดง notification แบบไม่มีรูป
      }
    }.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    if let contentHandler, let bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

  private static func imageURL(from userInfo: [AnyHashable: Any]) -> String? {
    if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
       let image = fcmOptions["image"] as? String,
       !image.isEmpty
    {
      return image
    }

    if let image = userInfo["image"] as? String, !image.isEmpty {
      return image
    }

    if let gcm = userInfo["gcm.notification"] as? [String: Any],
       let image = gcm["image"] as? String,
       !image.isEmpty
    {
      return image
    }

    return nil
  }
}
