const functions = require("firebase-functions");
const stripe = require('stripe')(functions.config().stripe.testkey);

const admin = require('firebase-admin');
admin.initializeApp();

exports.stripePayment = functions.https.onRequest(async (req, res)=>{

    const amount = req.query.amount;

    const paymentIntent = await stripe.paymentIntents.create({
        amount,
        currency: 'myr',
      },
        function(err, paymentIntent){
            if(err != null){
                console.log(err);
            }else{
                res.json({
                    paymentIntent: paymentIntent.client_secret
                })
            }
        }
      )
})
/*
exports.sendMessageNotification = functions.https.onRequest(async (req, res) => {

  const receiverId = req.query.receiverId;
  const senderInfo = req.query.senderName + " sends a new message";
  const messageText = req.query.messageText;

  const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(receiverId).get();

  const receiverToken = userTokenSnapshot.data().deviceToken;
  if (!receiverToken) {
    console.log(`Device token not found for user ${receiverId}.`);
    return res.status(400).send('Device token not found');
  }

  const message = {
    token: receiverToken,
    notification: {
      title: senderInfo,
      body: messageText,
    },
    android: {
      notification: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
  };

  await admin.messaging().send(message);
   
});
*/
exports.sendMessageNotification = functions.https.onRequest(async (req, res) => {
  try {

    const receiverId = req.query.receiverId;
    const senderInfo = req.query.senderName + " sends a new message";
    const messageText = req.query.messageText;

    const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(receiverId).get();

    if (!userTokenSnapshot.exists) {
      console.log(`Device token not found for user ${receiverId}.`);
      return res.status(400).send('Device token not found');
    }

    const receiverToken = userTokenSnapshot.data().deviceToken;

    const message = {
      token: receiverToken,
      notification: {
        title: senderInfo,
        body: messageText,
      },
      android: {
        notification: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
    };

    await admin.messaging().send(message);

  } catch (e) {
    console.error("An error occurred:", e);
  }
});


exports.serviceConfirmedNotification = functions.https.onRequest(async (req, res) => {

  const customerId = req.query.customerId;
  const body = req.query.serviceName + " is confirmed by " + req.query.technicianName;

  const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(customerId).get();

  const receiverToken = userTokenSnapshot.data().deviceToken;
  if (!receiverToken) {
    console.log(`Device token not found for user ${customerId}.`);
    return res.status(400).send('Device token not found');
  }

  const message = {
    token: receiverToken,
    notification: {
      title: "Service Confirmed!",
      body: body,
    },
    android: {
      notification: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
  };

  await admin.messaging().send(message);
});

exports.serviceStatusChangedNotification = functions.https.onRequest(async (req, res) => {
  const newStatus = req.query.newStatus;
  const customerId = req.query.customerId;
  let title, body;

  if (newStatus === "Completed") {
    title = "Service Completed!";
    body = req.query.serviceName + " is completed";
  } else if (newStatus === "In Progress") {
    title = "Service In Progress!";
    body = req.query.serviceName + " is in progress";
  } else {
    return res.status(400).send('Invalid service status');
  }

  const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(customerId).get();

  const receiverToken = userTokenSnapshot.data().deviceToken;
  if (!receiverToken) {
    console.log(`Device token not found for user ${customerId}.`);
    return res.status(400).send('Device token not found');
  }

  const message = {
    token: receiverToken,
    notification: {
      title: title,
      body: body,
    },
    android: {
      notification: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
  };

  await admin.messaging().send(message);
});