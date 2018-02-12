const util = require('util');
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const database = admin.database();

const RequestStatus = {
    "pending": "PENDING", // The SENDER is waiting on the RECIPIENT
    "accepted": "ACCEPTED", // The RECIPIENT has ACCEPTED the SENDERs the request
    "denied": "DENIED" // The RECIPIENT has DENIED the SENDERs the request
};

const RequestResponseMessage = {
    "pending": "jabbed you.",
    "accepted": "accpeted your jab",
    "denied": "denied your jab"
};

/*
    Handles newly created requests
    The procedure is as follows:
        1) Add the request to the RECIPIENTs list of received requests
        2) Send a notification to the RECIPIENT of the new request
*/
exports.requestCreated = functions.database.ref('requests/{key}').onCreate(event => {
    const requestKey = event.params.key;
    const senderUID = event.data.val().sender;
    const recipientUID = event.data.val().recipient;
    const name = event.data.val().name;
    const status = event.data.val().status;
    const message = event.data.val().message;
    
    const promises = [
        database.ref(`sentRequests/${senderUID}/${requestKey}`).set(status),
        database.ref(`receivedRequests/${recipientUID}/${requestKey}`).set(status)
    ];

    return Promise.all(promises).then(result => {

        const sorted = [senderUID, recipientUID].sort();
        const alphaParticipant = sorted[0];
        const betaParticipant = sorted[1];
        const conversationKey = `${alphaParticipant}:${betaParticipant}`;
        const messageKey = database.ref(`conversations/threads/${conversationKey}`).push().key;

        var messagesObject = {};
        messagesObject[messageKey] = {
            "sender": senderUID,
            "senderName": name,
            "recipient": recipientUID,
            "text": message,
            "timestamp": admin.database.ServerValue.TIMESTAMP
        }

        var updateObject = {};
        updateObject[`conversations/threads/${conversationKey}`] = messagesObject

        updateObject[`conversations/users/${recipientUID}/${senderUID}`] = {
            "key": conversationKey,
            "sender": senderUID,
            "recipient": recipientUID,
            "text": message,
            "timestamp": admin.database.ServerValue.TIMESTAMP,
            "muted": false,
            "seen": false
        };

        updateObject[`conversations/users/${senderUID}/${recipientUID}`] = {
            "key": conversationKey,
            "sender": senderUID,
            "recipient": recipientUID,
            "text": message,
            "timestamp": admin.database.ServerValue.TIMESTAMP,
            "muted": false,
            "seen": true
        };

        const setConversation = database.ref().update(updateObject);

        return setConversation.then(result => {
            // 2
            var pushNotificationPayload = {
                "notification": {
                    "type": "REQUEST",
                    "body": `${name} ${RequestResponseMessage.pending}`
                }
            };


            return sendPushNotificationToUser(recipientUID, pushNotificationPayload);
        });

    }).catch(error => {
        console.log(error);
        return;
    });

});

/*
    Handles status updates to requests
    The procedure is as follows:
        1) If the request has not been ACCEPTED or DENIED, do nothing
        2) Otherwise, update the status of the SENT request
        3) Get the USERNAME of the SENDER (to be used as part of the push notification)
        4) Send a notification to the SENDER (of the original request) of the status change
*/
exports.requestUpdated = functions.database.ref('requests/{key}').onUpdate(event => {
    const requestKey = event.params.key;
    const senderUID = event.data.val().sender;
    const recipientUID = event.data.val().recipient;
    const status = event.data.val().status;
    const message = event.data.val().message;

    // 1)
    if (status !== RequestStatus.accepted && status !== RequestStatus.denied) {
        return Promise.resolve()
    };

    // 2
    const promises = [
        database.ref(`sentRequests/${senderUID}/${requestKey}`).set(status),
        database.ref(`receivedRequests/${recipientUID}/${requestKey}`).set(status)
    ];

    return Promise.all(promises).then(results => {

        // 3
        const recipientName = database.ref(`users/${recipientUID}/firstLastName`).once('value');

        return recipientName;

    }).then(snapshot => {

        const name = snapshot.val();

        // 4
        var pushNotificationPayload = {};

        if (status === RequestStatus.accepted) {

            pushNotificationPayload = {
                "notification": {
                    "type": "REQUEST_ACCEPTED",
                    "body": `${name} ${RequestResponseMessage.accepted}`
                }
            };


        } else if (status === RequestStatus.denied) {
            pushNotificationPayload = {
                "notification": {
                    "type": "REQUEST_DENIED",
                    "body": `${name} ${RequestResponseMessage.denied}`
                }
            };
        }

        return sendPushNotificationToUser(senderUID, pushNotificationPayload);

    });

});

