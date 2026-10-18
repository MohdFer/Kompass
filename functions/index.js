const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered whenever a new chat message is created in a tour.
 * Sends a high-priority FCM notification to all members subscribed to tour_{tourId}.
 */
exports.sendTourChatMessageNotification = onDocumentCreated(
  "Tours/{tourId}/Messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const tourId = event.params.tourId;
    const senderName = data.senderName || "Expedition Crew";
    const messageText = data.message || "";
    const senderId = data.senderId || "";

    const payload = {
      topic: `tour_${tourId}`,
      notification: {
        title: `💬 ${senderName}`,
        body: messageText,
      },
      data: {
        tourId: tourId,
        senderId: senderId,
        type: "chat",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "kompass_chat_channel",
          sound: "default",
          priority: "max",
          visibility: "public",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: `💬 ${senderName}`,
              body: messageText,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(payload);
      console.log(`Successfully sent chat notification for tour ${tourId}:`, response);
    } catch (error) {
      console.error("Error sending chat push notification:", error);
    }
  }
);

/**
 * Triggered whenever a new broadcast announcement is published in a tour.
 */
exports.sendTourAnnouncementNotification = onDocumentCreated(
  "Tours/{tourId}/Announcements/{announcementId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const tourId = event.params.tourId;
    const title = data.title || "Tour Announcement";
    const message = data.message || "";

    const payload = {
      topic: `tour_${tourId}`,
      notification: {
        title: `📢 ${title}`,
        body: message,
      },
      data: {
        tourId: tourId,
        type: "announcement",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "kompass_chat_channel",
          sound: "default",
          priority: "max",
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      console.log(`Sent announcement push for tour ${tourId}`);
    } catch (error) {
      console.error("Error sending announcement push notification:", error);
    }
  }
);

/**
 * Triggered whenever an SOS Emergency alert is triggered in a tour.
 */
exports.sendTourSOSAlertNotification = onDocumentCreated(
  "Tours/{tourId}/SOSAlerts/{alertId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const tourId = event.params.tourId;
    const senderName = data.userName || "Participant";
    const emergencyMsg = data.message || "Emergency distress signal raised!";

    const payload = {
      topic: `tour_${tourId}`,
      notification: {
        title: `🚨 SOS EMERGENCY: ${senderName}`,
        body: emergencyMsg,
      },
      data: {
        tourId: tourId,
        type: "sos",
        alertId: event.params.alertId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "kompass_chat_channel",
          sound: "default",
          priority: "max",
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      console.log(`Sent SOS push notification for tour ${tourId}`);
    } catch (error) {
      console.error("Error sending SOS push notification:", error);
    }
  }
);
