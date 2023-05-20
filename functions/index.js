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

exports.sendMessageNotification = functions.https.onRequest(async (req, res) => {

  const receiverId = req.query.receiverId;
  const senderInfo = req.query.senderName + " sends a new message";
  const messageText = req.query.messageText;

  const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(receiverId).get();

  const receiverToken = userTokenSnapshot.data().deviceToken;
  if (!receiverToken) {
    console.log(`Device token not found for user ${receiverId}.`);
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
  console.log("Message: " + message.toString());

  await admin.messaging().send(message);
   
});