exports.newMessage = functions.database.ref('conversations/threads/{conversationKey}/{messageKey}').onCreate(event => {
    const conversationKey = event.params.conversationKey;
    const messageKey = event.params.messageKey;
    const data = event.data.val();
    const recipientUID = data.recipient;
    const senderUID = data.sender;
    const senderName = data.senderName;
    const text = data.text;
    const timestamp = data.timestamp;

    var updateObject = {};
    updateObject[`conversations/users/${recipientUID}/${senderUID}/sender`] = senderUID;
    updateObject[`conversations/users/${recipientUID}/${senderUID}/recipient`] = recipientUID;
    updateObject[`conversations/users/${recipientUID}/${senderUID}/text`] = text;
    updateObject[`conversations/users/${recipientUID}/${senderUID}/timestamp`] = timestamp;
    updateObject[`conversations/users/${recipientUID}/${senderUID}/seen`] = false;

    updateObject[`conversations/users/${senderUID}/${recipientUID}/sender`] = senderUID;
    updateObject[`conversations/users/${senderUID}/${recipientUID}/recipient`] = recipientUID;
    updateObject[`conversations/users/${senderUID}/${recipientUID}/text`] = text;
    updateObject[`conversations/users/${senderUID}/${recipientUID}/timestamp`] = timestamp;
    updateObject[`conversations/users/${senderUID}/${recipientUID}/seen`] = true;

    const update = database.ref().update(updateObject);
    return update.then(result => {

        const isRecipientMuted = database.ref(`conversations/users/${recipientUID}/${senderUID}/muted`).once('value');

        return isRecipientMuted.then(mutedResults => {
            const muted = mutedResults.val();
            if (muted) {
                return;
            }

            var pushNotificationPayload = {
                "notification": {
                    "type": "NEW_MESSAGE",
                    "body": `${senderName}: ${text}`
                }
            };

            return sendPushNotificationToUser(recipientUID, pushNotificationPayload);

        });

    });

});
/*
    Sends a push notification to the specified user with a given payload
    The procedure is as follows:
        1) Get the users Firebase Cloud Messaging Token (FCMToken)
        2) Get the number of PENDING requests for the user (this is used for the App Icon Badge Number)
        3) Send the payload
*/
function sendPushNotificationToUser(uid, payload) {

    var token = "";
    var badgeCount = 0;

    // 1
    const getUserToken = database.ref(`FCMToken/${uid}`).once('value');

    return getUserToken.then(tokenSnapshot => {
        if (tokenSnapshot.val() == null) {
            return Promise.reject("No Token Found.");
        }

        token = tokenSnapshot.val();

        // 2
        const getPendingRequests = database.ref(`receivedRequests/${uid}`).orderByValue().equalTo(RequestStatus.pending).once('value');
        return getPendingRequests;

    }).then(pendingRequestsSnapshot => {
        if (pendingRequestsSnapshot.val()) {
            badgeCount += pendingRequestsSnapshot.numChildren();
        }

        
        const getUnseenConversations = database.ref(`conversations/users/${uid}`).orderByChild('seen').equalTo(false).once('value');
        return getUnseenConversations;

    }).then(unseenConversationsSnapshot => {
        if (unseenConversationsSnapshot.val()) {
            badgeCount += unseenConversationsSnapshot.numChildren();
        }

        
        payload.notification.badge = `${badgeCount}`;

        // 3
        const sendPushNotification = admin.messaging().sendToDevice(token, payload);
        return sendPushNotification
    });
}