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

exports.sendMessageNotification = functions.database.ref('/messages/{connectionId}/{messageId}')
  .onCreate(async (snapshot, context) => {
    const connectionId = context.params.connectionId;
    const messageId = context.params.messageId;
    const message = snapshot.val();

    const receiverId = message.receiverID;

    const userTokenSnapshot = await admin.firestore().collection('user_tokens').doc(receiverId).get();
    if (!userTokenSnapshot.exists) {
      console.log(`Device token not found for user ${receiverId}.`);
      return;
    }

    const receiverToken = userTokenSnapshot.data().deviceToken;
    if (!receiverToken) {
      console.log(`Device token not found for user ${receiverId}.`);
      return;
    }

    const payload = {
      notification: {
        title: message.senderName,
        body: message.messageText,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    await admin.messaging().Messaging.send(receiverToken, payload);
  });